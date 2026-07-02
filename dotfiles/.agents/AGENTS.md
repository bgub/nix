## Local Notes

- Agent config files, skills, and AGENTS.md/CLAUDE.md files for Codex, Pi, Claude, and related agents are sourced from `~/.config/nix/dotfiles`. Edit the source files under that repo, not the symlinked/generated copies in `~/.codex`, `~/.pi`, `~/.claude`, or similar agent config directories.
- Do not push commits without asking first.
- Always use the GitHub CLI API (`gh api`) when possible for GitHub operations.
- If `pnpm`, `node`, or `npm` are missing, check the active `fnm` multishell bin path. In this setup it may look like `/Users/bgub/.local/state/fnm_multishells/<id>/bin`; prepend it to `PATH` for commands.
- Use conventional commit messages for commits.
- Always run lint/format before committing.
- Structure pull request descriptions with these sections:

```markdown
## TL;DR

## Code Changes

## Notes / Flags
```

## JavaScript and TypeScript

- Do not use default exports.
- Do not use barrel files.
- Do not use `useEffect`.

## gt Monorepo

- Branch names should start with `bg/`.
- `pnpm build` and `pnpm test` may fail or be impractical inside the sandbox. It is acceptable to ask the user to run them locally.
- In `/Users/bgub/gt/gt`, `enableGlobalVirtualStore: true` is paired with `hoist: false`.
- Treat missing module/type errors after install as real missing direct dependencies. Add the dependency to the package that imports or uses it, not to a sibling package or the root just to make hoisting work.
- Do not use `CI=true pnpm install` locally to bypass prompts; pnpm disables the global virtual store in CI mode. Use `pnpm install --force` instead.
