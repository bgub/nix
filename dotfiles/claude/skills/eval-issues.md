---
name: eval-issues
description: Evaluate one or more GitHub issues in parallel to check if they're still reproducible
argument-hint: [issue-urls...]
disable-model-invocation: true
---

Evaluate one or more GitHub issues to check if they're still reproducible.

## Input

The issue URLs are: $ARGUMENTS

If no URLs were provided, ask for them and stop.

## Dispatch

For each issue URL, dispatch it to the `eval-issue` subagent **running in the background**. Run all of them in parallel — do not wait for one to finish before starting the next.

Each subagent task should simply be: `Evaluate this GitHub issue: <url>`

## Collect results

As each subagent completes, collect its results. Once all are done, present a summary table:

| Issue | Status | Package/Version | Summary |
|-------|--------|-----------------|---------|

Then show the bug description and draft comment for each issue.

## Review

For each issue, ask the user (using AskUserQuestion, all at once) what to do with the draft comment:
1. **Post** — run `gh issue comment <url> --body "<comment>"`
2. **Edit** — let the user modify it, then post
3. **Skip** — discard it
