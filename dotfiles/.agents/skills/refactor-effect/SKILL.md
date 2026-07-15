---
name: refactor-effect
description: Right-size Effect code. Use whenever WRITING, reviewing, or refactoring Effect code — services, layers, runtimes, run* boundaries, platform adapters — alongside the effect-ts skill. That skill teaches how to use Effect features; this one prevents over-engineering by saying when NOT to, pins v4 (effect-smol) semantics that differ from v3 lore, and shows real before/after refactors.
---

# Refactor Effect: Right-Sizing

Effect's failure mode in this codebase is not under-use — it is maximal idiom
applied to minimal problems: layer graphs over linear constructor chains,
hand-rolled boundary plumbing the runtime already provides, observability
ceremony with no consumer. Every example below is a real refactor the user had
to make by hand. Match against them before writing, not after.

## The Test

**Deleting the abstraction should lose something real.** If inlining a
service, layer, wrapper, or helper would be a pure simplification — no lost
substitution, no lost cleanup guarantee, no lost error information — inline it
now. Do not build for a hypothetical second consumer.

## Right-Sizing Rules

1. **Services and layers exist for substitution.** Reach for them only when
   there are multiple implementations, test doubles that actually get
   injected, or several long-lived subsystems sharing dependencies. A linear
   construction chain (config → handler → server) belongs in one
   `Effect.gen`, not a layer graph. If nothing will ever substitute a
   service, do not define it.

