---
name: squash
description: Stage all changes and amend them into the last commit
disable-model-invocation: true
allowed-tools: Bash(git *)
---

Squash all current changes into the last commit.

1. Show `git status -s` and `git log -1 --oneline` so the user can see what will be squashed and into which commit.
2. If there are no staged or unstaged changes, say so and stop.
3. Run `git add -A && git commit --amend --no-edit`.
4. Show `git log -1` to confirm the amended commit.
