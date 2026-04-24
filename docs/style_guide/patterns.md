# Patterns

## Purpose
Define repeatable page and interaction patterns so users get a consistent experience across modules.

## Screen Patterns

### Standard Screen Shell
Use:
- `GlassScreenScaffold` for screen frame and header.
- Shared spacing rhythm across sections.
- Shared glass cards for grouped content.

Avoid:
- Introducing custom top bars on one module without design rationale.
- Mixing old Material containers with glass surfaces in the same flow.

## Modal Patterns

### Bottom Sheets
Use:
- `GlassBottomSheet` (directly or via a thin wrapper like `GenericBottomsheet`).
- Consistent handle, title treatment, and body spacing.

Avoid:
- Plain surface fallback states that visually diverge from the normal sheet state.

### Dialogs
Use:
- `GlassDialogSurface` as root visual wrapper.
- Shared title/body/action structure.

Avoid:
- Nested custom blur wrappers that duplicate dialog styling.

## List And Card Patterns
Use:
- `GlassCard` for settings rows, option groups, and selectable items.
- Active states through existing card options (`isActive`, `enabled`).

Avoid:
- Local `Container + BoxDecoration` recipes for card-like rows.

## State Patterns

### Loading
Use:
- Keep loading inside the same visual container style as loaded state.
- Prefer skeletons or progress indicators that do not shift visual language.

### Error
Use:
- Clear, neutral, actionable messages.
- Error visuals aligned with same card/sheet shell as success state.

Avoid:
- Generic or ambiguous error text.

### Empty State
Use:
- Explain why no content is shown.
- Add next action where possible.

Avoid:
- Empty states with no context.

## Interaction Patterns
- Tap targets should be clearly visible on translucent backgrounds.
- Disabled states must remain readable, not only faded.
- Active and focus states should use consistent visual emphasis.

## Module Alignment Notes
- **Calendar**: prioritize harmonizing inner custom glass recipes with shared surfaces.
- **Settings**: keep all bottom sheet variants aligned via shared shell.
- **Setup/About**: keep decorative variants, but preserve token consistency.
- **Debug**: migrate legacy surface language to glass primitives for parity.
