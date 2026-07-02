---
name: code-design
description: Design or improve code structure around deep modules and testable interfaces. Use when the user asks about architecture, module boundaries, seams, public interfaces, testability, refactoring design, or making code easier for agents and humans to navigate.
---

# Code Design

Use this vocabulary when designing or restructuring code.

## Vocabulary

- **Module:** anything with an interface and implementation; a function, class, package, route, or larger slice.
- **Interface:** everything callers must know to use a module correctly, including types, invariants, ordering, errors, config, and performance behavior.
- **Implementation:** the code behind the interface.
- **Seam:** the place where behavior can vary without editing the caller.
- **Adapter:** a concrete implementation that satisfies an interface at a seam.
- **Depth:** how much behavior sits behind a small interface.
- **Locality:** how well related change stays in one place.
- **Leverage:** how much callers get from learning a small interface.

Prefer these words over overloaded alternatives such as component, boundary, service, or API when precision matters.

## Principles

- A deep module has a small interface and substantial useful behavior behind it.
- The interface is the natural test surface.
- If deleting a module makes complexity disappear, it was probably pass-through indirection.
- If deleting a module spreads complexity into callers, it was probably earning its keep.
- One adapter is often a hypothetical seam; two adapters usually prove the seam is real.
- Accept dependencies instead of constructing them deep inside business logic when testability matters.
- Return explicit results instead of hiding important behavior in side effects when possible.

## Design Review

When evaluating a design, ask:

- What is the public interface?
- Which facts must callers know?
- Can the interface be smaller?
- Can more behavior move behind the interface?
- Where should tests observe behavior?
- What changes together, and can it live together?
- Is this abstraction serving a real variation point?

Prefer concrete alternatives over vague advice. Show the smaller interface or module shape when recommending a design change.
