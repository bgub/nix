---
name: rebase
description: Fetch and rebase an entire PR stack onto the latest base branch
disable-model-invocation: true
allowed-tools: Bash(gh *), Bash(git *)
---

Fetch the base branch and rebase every branch in the current PR stack onto it, bottom-up.

## Step 1: Detect the default branch

Use the GitHub API to find the repo's default branch:

```
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

This handles `canary` (Next.js), `main`, `master`, etc. automatically.

## Step 2: Map the stack

Starting from the current branch, walk the stack using GitHub PR metadata, exactly like `/examine`:

```
gh pr view <branch> --json headRefName,baseRefName,title,number
```

Keep walking `baseRefName` until you hit the default branch or a branch with no PR. Build the ordered list from root to tip:

```
origin/canary
 └─ feat/step-1 (#1001)
     └─ feat/step-2 (#1002)
         └─ feat/step-3 (#1003)  ← you are here
```

Collect the branches into an ordered array, e.g. `[feat/step-1, feat/step-2, feat/step-3]`.

If the current branch has no PR, fall back to `git config branch.<name>.merge` or ask the user.

## Step 3: Fetch the base branch

```
git fetch origin <default-branch> --prune
```

## Step 4: Show the plan and confirm

Display what will happen before doing anything:

```
Will rebase the following stack onto origin/<default-branch>:

  1. feat/step-1  →  rebase onto origin/canary
  2. feat/step-2  →  rebase onto feat/step-1
  3. feat/step-3  →  rebase onto feat/step-2

Current branch: feat/step-3
```

**Ask the user for confirmation before proceeding.** This is a destructive operation that rewrites history.

## Step 5: Rebase bottom-up

Rebase each branch in order, from the bottom of the stack to the top. For each branch:

```
git checkout <branch>
git rebase <parent>
```

Where `<parent>` is `origin/<default-branch>` for the first branch, and the previous branch in the stack for all subsequent ones.

**If a rebase hits conflicts:**
1. Stop immediately.
2. Show the conflicting files with `git diff --name-only --diff-filter=U`.
3. Tell the user which branch/rebase failed and that they're in a dirty rebase state.
4. Remind them they can `git rebase --abort` to undo.
5. Do NOT attempt to resolve conflicts automatically.

## Step 6: Return to the original branch

After all rebases succeed, switch back to the branch the user started on:

```
git checkout <original-branch>
```

Show the final state:
```
git log --oneline --graph origin/<default-branch>..HEAD
```

Confirm that all branches in the stack have been rebased successfully.

## Step 7: Offer to force-push

Ask the user if they'd like to force-push the rebased branches. If yes, push each one:

```
git push --force-with-lease origin <branch>
```

Use `--force-with-lease` (not `--force`) as a safety measure. Push them in stack order (bottom-up) so CI triggers in the right sequence.

Do NOT push without explicit confirmation.
