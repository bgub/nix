import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";

type PatternConfig =
  | string
  | {
      pattern: string;
      replace?: string;
      flags?: string;
    };

interface RuleConfig {
  filePattern: string | string[];
  cloakPattern: PatternConfig | PatternConfig[];
  replace?: string;
}

interface CloakConfig {
  enabled?: boolean;
  cloakCharacter?: string;
  patterns?: RuleConfig[];
}

interface CompiledPattern {
  regex: RegExp;
  replace?: string;
}

interface CompiledRule {
  files: RegExp[];
  patterns: CompiledPattern[];
}

interface RuntimeState {
  configPath: string;
  config: Required<CloakConfig>;
  rules: CompiledRule[];
  error?: string;
}

interface PiContext {
  cwd: string;
  hasUI?: boolean;
  ui: {
    notify(message: string, level?: "error" | "info" | "warning"): void;
  };
}

interface ToolResultEvent {
  toolName?: string;
  input?: {
    path?: unknown;
  };
  content: Array<{ type: string; text?: string; [key: string]: unknown }>;
}

interface ExtensionAPI {
  on(eventName: string, handler: (...args: any[]) => unknown): void;
  registerCommand(
    name: string,
    command: {
      description: string;
      handler(args: string, ctx: PiContext): unknown;
    },
  ): void;
}

const DEFAULT_AGENT_DIR =
  process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
const DEFAULT_CONFIG_PATH = join(DEFAULT_AGENT_DIR, "cloak.json");
const DEFAULT_CONFIG: Required<CloakConfig> = {
  enabled: true,
  cloakCharacter: "*",
  patterns: [],
};

function asArray<T>(value: T | T[] | undefined): T[] {
  if (value === undefined) return [];
  return Array.isArray(value) ? value : [value];
}

function normalizePath(path: string): string {
  const expanded =
    path === "~"
      ? homedir()
      : path.startsWith("~/")
        ? join(homedir(), path.slice(2))
        : path;

  return expanded.trim().split("\\").join("/");
}

function stripLeadingAt(path: string): string {
  return path.startsWith("@") ? path.slice(1) : path;
}

function escapeRegex(value: string): string {
  return value.replace(/[|\\{}()[\]^$+?.]/g, "\\$&");
}

function globToRegExp(glob: string): RegExp {
  const normalized = normalizePath(glob);
  let source = "^";

  for (let index = 0; index < normalized.length; index++) {
    const char = normalized[index]!;
    const next = normalized[index + 1];
    const afterNext = normalized[index + 2];

    if (char === "*" && next === "*") {
      source += afterNext === "/" ? "(?:.*/)?" : ".*";
      index += afterNext === "/" ? 2 : 1;
    } else {
      source += char === "*" ? "[^/]*" : escapeRegex(char);
    }
  }

  return new RegExp(`${source}$`);
}

function compilePattern(
  pattern: PatternConfig,
  fallbackReplace?: string,
): CompiledPattern {
  if (typeof pattern === "string") {
    return {
      regex: new RegExp(pattern, "g"),
      replace: fallbackReplace,
    };
  }

  const flags = Array.from(new Set([...(pattern.flags ?? ""), "g"])).join("");
  return {
    regex: new RegExp(pattern.pattern, flags),
    replace: pattern.replace ?? fallbackReplace,
  };
}

function compileRule(rule: RuleConfig): CompiledRule {
  return {
    files: asArray(rule.filePattern).map(globToRegExp),
    patterns: asArray(rule.cloakPattern).map((pattern) =>
      compilePattern(pattern, rule.replace),
    ),
  };
}

