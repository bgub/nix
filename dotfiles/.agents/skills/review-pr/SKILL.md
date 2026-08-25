---
name: review-pr
description: Review a GitHub PR by number or URL. By default, launch an isolated background review in a separate Herdr tab and worktree. If the user asks for a local review or says locally, in this checkout, in this tab, or without a separate workspace/tab, review directly in the current checkout and never create a Herdr workspace, tab, worktree, or background agent.
---

# Review PR

Choose the review mode from the user's wording before taking any action.

## Mode Selection

Use local mode when the user asks for a `local review`, says `locally`, `in this checkout`, `in this workspace`, `in this tab`, `here`, or explicitly asks not to create a separate workspace, worktree, tab, or background agent. Local mode takes precedence even when Herdr is available.

Use background mode for other PR review requests.

## Local Mode

Review the PR directly in the current agent and checkout.

- Do not call Herdr, create a worktree or tab, or delegate to another agent.
- Use `gh api` for PR metadata and comments when possible.
- Check the current branch and worktree status before reviewing. Preserve unrelated local changes.
- Fetch the PR head and base into temporary refs when needed. Do not switch branches or alter the current checkout merely to align it with the PR.
- If the current checkout contains the PR head, run focused tests and checks there when practical. Otherwise, inspect the fetched refs and clearly state that tests were not run against the PR checkout.
- Review both standards and spec: correctness, regressions, missing tests, async/resource risks, loose types, maintainability, and agreement with the PR description and commits.
- Return the full review in the current response, with findings ordered by severity and exact test commands/results.

## Background Mode

Launch a background Codex agent in an isolated worktree. The parent tab's job is orchestration only: create the worktree, start the agent, verify it is working, then stop.

## Background Contract

- Do not review the diff in the parent tab.
- Do not run installs, tests, or analysis in the parent tab.
- Do not wait for the background review to finish unless the user explicitly asks to wait.
- Return only the launch status, tab ID, pane ID, and worktree path.
- Use `gh api` for GitHub metadata when possible.
- Use `gpt-5.6-sol` with `model_reasoning_effort="high"` for the background agent.

If Herdr is unavailable, say that background PR reviews require running inside Herdr and ask whether to review in the current checkout instead.

## Launch Discipline

- Prefer one non-interactive shell block that creates the worktree, starts Codex, sends the prompt, presses Enter, and waits for `agent-status=working`.
- Do not split prompt submission and Enter/status verification across multiple assistant turns unless a command fails or the user interrupts.
- Keep command output concise: return IDs and paths, not full fetch/build logs.
- If interrupted after `herdr pane send-text`, recover by immediately running `herdr pane send-keys "$pane_id" Enter` and then waiting for `agent-status=working`.

## Launch Workflow

Preconditions:

- `HERDR_ENV=1`
- `command -v herdr`
- the current repo has GitHub metadata available through `gh api`

Fetch the PR, create a worktree under `~/gt/worktrees` when the repo is already under `~/gt`, otherwise under `~/code/worktrees`, and keep the current tab focused:

```bash
pr_number="<number>"
repo_root="$(git rev-parse --show-toplevel)"
owner_repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
pr_json="$(gh api "repos/${owner_repo}/pulls/${pr_number}")"
pr_url="$(printf '%s' "$pr_json" | jq -r .html_url)"
base_ref="$(printf '%s' "$pr_json" | jq -r .base.ref)"
head_ref="$(printf '%s' "$pr_json" | jq -r .head.ref)"
head_repo="$(printf '%s' "$pr_json" | jq -r .head.repo.full_name)"
label="review PR #${pr_number}"
stamp="$(date +%Y%m%d%H%M%S)"
safe_repo="$(basename "$repo_root" | tr -cd 'A-Za-z0-9._-')"
case "$repo_root" in
  "$HOME/gt"/*) worktree_parent="$HOME/gt/worktrees" ;;
  *) worktree_parent="$HOME/code/worktrees" ;;
esac
mkdir -p "$worktree_parent"
worktree_path="$worktree_parent/${safe_repo}-pr-${pr_number}-${stamp}"
review_branch="review/pr-${pr_number}-${stamp}"

git fetch origin "+pull/${pr_number}/head:refs/review-pr/${pr_number}" || \
  git fetch "https://github.com/${head_repo}.git" "+${head_ref}:refs/review-pr/${pr_number}"
git fetch origin "+${base_ref}:refs/review-pr/${pr_number}-base"
```

