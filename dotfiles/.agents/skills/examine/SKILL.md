---
name: examine
description: Review the current branch's changes against its parent in a PR stack
disable-model-invocation: true
allowed-tools: Bash(gh *), Bash(git *)
---

Review the current branch's diff against its immediate parent branch in a stacked PR workflow.

## Step 1: Map the stack

Start from the current branch and walk the stack downward using GitHub PR metadata.

For the current branch:
```
gh pr view --json headRefName,baseRefName,title,number,url
```

Record the `baseRefName` — that's the parent branch. Then check if the parent also has a PR:
```
gh pr view <baseRefName> --json headRefName,baseRefName,title,number,url
```

Keep walking until you hit a root branch (typically `main` or `canary`) or a branch with no associated PR.

Display the full stack to the user as a visual chain, e.g.:

```
canary
 └─ feat/base-refactor (#1234)
     └─ feat/base-refactor-tests (#1235)
         └─ feat/base-refactor-cleanup (#1236)  ← you are here
```

If the current branch has no PR yet, note that and use `git` to infer the parent:
```
git config branch.<current-branch>.merge
```
Or fall back to asking the user which branch is the parent.

## Step 2: Get the diff against the immediate parent

Use the **three-dot diff** to isolate only the commits on this branch since it diverged from its parent:

```
git diff <parent-branch>...HEAD
```

Also show a summary of what changed:
```
git diff <parent-branch>...HEAD --stat
```

And the commit log for this branch only:
```
git log <parent-branch>..HEAD --oneline
```

## Step 3: Review the changes

Perform a thorough code review of the diff. Focus on:

- **Correctness**: Logic errors, off-by-one mistakes, missing edge cases
- **Performance**: Unnecessary allocations, O(n²) where O(n) is possible, missing memoization
- **Consistency**: Does the code follow patterns established elsewhere in the codebase? Read surrounding files if needed to understand conventions.
- **Types**: Missing or overly loose types, unsafe casts, `any` usage
- **Tests**: Are changes covered? Are test assertions meaningful?
- **Naming**: Do variable/function names clearly convey intent?

Do NOT flag:
- Style/formatting nits (prettier handles that)
- Import ordering
- Minor preferences that don't affect correctness

Structure the review as:

### Summary
One or two sentences on what this branch does.

### Issues
Anything that looks like a bug or would cause problems. Include file paths and line context.

### Suggestions
Non-blocking improvements worth considering.

### Questions
Anything where the intent is unclear and you'd want to understand the reasoning.

If the changes look solid, say so plainly — don't manufacture feedback.
