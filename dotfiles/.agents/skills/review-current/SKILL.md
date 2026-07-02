---
name: review-current
description: Review or simplify the current branch or worktree against its parent. Use when the user asks for a code review, current-branch review, current-worktree review, examine pass, refactor pass, simplification opportunities, LOC-reduction opportunities, or a review of committed plus uncommitted changes in the current checkout.
---

# Review Current

Use this skill to inspect the current checkout against its parent and produce either a bug-focused review or a refactoring/simplification review.

## Choose The Review Mode

Infer the mode from the request:

- Code review: prioritize correctness, regressions, missing tests, and behavior risks.
- Refactor review: prioritize reducing code, removing duplication, simplifying control flow, and improving maintainability.
- Combined review: use both when the user asks broadly.

## Determine The Parent

Prefer GitHub PR metadata through `gh api`.

```bash
owner_repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
owner="${owner_repo%%/*}"
branch="$(git branch --show-current)"
gh api --method GET "repos/${owner_repo}/pulls" -f head="${owner}:${branch}" -f state=open
```

Use the PR's `base.ref` as the immediate parent. If this branch is part of a stack, walk parent PRs the same way until reaching the default branch or a parent with no PR. Show the stack before reviewing:

```text
canary
  -> bg/base-change (#1001)
    -> bg/follow-up (#1002)  [current]
```

If there is no PR, use the upstream branch or repo default branch:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{upstream}
owner_repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
gh api "repos/${owner_repo}" --jq .default_branch
```

Ask the user for the parent only if it cannot be inferred.

## Gather The Diff

Use the three-dot diff for committed branch-local work:

```bash
git diff <parent>...HEAD --stat
git diff <parent>...HEAD
git log <parent>..HEAD --oneline
```

For refactor reviews, include in-progress work too:

```bash
git diff HEAD --stat
git diff HEAD
git diff <parent>...HEAD --name-only
git diff HEAD --name-only
```

Read the current version of every changed source file that matters to the review. Prefer `rg`, `sed`, and direct file reads over reasoning from diff hunks alone.

## Code Review Criteria

Look for:

- correctness bugs and edge cases
- behavioral regressions
- unsafe async or concurrency behavior
- resource cleanup problems
- loose types, unsafe casts, or unchecked external data
- missing or weak tests for changed behavior
- inconsistent local patterns that create real maintenance risk

Do not flag formatting, import ordering, or stylistic preferences that tooling handles.

Output format:

```markdown
### Issues

- **Severity:** file:line - Finding with concrete impact.

### Questions

- Anything that blocks confidence or needs product intent.

### Summary

Brief change summary and residual test risk.
```

If there are no issues, say that plainly and mention any remaining test gap.

## Refactor Review Criteria

Look for:

- dead code, unused variables, unreachable branches, and redundant checks
- duplicated logic that can become a loop, helper, or shared function
- over-abstraction and single-use wrappers that obscure simple code
- nested conditionals that can become guard clauses or derived state
- manual loops that can use clearer builtins
- mutable state that can be derived
- repeated test setup that can be made smaller without weakening assertions

Do not suggest comments as a substitute for simpler code.

Output format:

```markdown
### Overview

What changed, file count, and rough added/deleted lines.

### Refactoring Opportunities

1. **Where:** file:line
   **What:** short excerpt or description
   **Why:** concrete problem
   **How:** concrete replacement snippet
   **LOC impact:** estimated net change

### Summary

Total estimated LOC reduction and anything suspicious but uncertain.
```

After presenting refactor suggestions, ask which ones the user wants applied unless they already asked for implementation.
