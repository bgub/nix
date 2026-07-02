/**
 * Git Interceptor
 *
 * Two guards for agent-driven git commands:
 *
 * 1. Editor hang prevention: Sets GIT_EDITOR, GIT_SEQUENCE_EDITOR to `true`
 *    and GIT_MERGE_AUTOEDIT to `no` so git never spawns an interactive editor.
 *
 * 2. Hook bypass prevention: Blocks commands containing `--no-verify`.
 */

const GIT_ENV_PREFIX =
  "export GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true GIT_MERGE_AUTOEDIT=no\n";

const NO_VERIFY_RE = /--no-verify\b/;
const GIT_COMMAND_RE = /(?:^|[\s;&|()])git(?:\s|$)/;

const BLOCK_REASON =
  "BLOCKED: --no-verify is not allowed. Git hooks exist for a reason. " +
  "Do not attempt to bypass them. Instead: fix the underlying issue that " +
  "is causing the hook to fail, or ask the user for help.";

interface BashToolCall {
  input: {
    command: string;
  };
}

interface ExtensionAPI {
  on(
    eventName: "tool_call",
    handler: (event: unknown) => { block: true; reason: string } | void,
  ): void;
}

function isBashToolCall(event: unknown): event is BashToolCall {
  if (typeof event !== "object" || event === null) return false;
  if (!("input" in event)) return false;
  const input = event.input;
  return (
    typeof input === "object" &&
    input !== null &&
    "command" in input &&
    typeof input.command === "string"
  );
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", (event) => {
    if (!isBashToolCall(event)) return;
    if (!GIT_COMMAND_RE.test(event.input.command)) return;

    if (NO_VERIFY_RE.test(event.input.command)) {
      return { block: true, reason: BLOCK_REASON };
    }

    event.input.command = GIT_ENV_PREFIX + event.input.command;
  });
}