export function loadState(configPath: string = DEFAULT_CONFIG_PATH): RuntimeState {
  try {
    const parsed = JSON.parse(readFileSync(configPath, "utf8")) as CloakConfig;
    const config: Required<CloakConfig> = {
      ...DEFAULT_CONFIG,
      ...parsed,
      patterns: parsed.patterns ?? [],
    };

    return {
      configPath,
      config,
      rules: config.patterns.map(compileRule),
    };
  } catch (error) {
    const code =
      typeof error === "object" && error !== null && "code" in error
        ? error.code
        : undefined;
    const message = error instanceof Error ? error.message : String(error);

    return {
      configPath,
      config: DEFAULT_CONFIG,
      rules: [],
      error:
        code === "ENOENT"
          ? `pi-cloak config not found at ${configPath}`
          : `pi-cloak failed to load ${configPath}: ${message}`,
    };
  }
}

function pathCandidates(rawPath: string, cwd: string): [string, string] {
  const cleanPath = normalizePath(stripLeadingAt(rawPath));
  const absolutePath = normalizePath(resolve(cwd, stripLeadingAt(rawPath)));

  return [cleanPath, absolutePath];
}

function matchesPath(rule: CompiledRule, rawPath: string, cwd: string): boolean {
  return pathCandidates(rawPath, cwd).some((path) =>
    rule.files.some((regex) => regex.test(path)),
  );
}

function renderTemplate(
  template: string,
  match: string,
  captures: string[],
): string {
  return template.replace(/\$(\$|&|\d{1,2})/g, (_token, group: string) => {
    if (group === "$") return "$";
    if (group === "&") return match;
    return captures[Number(group) - 1] ?? "";
  });
}

function maskValue(
  match: string,
  captures: string[],
  pattern: CompiledPattern,
  maskCharacter: string,
): string {
  const visible = pattern.replace
    ? renderTemplate(pattern.replace, match, captures)
    : match.slice(0, 1);
  const maskLength = Math.max(0, match.length - visible.length);

  return visible + maskCharacter.repeat(maskLength).slice(0, maskLength);
}

export function cloakText(
  text: string,
  rawPath: string,
  cwd: string,
  state: RuntimeState,
): string {
  if (!state.config.enabled) return text;

  let output = text;
  const maskCharacter = state.config.cloakCharacter || "*";
  for (const rule of state.rules) {
    if (!matchesPath(rule, rawPath, cwd)) continue;

    for (const pattern of rule.patterns) {
      output = output.replace(pattern.regex, (match: string, ...args: unknown[]) => {
        const captures = args
          .slice(0, Math.max(0, args.length - 2))
          .map((value) => String(value ?? ""));
        return maskValue(match, captures, pattern, maskCharacter);
      });
    }
  }

  return output;
}

export default function piCloak(pi: ExtensionAPI) {
  let state = loadState();

  const reloadConfig = () => {
    state = loadState();
  };

  pi.on("session_start", (_event: unknown, ctx: PiContext) => {
    reloadConfig();
    if (state.error && ctx.hasUI) {
      ctx.ui.notify(state.error, "warning");
    }
  });

  pi.registerCommand("cloak-status", {
    description: "Show pi-cloak config status",
    handler: (_args, ctx) => {
      reloadConfig();

      const summary = state.error
        ? `${state.error}\npatterns: ${state.rules.length}`
        : `pi-cloak enabled=${state.config.enabled} patterns=${state.rules.length} config=${state.configPath}`;

      ctx.ui.notify(summary, state.error ? "warning" : "info");
    },
  });

  pi.on("tool_result", (event: ToolResultEvent, ctx: PiContext) => {
    if (event.toolName !== "read" || !state.config.enabled) return undefined;

    const rawPath = typeof event.input?.path === "string" ? event.input.path : "";
    if (!rawPath) return undefined;

    let changed = false;
    const content = event.content.map((part) => {
      if (part.type !== "text" || typeof part.text !== "string") return part;

      const text = cloakText(part.text, rawPath, ctx.cwd, state);
      if (text === part.text) return part;

      changed = true;
      return { ...part, text };
    });

    return changed ? { content } : undefined;
  });
}
