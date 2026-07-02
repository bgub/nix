---
name: pr-stack
description: Manage PR stacks and branch-stack git workflows. Use when the user asks to rebase a stack, rebase current branch, squash changes, amend the last commit, push, force-push, create a fresh branch, inspect a PR stack, map parent/base branches, or work with stacked pull requests, GitHub PR metadata, and force-with-lease pushes.
---

# PR Stack

Use this skill for git and GitHub workflows around stacked pull requests.

## Ground Rules

- Use `gh api` for GitHub metadata when possible.
- Do not push, force-push, amend, or rebase until the user has explicitly asked for that operation.
- Before any history-rewriting operation, show the exact branch and commit scope involved.
- Use `--force-with-lease`, never plain `--force`.
- If a rebase conflicts, stop immediately and report the conflicted files. Do not resolve conflicts automatically.

## Discover The Current Branch

```bash
git branch --show-current
git status -sb
```

If there are uncommitted changes and the requested operation may rewrite history or switch branches, call that out before proceeding.

## Discover Repo Defaults

Get the repository owner/name and default branch:

```bash
owner_repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
default_branch="$(gh api "repos/${owner_repo}" --jq .default_branch)"
```

If JSON processing is needed, prefer `--jq` over ad hoc parsing.

## Get PR Metadata With `gh api`

For a branch, find the matching open PR:

```bash
owner_repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
owner="${owner_repo%%/*}"
branch="$(git branch --show-current)"
gh api --method GET "repos/${owner_repo}/pulls" -f head="${owner}:${branch}" -f state=open
```

Use the returned `head.ref`, `base.ref`, `number`, `title`, and `html_url`.

If the current branch has no PR, fall back to:

```bash
git config "branch.${branch}.merge"
git merge-base --fork-point origin/HEAD HEAD
```

Ask the user for the parent branch only if local and GitHub metadata cannot establish it.

## Map A PR Stack

Start from the current branch. Repeatedly find the branch's open PR and follow `base.ref` until one of these is true:

- `base.ref` is the default branch
- the parent branch has no open PR
- metadata cannot be found

Display the stack from root to tip:

```text
canary
  -> bg/base-change (#1001)
    -> bg/follow-up (#1002)  [current]
```

Use the immediate parent branch for branch-local diffs and the default branch for whole-stack operations.

## Create A Fresh Branch

Use when the user asks for a fresh branch.

1. Require a branch name.
2. Prefer names starting with `bg/` when the repository convention applies.
3. Fetch the default branch:

```bash
git fetch origin <default-branch> --prune
```

4. If the local branch already exists, stop and explain.
5. Create the branch without tracking:

```bash
git switch -c <branch-name> --no-track origin/<default-branch>
git status -sb
```

## Rebase A Stack

Use when the user asks to rebase a stack.

1. Map the stack.
2. Fetch the default branch:

```bash
git fetch origin <default-branch> --prune
```

3. Show the exact bottom-up plan:

```text
Will rebase:
  1. bg/base-change -> origin/canary
  2. bg/follow-up   -> bg/base-change
```

4. Ask for confirmation before running the first rebase.
5. Rebase bottom-up:

```bash
git switch <branch>
git rebase <parent>
```

6. On conflict, stop and show:

```bash
git diff --name-only --diff-filter=U
git status -sb
```

Tell the user which branch failed and that `git rebase --abort` is available.

7. After success, return to the starting branch and show:

```bash
git log --oneline --graph origin/<default-branch>..HEAD
git status -sb
```

Offer to force-push the rebased branches, but do not push unless the user confirms.

## Push Or Force-Push

Use when the user asks to push the current branch or a rebased stack.

For one branch:

```bash
branch="$(git branch --show-current)"
git log --oneline "origin/${branch}..HEAD"
git push --force-with-lease origin "${branch}"
```

If the remote branch does not exist, say that the push will create it.

For a stack, push bottom-up so CI and PR metadata update in dependency order:

```bash
git push --force-with-lease origin <branch>
```

## Squash Current Changes Into Last Commit

Use when the user asks to squash, amend, or fold current work into the previous commit.

1. Show the target commit and pending changes:

```bash
git log -1 --oneline
git status -s
```

2. If there are no staged or unstaged changes, stop.
3. Ask for confirmation unless the user's request was already explicit.
4. Amend:

```bash
git add -A
git commit --amend --no-edit
git log -1 --oneline
```
