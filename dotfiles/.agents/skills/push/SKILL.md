---
name: push
description: Force-push the current branch to GitHub
disable-model-invocation: true
allowed-tools: Bash(git *)
---

Push the current branch to GitHub.

1. Show `git log --oneline origin/<current-branch>..HEAD` to display what will be pushed. If the remote branch doesn't exist yet, note that this will create it.
2. Run `git push --force-with-lease origin <current-branch>`.
3. Show the result and confirm success.

Use `--force-with-lease` since stacked/rebased branches routinely need force pushes, but the lease check prevents overwriting unexpected remote changes.
