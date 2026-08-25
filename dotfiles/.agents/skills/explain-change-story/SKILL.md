---
name: explain-change-story
description: Explain a code change as a concrete before-and-after failure story. Use when the user asks for a story explanation, what can go wrong, how a PR fixes it, why a change is needed, a concrete example, or a non-abstract walkthrough of a bug, refactor, or architectural seam.
---

# Explain Change Story

Explain the change through one realistic scenario that makes the failure and fix easy to visualize.

## Ground the Story

Inspect the relevant diff, callers, types, and tests when they are available. Identify:

- the exact behavior before the change;
- the assumption that stops being valid;
- the concrete failure or incorrect outcome;
- the new input, invariant, or seam that corrects it;
- anything the change deliberately does not solve.

Do not invent behavior that the code does not support. State an assumption when the source is unavailable.

## Use This Structure

### What can go wrong before

Set up one concrete example with memorable names and values, such as repositories, PR numbers, branches, projects, IDs, requests, or records. Walk through the execution in order:

1. State what initiates the operation.
2. Show which values the old code reads or derives.
3. Identify where those values become incorrect.
4. Name the observable result: the exact error, wrong mutation, missing output, duplicate, orphan, or silent inconsistency.

### How this fixes it

Replay the same example after the change:

1. Show the new values or explicit input.
2. Map them to the relevant function or operation.
3. State the corrected observable result.
4. Explain how legacy behavior is preserved when relevant.

### What this does not change

Include this section when the change is preparatory, intentionally narrow, or one part of a larger sequence. Clearly separate what is safe now from what a future change still needs to implement.

## Specificity Rules

- Name actual functions and fields when they clarify the failure.
- Use realistic sample values: `acme/web`, PR `#42`, installation `111`, branch `main`.
- Distinguish source from destination, persisted from derived, and repository-local identifiers from global identifiers.
- Prefer a causal sequence over a list of modified files.
- Say `GitHub returns 422 because the head branch does not exist in that repository`, not `publication may fail`.
- Explain the user-visible or system-visible consequence after the technical failure.
- Do not claim the PR solves adjacent work that remains unimplemented.
- Keep the story compact enough to read without knowing the codebase.

## Quality Check

Before answering, verify that a reader can answer all four questions:

1. What exact situation triggers the problem?
2. What exact value or assumption is wrong?
3. What exact bad outcome follows?
4. What exact part of the change prevents it?

If any answer is vague, make the scenario more concrete.
