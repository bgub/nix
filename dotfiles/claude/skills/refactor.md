---
name: refactor
description: Analyze current branch changes for refactoring and simplification opportunities
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *), Read, Grep, Glob
---

Analyze all changes on the current branch (committed + uncommitted) and suggest ways to simplify, reduce code, and improve quality.

## Step 1: Gather the full picture

Determine the parent branch. If there's a PR, use:
```
gh pr view --json baseRefName --jq '.baseRefName'
```
Otherwise fall back to the repo's default branch:
```
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

Then collect everything — committed work plus any in-progress changes:

```
# All committed changes on this branch vs parent
git diff origin/<parent>...HEAD

# Uncommitted staged + unstaged changes
git diff HEAD

# Combined stat summary
git diff origin/<parent>...HEAD --stat
git diff HEAD --stat
```

Also get the list of changed files:
```
git diff origin/<parent>...HEAD --name-only
git diff HEAD --name-only
```

Read the full current version of every changed file so you can see the changes in context, not just the diff hunks.

## Step 2: Analyze

For each changed file, look for:

**Reduce LOC — this is the primary goal:**
- Dead code: variables assigned but never read, unreachable branches, unused imports
- Redundant logic: conditions that are always true/false, duplicate checks across functions
- Over-abstraction: wrappers that add indirection without value, single-use helpers that could be inlined
- Verbose patterns: manual loops replaceable with builtins, explicit state machines replaceable with simpler control flow
- Copy-paste: similar blocks that could be a shared function or loop

**Simplify:**
- Complex conditionals that could be truth tables, early returns, or guard clauses
- Nested callbacks/promises that could flatten
- State that could be derived instead of tracked
- Mutable patterns where immutable would be simpler

**Robustness:**
- Error paths that silently swallow failures
- Type narrowing gaps (values assumed to exist without checks at boundaries)
- Race conditions in async code
- Resource cleanup (missing finally, unclosed handles)

Do NOT flag:
- Formatting, whitespace, import order (prettier/linter handles these)
- Naming preferences unless genuinely confusing
- "Could add a comment here" — if the code needs a comment, it needs simplifying

## Step 3: Present findings

Structure the output as:

### Overview
What this branch does in 1-2 sentences. Total files changed, lines added/removed.

### Refactoring opportunities

For each suggestion, show:
1. **Where**: file path and line range
2. **What**: the current code (brief excerpt)
3. **Why**: what's wrong or suboptimal
4. **How**: the simpler version, as a concrete code snippet — not a vague description
5. **LOC impact**: estimated lines saved

Order suggestions by impact (most lines saved first).

### Summary
Total potential LOC reduction across all suggestions. Note anything that looked suspicious but you weren't sure enough to flag.

After presenting, ask the user which suggestions (if any) they'd like applied.
