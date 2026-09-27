# Checklist

## Design Consistency Checklist
Use this before merging UI changes.

## Visual
- [ ] Uses shared glass primitives where possible (`GlassContainer`, `GlassCard`, `GlassDialogSurface`, `GlassBottomSheet`, `GlassScreenScaffold`).
- [ ] Avoids duplicating local blur/tint/border/shadow recipes.
- [ ] Uses semantic `ColorScheme` values instead of direct `Colors.*` unless justified.
- [ ] Applies consistent radius and spacing scale.
- [ ] Maintains readable contrast on translucent surfaces.

## Components
- [ ] New component extends existing shared primitives or introduces a reusable common primitive.
- [ ] No legacy `Card`/plain `Dialog` introduced in glass-first screens without rationale.
- [ ] Loading, error, and empty states stay visually aligned with main state container.

## Interaction
- [ ] Tap, active, focus, and disabled states are visible and consistent.
- [ ] Modal and sheet interactions follow existing behavior patterns.
- [ ] Sticky actions and bottom bars keep consistent visual hierarchy.

## Content
- [ ] Labels are explicit and consistent with existing terminology.
- [ ] CTA text uses clear verbs and reflects real action.
- [ ] Error messages are specific, contextual, and recovery-oriented.
- [ ] Empty states explain what happened and what user can do next.
- [ ] Copy tone is neutral and professional.

## Review Gate
- [ ] Checked against `docs/style_guide/foundations.md`.
- [ ] Checked against `docs/style_guide/components.md`.
- [ ] Checked against `docs/style_guide/patterns.md`.
- [ ] Checked against `docs/style_guide/content_style.md`.
- [ ] If UI drift is intentional, rationale is documented in the PR.
