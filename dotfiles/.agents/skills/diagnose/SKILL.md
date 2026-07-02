---
name: diagnose
description: Diagnose bugs, failing tests, thrown errors, flaky behavior, and performance regressions. Use when the user asks to debug, diagnose, investigate a failure, explain why something is broken, or fix a bug with an unknown cause.
---

# Diagnose

Do not jump straight to a fix. Build a feedback loop first.

## Phase 1: Feedback Loop

Find or create a command that can reproduce the user's exact symptom.

Good loops include:

- focused failing test
- CLI invocation with fixture input
- HTTP/curl script against a dev server
- browser automation for UI behavior
- replayed trace, request, or log fixture
- small harness around the failing path

Tighten the loop until it is:

- red-capable: it can catch this exact bug
- deterministic, or high-reproduction for flaky bugs
- fast enough to run repeatedly
- agent-runnable without manual clicking when possible

If no loop can be built, stop and report what was tried. Ask for the missing artifact, environment, or permission needed.

## Phase 2: Reproduce And Minimize

Run the loop and confirm it shows the user's symptom.

Then minimize one variable at a time:

- input
- setup
- configuration
- caller chain
- data shape
- timing

Keep only what is load-bearing.

## Phase 3: Hypotheses

Generate 3-5 ranked, falsifiable hypotheses before changing code.

Use this format:

```text
If <cause> is true, then <probe/change> should <observable result>.
```

Test one variable at a time.

## Phase 4: Instrument

Prefer precise probes over broad logging:

- debugger or REPL inspection when available
- targeted logs at boundaries that distinguish hypotheses
- timing/profiling for performance issues

Tag temporary logs with a unique marker such as `[DEBUG-a4f2]` so cleanup is mechanical.

## Phase 5: Fix And Verify

When the cause is known:

1. Add or preserve a regression test at the correct seam.
2. Apply the smallest correct fix.
3. Run the minimized loop.
4. Run the original repro loop.
5. Run relevant nearby tests.
6. Remove debug instrumentation.

If no correct test seam exists, call that out as an architecture/testability gap.

## Output

Report:

- repro command
- minimized cause
- hypothesis that won
- fix summary
- tests run
- residual risk
