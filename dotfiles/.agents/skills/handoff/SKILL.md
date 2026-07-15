---
name: handoff
description: Create a handoff document for a fresh agent or future session. Use when the user asks for a handoff, transfer note, continuation summary, compacted context, or instructions for another agent to pick up the current work.
---

# Handoff

Write a concise handoff document that lets a fresh agent continue the current work without rereading the whole conversation.

## Output Location

Save the handoff to the operating system temp directory, not the current workspace.

- Prefer `$TMPDIR` when set.
- Otherwise use `/tmp` on Unix-like systems.
- Use a descriptive filename such as `handoff-<topic>.md`.
- Report the final file path to the user.

## Content

Include:

- Current objective and why it matters.
- Relevant repository/workspace paths.
- Important decisions already made.
- Current git state and known uncommitted changes, if relevant.
- Work already completed.
- Remaining next steps.
- Verification already run and verification still needed.
- Blockers, risks, or assumptions.
- Suggested skills for the next agent to invoke.

If the user passes arguments, treat them as the intended focus for the next session and tailor the handoff around that work.

## Constraints

- Do not duplicate content already captured in artifacts such as PRDs, plans, ADRs, issues, commits, diffs, or generated files. Reference those by path, commit, PR, issue, or URL instead.
- Redact sensitive values, including API keys, tokens, passwords, secrets, private credentials, and personally identifiable information.
- Keep the document high-signal. Prefer concrete paths, commands, decisions, and next actions over broad narrative.
