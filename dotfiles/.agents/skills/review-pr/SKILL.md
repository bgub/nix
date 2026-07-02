---
name: review-pr
description: Review one or more GitHub pull requests from the current checkout. Use when the user asks to review a PR, review multiple PRs, inspect PR diffs, check out a PR for review, run tests for a PR, or examine PR changes. Do not create worktrees; the user may create/manage review worktrees separately.
---

# Review PR

Review requested PRs from the current checkout. Do not create worktrees; assume the user will create or select any needed worktree outside this skill.

## Inputs

Accept PR URLs, PR numbers, or branch names. If the user does not provide a PR identifier, ask for it and stop.

Support multiple PRs in one request. Process them independently and summarize results per PR. When reviewing multiple PRs, do not switch between them if that would overwrite local changes; ask the user to provide separate worktrees or confirm the checkout sequence.

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

## Fetch And Check Out The PR

Fetch each PR into a local review ref.

```bash
git fetch origin "pull/<number>/head:refs/review-pr/<number>"
git fetch origin "<base-ref>:refs/review-pr/<number>-base"
```

For forks where `pull/<number>/head` is unavailable, fetch the PR head repo explicitly into the same review ref:

```bash
git fetch "https://github.com/<head-repo-full-name>.git" "<head-ref>:refs/review-pr/<number>"
```

Before changing the current checkout, inspect local state:

```bash
git status -sb
```

If there are local changes, ask before switching. Otherwise check out the fetched PR head:

```bash
git switch --detach "refs/review-pr/<number>"
git status -sb
```

## Run Tests

Run tests after checking out the PR. Testing is part of the default review workflow unless the user explicitly asks for a diff-only review or the environment blocks it.

Follow repo-local instructions first. If package-manager commands fail because `pnpm`, `node`, or `npm` are missing, check the active `fnm` multishell bin path and prepend it to `PATH`.

For the gt monorepo, do not use `CI=true pnpm install`; use `pnpm install --force` when an install is needed.

Prefer commands implied by changed files and package scripts:

```bash
git diff --name-only "refs/review-pr/<number>-base...HEAD"
git status -sb
```

Then inspect repo scripts and run the narrowest useful checks. Examples:

```bash
pnpm lint
pnpm test -- <changed-test-or-package>
pnpm typecheck
```

If full `pnpm build` or `pnpm test` is likely impractical in the gt monorepo, say so and run focused tests instead. If tests cannot be run, report the exact blocker and continue with review.

## Examine The PR

Use the checked-out PR and the fetched base ref to examine the diff. The `review-current` workflow applies against the PR base.

```bash
git diff "refs/review-pr/<number>-base...HEAD" --stat
git diff "refs/review-pr/<number>-base...HEAD"
git log "refs/review-pr/<number>-base..HEAD" --oneline
```

Review for correctness, regressions, missing tests, type safety, async/resource handling, and consistency with nearby code. Do not flag formatting-only issues.

## Multiple PRs

For multiple PRs, fetch all review refs first. Review one checked-out PR at a time unless the user has already created separate worktrees. Keep outputs separated by PR number.

Final output:

```markdown
### PR <number>: <title>

- Tests: <passed/failed/skipped and command summary>
- Findings: <issues or "No blocking issues found">
- Notes: <review caveats>
```
