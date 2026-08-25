---
name: simplify-code
description: Refactor code to remove accidental complexity while preserving behavior and public contracts. Use when writing, reviewing, or simplifying code with unnecessary indirection, reflection, type assertions, overloads, wrapper interfaces, fake initialization states, duplicated bookkeeping, oversized modules, or speculative abstractions.
---

# Simplify Code

Make behavior easier to see by deleting machinery that does not represent a real runtime requirement or variation point.

## Workflow

1. Establish the contract before editing.
   - Read the public signatures, owning documentation, callers, and tests.
   - Treat behavior changes and public API changes as separate work unless requested.
2. Find accidental complexity.
   - Trust static types for typed internal values; keep runtime validation at untyped boundaries such as I/O, wire data, parsed input, and external objects.
   - Replace `unknown` plus assertions with precise signatures or discriminated unions.
   - Remove unused fields, redundant parameters, pass-through helpers, duplicate bookkeeping, overloads, and interfaces that add no semantic distinction.
   - Replace fake initialization such as `null as never` with better construction order, honest nullable state, or lazy initialization.
   - Put a capability on the object that owns its state instead of threading adapter objects through internal calls.
3. Challenge every abstraction.
   - Keep an abstraction when it centralizes an invariant, hides substantial behavior, or serves proven variation.
   - Inline or delete it when it only renames a call, forwards arguments, or generalizes one use case.
   - Share code only when semantics match exactly. Prefer small duplication over a helper that erases meaningful differences.
4. Split large modules only at cohesive, one-way seams.
   - Give each extracted module a small interface and substantial implementation.
   - Keep related state transitions local.
   - Avoid type warehouses, callback plumbing, and cycles created solely to enable a split.
5. Implement in small passes, then reread the resulting code.
   - Prefer direct narrowed assignments and ordinary control flow over dynamic property helpers.
   - Make signatures describe actual behavior, including async results and callback arguments.
   - Do not optimize for line count at the expense of clarity or invariants.
6. Verify proportionally.
   - Run formatting, linting, type checks or builds, and focused tests.
   - Review concurrency, cancellation, cleanup, initialization order, and boundary validation after structural changes.
   - Inspect the final combined diff, not only the last edit.

## Common Transformations

- `null as never` fields → reorder construction or initialize lazily.
- `kind` plus `unknown` value → discriminated union.
- reflective property probing on typed objects → typed access or removal of the unsupported convention.
- string-keyed assignment helper plus cast → direct assignment inside an already narrowed branch.
- internal sink or adapter threaded through calls → method on the state owner.
- large mixed module → extract a cohesive phase with a small, one-way interface.
- nearly identical helpers with different edge semantics → keep them separate.

## Guardrails

- Preserve validation that protects real external boundaries.
- Preserve abstractions that own invariants or coordinate lifecycle state.
- Do not force two workflows behind one generic interface merely because their function names resemble each other.
- Do not silently widen scope into behavior changes, dependency changes, or public API redesign.