2. **The platform almost certainly owns that lifecycle.** Before wrapping a
   runtime API (`node:http`, signals, timers, file serving) in
   `Effect.callback` / `acquireRelease`, check `effect/unstable/*` and the
   `@effect/platform-*` packages in the vendored repo. Adapt platform APIs
   through their options (e.g. `runMain`'s `teardown`) instead of rebuilding
   their behavior around them.

3. **One `run*` call per program, at the true boundary — and trust it.**
   v4 `runPromise` rejects with the squashed typed error. Never unwrap
   `Exit`/`Cause` by hand to "surface typed errors"; that is v3 lore.

4. **No observability without a consumer.** Do not add `Effect.fn` span
   names, logger services, or metrics until an exporter or reader exists. A
   one-method service wrapping a plain function is a middle-man; call the
   function.

5. **Keep what Effect is actually buying.** In a server runtime that is:
   scoped resource lifecycle (acquire/release tied to a scope), the typed
   error channel surfaced at the boundary, and structured interruption. When
   simplifying, preserve exactly those and delete the rest.

## When the Machinery IS Warranted

Do not swing to under-engineering. Layers earn their place when several
long-lived subsystems (watchers, HMR sockets, build pipelines) share config
and lifecycle; `Effect.fn` earns its place when spans are exported;
`Context.Service` earns its place the moment a test injects a double. Add
them at that moment — they retrofit cheaply.

## v4 (effect-smol) Facts — Not v3 Lore

- `runPromise` rejects with the **typed error instance** (squashed Cause:
  first `Fail`, then defect). No `FiberFailure` unwrapping, no
  `runPromiseExit` + reasons loop at promise boundaries.
- `Layer.effect(Tag, effect)` **scopes its effect** (R excludes `Scope`);
  there is no separate `Layer.scoped`.
- `Layer.provideMerge` chains flatly: each `provideMerge` feeds everything
  piped before it. No named intermediate layers.
- `NodeRuntime.runMain`'s `onExit` only calls `process.exit` when a signal
  was received **or** the exit code is non-zero — this is what makes it
  adaptable for library use (see example 3).
- HTTP modules live in `effect/unstable/http`; the Node adapter is
  `@effect/platform-node`, version-locked **exactly** to `effect`
  (e.g. both `4.0.0-beta.92`).
- `HttpServerResponse.fromWeb(response)` bridges a web-standard handler;
  `NodeHttpServer.make(() => server, { port })` lets you keep the node
  `Server` instance for public APIs while the platform owns listen/close.

## Real Refactors (fig-start server runtime, 2026-07)

### 1. Layer graph → one scoped program

Before — six `Context.Service` classes and a layer graph, built because
"Effect code uses layers." Nothing ever substituted a service:

```ts
class StartConfig extends Context.Service<StartConfig, RuntimeConfig>()("StartConfig") {}
class StartLogger extends Context.Service<StartLogger, {...}>()("StartLogger") {}
class StartHandlerService extends Context.Service<...>()("StartHandler") {}
class ClientAssetStore extends Context.Service<...>()("ClientAssetStore") {}
class StartAppHandler extends Context.Service<...>()("StartAppHandler") {}
// ...five Layer.effect constructors, then:
return startAppHandlerLayer.pipe(
  Layer.provideMerge(clientAssetStoreLayer),
  Layer.provideMerge(startHandlerLayer(input.handlerOptions)),
  Layer.provideMerge(startConfigLayer(input.config)),
  Layer.provideMerge(startLoggerLayer(input.log)),
);
```

After — the chain was linear all along; one `Effect.gen` keeps the scoped
lifecycle and typed errors, which were the actual value:

```ts
Effect.scoped(
  Effect.gen(function* () {
    const config = yield* normalizeStartRuntimeConfig(input.config);
    const appHandler = createStartWebHandler({ /* plain constructors */ });
    const httpServer = yield* NodeHttpServer.make(() => server, { port: config.port })
      .pipe(Effect.mapError((e) => new StartListenError({ cause: e.cause, port: config.port })));
    yield* httpServer.serve(app);
    input.log(`Fig Start: ${config.publicUrl.href}`);
    yield* Deferred.succeed(started, server);
    yield* awaitServerClose(server);
  }),
)
```

### 2. Hand-rolled error boundary → `runPromise`

Before — v3 lore ("runPromise rejects with FiberFailure") produced 15 lines
of Cause spelunking:

```ts
return Effect.runPromiseExit(Deferred.await(started)).then((exit) => {
  if (Exit.isSuccess(exit)) return exit.value;
  throw startErrorFromCause(exit.cause);
});
function startErrorFromCause(cause: Cause.Cause<StartRuntimeError>): unknown {
  for (const reason of cause.reasons) {
    if (reason._tag === "Fail") return reason.error;
  }
  return Cause.squash(cause);
}
```

After — v4 already does exactly this:

```ts
return Effect.runPromise(Deferred.await(started));
```

### 3. Hand-rolled signal handling → `runMain` adapted via its options

Before — manual `process.once` listeners, a race against the server's
`close` event, and a re-raise dance with a stdout-flush hack:

```ts
const shutdown = yield* Effect.race(
  awaitShutdownSignal,                       // process.once(SIGINT/SIGTERM) + cleanup
  Effect.as(awaitServerClose(server), "closed" as const),
);
// ...then after scope close:
Effect.tap((s) => s === "closed" ? Effect.void
  : Effect.sync(() => { setImmediate(() => process.kill(process.pid, s)); }))
```

After — `NodeRuntime.runMain` owns interruption; a custom `teardown` adapts
its app-entrypoint semantics for library use (signal interrupts exit 130;
everything else passes 0, a no-op in runMain, so callers' processes survive):

```ts
NodeRuntime.runMain(program, {
  disableErrorReporting: true, // suppress runMain's default failure logging
  teardown: (exit, onExit) => {
    if (Exit.isFailure(exit) && Cause.hasInterruptsOnly(exit.cause)) {
      Runtime.defaultTeardown(exit, onExit); // Ctrl+C → exit 130
    } else {
      onExit(0); // no-op: external close and typed failures keep the process alive
    }
  },
});
```

`runMain` returns `void`; it handles process lifecycle, not caller-facing
error propagation. If a library API must reject on startup failure, bridge
both success and failure through a separate `Deferred` or promise boundary.
