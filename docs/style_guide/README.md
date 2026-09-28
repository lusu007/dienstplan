# App Design And Style Guide


This directory is the source of truth for visual and UI copy consistency.

Verified against the app implementation on 2026-09-28, using `liquid_glass_widgets` 1.7.2. Shared app adapters remain the entry point for feature widgets; not every page or sheet uses a library widget directly.

## Contents

- [Foundations](./foundations.md)
- [Components](./components.md)
- [Patterns](./patterns.md)
- [Content Style](./content_style.md)
- [Checklist](./checklist.md)

## How To Use

1. Start with `foundations.md` for visual intent and constraints.
2. Use `components.md` when implementing or refactoring widgets.
3. Use `patterns.md` for screen-level and interaction decisions.
4. Use `content_style.md` for labels, CTA text, and state messages.
5. Run `checklist.md` before opening or approving a PR.

## Scope

- Glass design language and shared surface behavior.
- Component reuse and anti-pattern avoidance.
- UI writing style for labels, actions, loading, error, and empty states.

## Related Documents

- [Glass Design Consistency Audit](../glass_design_consistency_audit.md) — historical migration inventory; its classifications are not a current backlog.
