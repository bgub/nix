---
name: fresh-branch
description: Fetch canary and create a new branch from it
argument-hint: [branch-name]
disable-model-invocation: true
allowed-tools: Bash(git *)
---

Create a fresh branch named `$0` from `origin/canary`.

Workflow:

1. If `$0` is empty, ask for the branch name and stop.
2. Run `git fetch origin canary --prune`.
3. If a local branch named `$0` already exists, stop and explain that it already exists.
4. Run `git switch -c "$0" --no-track origin/canary`.
5. Show `git status -sb` and confirm the new branch is active.