Discover the active workspace. Do not assume IDs:

```bash
current="$(herdr pane current --current)"
workspace_id="$(printf '%s' "$current" | jq -r '.result.pane.workspace_id // .pane.workspace_id // empty')"
```

Create the Herdr worktree. Use either `--workspace` or `--cwd`, not both; some Herdr versions reject passing both:

```bash
created="$(herdr worktree create \
  --workspace "$workspace_id" \
  --path "$worktree_path" \
  --branch "$review_branch" \
  --base "refs/review-pr/${pr_number}" \
  --label "$label" \
  --no-focus \
  --json)"

tab_id="$(printf '%s' "$created" | jq -r '.result.root_pane.tab_id // .root_pane.tab_id')"
pane_id="$(printf '%s' "$created" | jq -r '.result.root_pane.pane_id // .root_pane.pane_id')"
```

If `herdr worktree create` is unavailable or fails for a CLI-version reason, fall back to `git worktree add --detach "$worktree_path" "refs/review-pr/${pr_number}"`, then create a normal Herdr tab and parse the returned IDs:

```bash
git worktree add --detach "$worktree_path" "refs/review-pr/${pr_number}"
created="$(herdr tab create --workspace "$workspace_id" --cwd "$worktree_path" --label "$label" --no-focus --json)"
tab_id="$(printf '%s' "$created" | jq -r '.result.tab.tab_id // .tab.tab_id // .result.tab.id // .tab.id')"
pane_id="$(printf '%s' "$created" | jq -r '.result.root_pane.pane_id // .root_pane.pane_id')"
```

Start Codex in the review pane:

```bash
agent_cmd="codex -m gpt-5.6-sol -c model_reasoning_effort=\"high\" --cd \"$worktree_path\""
herdr pane run "$pane_id" "$agent_cmd"
herdr tab rename "$tab_id" "$label"
```

Send the delegated task. The prompt must explicitly prevent recursive delegation:

```bash
task_prompt="$(cat <<EOF
Review ${pr_url} in this repository.

You are already running in the isolated review worktree: ${worktree_path}.
Do not delegate this review to another agent, create another Herdr tab, or create another worktree.
The PR has been fetched into refs/review-pr/${pr_number}, and the base has been fetched into refs/review-pr/${pr_number}-base.
Use GitHub metadata through gh api. Base: ${base_ref}. Head: ${head_repo}:${head_ref}.

Run installs and focused tests/checks in this worktree where practical. If this is the gt monorepo and install is needed, use pnpm install --force, not CI=true pnpm install.

Review both Standards and Spec:
- Standards: correctness bugs, regressions, missing tests, async/resource risks, loose types, and maintainability issues.
- Spec: compare the PR description, commits, tests, and code. If no spec is available, say so.

Start with findings ordered by severity. Include exact test commands and results. Leave the final review in this tab.
EOF
)"

herdr wait output "$pane_id" --match "›" --lines 80 --timeout 120000
herdr pane send-text "$pane_id" "$task_prompt"

# CRITICAL: send-text only fills the Codex prompt. It does not submit it.
# Always press Enter immediately after sending the prompt.
herdr pane send-keys "$pane_id" Enter
```

Verify that the agent actually started. If it remains idle, assume the prompt
was not submitted and send Enter once more:

```bash
if ! herdr wait agent-status "$pane_id" --status working --timeout 120000; then
  herdr pane send-keys "$pane_id" Enter
  herdr wait agent-status "$pane_id" --status working --timeout 120000
fi
```

## Parent Response

After the background agent is working, stop. Do not read, summarize, or wait for review results.

Use this shape:

```markdown
Started background PR review.

- Tab: `w7:t1`
- Pane: `w7:p1`
- Worktree: `/path/to/worktree`
```

If launch fails or the background agent does not enter `working`, report the blocker and include the pane output if useful.
