---
name: review-pr
description: Review one or more GitHub pull requests in isolated git worktrees. Use when the user asks to review a PR, review multiple PRs at once, run tests for PR review, examine a PR without disturbing the current checkout, or create per-PR review worktrees under ~/gt/worktrees or ~/code/worktrees.
---

# Review PR

Review each requested PR in its own worktree so multiple reviews can run independently.

## Inputs

Accept PR URLs, PR numbers, or branch names. If the user does not provide a PR identifier, ask for it and stop.

Support multiple PRs in one request. Process them independently and summarize results per PR.

## Worktree Root

Choose the worktree root from the current repository location:

- If the current repository is under `$HOME/gt`, use `$HOME/gt/worktrees`.
- Otherwise use `$HOME/code/worktrees`.

```bash
repo_root="$(git rev-parse --show-toplevel)"
case "$repo_root" in
  "$HOME/gt"/*) worktree_root="$HOME/gt/worktrees" ;;
  *) worktree_root="$HOME/code/worktrees" ;;
esac
mkdir -p "$worktree_root"
```

## Resolve PR Metadata

Use the GitHub CLI API where possible.

```bash
owner_repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
repo_name="${owner_repo##*/}"
```

For a PR number:

```bash
gh api "repos/${owner_repo}/pulls/<number>"
```

For a PR URL, parse the owner, repo, and number from the URL and use:

```bash
gh api "repos/<owner>/<repo>/pulls/<number>"
```

Record:

- PR number, title, URL
- `head.sha`, `head.ref`, `head.repo.full_name`
- `base.ref`, `base.repo.full_name`

## Create One Worktree Per PR

Use a stable, readable directory name:

```bash
worktree_path="${worktree_root}/${repo_name}-pr-<number>"
```

If the path already exists:

1. Check whether it is a git worktree with `git -C "$worktree_path" rev-parse --show-toplevel`.
2. Check whether it is dirty with `git -C "$worktree_path" status --short`.
3. If it is dirty, stop for that PR and ask before reusing or replacing it.
4. If it is clean, reuse it after fetching and checking out the current PR head.

```bash
git -C "$repo_root" fetch origin "pull/<number>/head"
git -C "$worktree_path" checkout --detach FETCH_HEAD
```

For a fresh worktree, fetch the PR and create a detached worktree at the PR head:

```bash
git fetch origin "pull/<number>/head"
git worktree add --detach "$worktree_path" FETCH_HEAD
```

For forks where `pull/<number>/head` is unavailable, fetch the PR head repo explicitly:

```bash
git -C "$repo_root" fetch "https://github.com/<head-repo-full-name>.git" "<head-ref>"
git worktree add --detach "$worktree_path" FETCH_HEAD
```

Fetch the base branch for comparison:

```bash
git -C "$worktree_path" fetch origin "<base-ref>"
```

## Install Or Reuse Dependencies

Do not assume dependencies are installed in the new worktree.

Follow repo-local instructions first. If package-manager commands fail because `pnpm`, `node`, or `npm` are missing, check the active `fnm` multishell bin path and prepend it to `PATH`.

For the gt monorepo, do not use `CI=true pnpm install`; use `pnpm install --force` when an install is needed.

## Run Tests

Run focused validation from inside the worktree.

Prefer commands implied by changed files and package scripts:

```bash
git -C "$worktree_path" diff --name-only "origin/<base-ref>...HEAD"
git -C "$worktree_path" status -sb
```

Then inspect repo scripts and run the narrowest useful checks. Examples:

```bash
pnpm lint
pnpm test -- <changed-test-or-package>
pnpm typecheck
```

If full `pnpm build` or `pnpm test` is likely impractical in the gt monorepo, say so and run focused tests instead. If tests cannot be run, report the exact blocker and continue with review.

## Examine The PR

Inside each worktree, use the `review-current` workflow against the PR base:

```bash
cd "$worktree_path"
git diff "origin/<base-ref>...HEAD" --stat
git diff "origin/<base-ref>...HEAD"
git log "origin/<base-ref>..HEAD" --oneline
```

Review for correctness, regressions, missing tests, type safety, async/resource handling, and consistency with nearby code. Do not flag formatting-only issues.

## Multiple PRs

For multiple PRs, create or reuse all worktrees first, then run review/test work independently per worktree. Parallelize where tools allow it, but keep outputs separated by PR number.

Final output:

```markdown
### PR <number>: <title>

- Worktree: <path>
- Tests: <passed/failed/skipped and command summary>
- Findings: <issues or "No blocking issues found">
- Notes: <review caveats>
```

Do not remove worktrees after review unless the user asks.
