---
name: review-current
description: Review local code changes, a local branch, staged or unstaged work, or the current checkout against an inferred base. Use when the user asks for a code review, current branch review, examine pass, refactor pass, simplification review, review since a ref, or review unstaged changes without giving a GitHub PR number or URL.
---

# Review Current

Review the current checkout or a local branch in the active worktree. Prefer a bug-focused review unless the user asks for refactoring, simplification, or LOC reduction.

## Determine The Subject

If the user provides a branch name but no PR number, review it locally as a branch comparison unless GitHub metadata unambiguously maps it to an open PR.

If no ref is provided, review the current checkout:

- include committed branch changes
- include staged changes
- include unstaged changes
- include untracked source files when relevant

Do not create a Herdr worktree for current-checkout or local-branch reviews. If switching branches is necessary and there are local changes, ask before switching.

## Determine The Base

Prefer GitHub metadata through `gh api`.

For the current checkout:

1. If the current branch has an open PR, use that PR's `base.ref`.
2. Otherwise use the upstream branch if configured.
3. Otherwise use the repo default branch from `gh api "repos/${owner_repo}" --jq .default_branch`.
4. If the current branch is already the default/base branch, review staged, unstaged, and untracked changes against `HEAD`.

Ask for the base only if none of these can be inferred.

## Gather The Diff

For branch committed changes:

```bash
git diff <base>...HEAD --stat
git diff <base>...HEAD
git log <base>..HEAD --oneline
```

For current-checkout review, also include in-progress changes:

```bash
git diff --stat
git diff
git diff --cached --stat
git diff --cached
git ls-files --others --exclude-standard
```

Read the current version of changed source files that matter. Do not review from diff hunks alone when surrounding context affects correctness.

## Review Discipline

- Do not edit code during review unless the user explicitly asks for fixes.
- Trace changed behavior from the entry point through the relevant call sites before reporting a bug.
- Each finding needs file/line evidence, concrete impact, and a plausible failing path.
- Before reporting a finding, challenge it against existing guards, tests, types, feature flags, and runtime invariants.
- If evidence is weak, downgrade it to an open question or omit it.

## Run Tests

Run focused tests/checks as part of the default review unless the user asks for a diff-only review or the environment blocks it.

Follow repo-local scripts. If `pnpm`, `node`, or `npm` are missing, check the active `fnm` multishell bin path and prepend it to `PATH`.

For the gt monorepo:

- do not use `CI=true pnpm install`
- use `pnpm install --force` if an install is needed
- full `pnpm build` and `pnpm test` may be impractical; run focused checks when possible

Prefer commands implied by changed files and packages, for example:

```bash
pnpm lint
pnpm typecheck
pnpm test -- <changed-test-or-package>
```

Report exact commands and results. If tests cannot be run, report the blocker.

## Review Axes

Keep these axes separate in the final output.

### Standards

Check whether the change follows repo conventions and general code quality:

- correctness bugs and edge cases
- behavioral regressions
- missing or weak tests
- unsafe async/concurrency behavior
- resource cleanup problems
- loose types, unsafe casts, or unchecked external data
- duplication, speculative abstractions, middle-man wrappers, and needless complexity
- inconsistency with nearby patterns that creates real maintenance risk

Skip formatting, import ordering, and style issues that tooling handles.

### Spec

Check whether the change appears to implement what was requested:

- requirements missing or only partially implemented
- behavior not asked for or surprising scope creep
- implementation that appears to satisfy the request but is semantically wrong
- mismatches between PR/issue description, commit messages, tests, and code

If there is no spec or PR description, say "No spec available" and do not invent one.

## Output

Start with findings, ordered by severity. Keep Standards and Spec separate:

```markdown
## Standards

- **High:** file:line - Finding with concrete impact.

## Spec

- No spec available.

## Tests

- `pnpm test -- foo`: passed

## Summary

Brief change summary and residual risk.
```

If there are no issues, say so plainly and mention any remaining test gap.
