---
name: herdr
description: Control Herdr from inside a Herdr-managed pane. Use when HERDR_ENV=1 and the task needs to manage workspaces, worktrees, tabs, panes, background agents, dev servers, tab titles, waits, or pane output through the herdr CLI.
---

# herdr

Use the `herdr` CLI to control the current Herdr session through its local socket.

## Preconditions

- First check `HERDR_ENV`. If it is not `1`, do not run Herdr orchestration commands; say that Herdr control is only available from inside Herdr.
- Check `command -v herdr` before relying on the CLI.
- Do not assume workspace, tab, or pane IDs. Discover them from `herdr pane current --current`, `herdr pane list`, `herdr tab list`, or command responses.
- Prefer `--no-focus` for background work unless the user asks to switch focus.

## Common Commands

```bash
herdr workspace list
herdr pane current --current
herdr pane list --workspace <workspace-id>
herdr tab list --workspace <workspace-id>
herdr tab create --workspace <workspace-id> --cwd "$PWD" --label "task label" --no-focus
herdr tab rename <tab-id> "new label"
herdr pane split --current --direction right --ratio 0.5 --cwd "$PWD" --no-focus
herdr pane run <pane-id> '<command>'
herdr pane read <pane-id> --source recent --lines 120
herdr worktree list --cwd "$PWD" --json
herdr worktree create --cwd "$PWD" --path <path> --branch <branch> --base <ref> --label "task label" --no-focus --json
herdr worktree open --cwd "$PWD" --path <path> --label "task label" --no-focus --json
herdr wait output <pane-id> --match "text" --lines 120 --timeout 600000
herdr wait agent-status <pane-id> --status done --timeout 1800000
```

`herdr tab create` returns the new tab ID and root pane ID. Parse those IDs from the command response instead of reconstructing them.

## Background Agent Tabs

For delegated background work, create a labeled background tab, run the agent command in the root pane, verify that the agent starts working, and leave the user's current tab focused. Do not wait for the background agent to finish unless the user explicitly asks.

```bash
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
label="review PR #123"
created="$(herdr tab create --workspace "<workspace-id>" --cwd "$repo_root" --label "$label" --no-focus)"
tab_id="<parse-tab-id-from-created>"
pane_id="<parse-root-pane-id-from-created>"
agent_cmd="codex -m gpt-5.5 -c model_reasoning_effort=\"high\" --cd \"$repo_root\""

herdr pane run "$pane_id" "$agent_cmd"
herdr tab rename "$tab_id" "$label"
```

If the agent needs an initial prompt and the CLI invocation cannot quote it safely, start Codex first, wait for the prompt UI, then send the task:

```bash
herdr wait output "$pane_id" --match "›" --lines 80 --timeout 120000
herdr pane send-text "$pane_id" "$task_prompt"
herdr pane send-keys "$pane_id" Enter
```

After submitting the task, verify that the agent actually started. If it remains idle, send Enter once more:

```bash
if ! herdr wait agent-status "$pane_id" --status working --timeout 120000; then
  herdr pane send-keys "$pane_id" Enter
  herdr wait agent-status "$pane_id" --status working --timeout 120000
fi
```

For fire-and-forget background tasks, stop after the agent is working and report only the tab ID, pane ID, and cwd/worktree path. If the user explicitly asks to wait for completion, then wait for `done`, read the pane output, and summarize it. If the delegated agent blocks or fails to start, read the pane output and report the blocker rather than guessing.

## Worktree And Server Tasks

Use Herdr worktree helpers when the user asks to create, switch, or manage worktrees from Herdr. Prefer `herdr worktree create --json` for new isolated work because it can create the worktree and associated Herdr tab in one operation. Use either `--workspace` or `--cwd`; do not pass both unless the local `herdr worktree create` usage explicitly supports it.

If a command response does not include the pane ID you need, use `herdr tab get <tab-id>` or `herdr pane list --workspace <workspace-id>` to discover the root pane for the new tab.

Use pane commands to start dev servers, wait for readiness text, and read logs.

Always keep IDs and commands in the final update when Herdr orchestration creates long-running background work.
