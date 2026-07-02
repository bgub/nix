---
name: loc
description: Count source LOC changed in the current Git worktree, including committed branch changes plus staged, unstaged, and untracked files. Use when the user asks for LOC, source LOC, diff size, or net added/deleted code against the branch base while excluding tests, comments, package.json, lockfiles, generated files, and non-source files.
---

# LOC

Count changed source LOC against the branch base.

1. Determine the base: prefer the PR base via `gh pr view --json baseRefName`, otherwise the upstream branch, otherwise `origin/HEAD`, `origin/main`, or `origin/master`.
2. Use `git merge-base <base> HEAD`, then inspect `git diff <merge-base>` plus untracked files from `git ls-files --others --exclude-standard`.
3. Count only changed nonblank source lines. Exclude tests/specs, fixtures, snapshots, generated/vendor/build output, comments, Markdown/docs, package manifests such as `package.json`, lockfiles, and binary/media files.
4. Report added, deleted, net, base ref, and any caveats.

Use shell tools (`git diff --numstat`, `git diff --unified=0`, `rg`, `awk`, `wc`) pragmatically; the goal is a useful source-code estimate, not a perfect parser.
