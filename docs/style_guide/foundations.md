# Foundations

## Purpose
This guide defines the visual foundation for the app's glass design language. Use it as the baseline for all screens, widgets, dialogs, and sheets.

## Core Principles
- Design for clarity first, decoration second.
- Reuse shared glass primitives before writing custom decoration code.
- Keep visual depth subtle and consistent.
- Prefer semantic theme colors over hardcoded `Colors.*`.
- Keep component spacing and corner radii predictable.

## Visual Language

### Glass Surface Hierarchy
- **Page backdrop**: `CalendarBackdrop` sets the ambient base.
- **Primary surfaces**: `GlassContainer`, `GlassCard`, `GlassDialogSurface`.
- **Modal shells**: `GlassBottomSheet`, `GlassDialogSurface`.
- **Interactive chips/badges**: glass-adjacent, but must use the same alpha/radius logic.

### Contrast And Readability
- Always verify text legibility over tinted/blurred backgrounds.
- Use `Theme.of(context).colorScheme.onSurface` for primary text on glass surfaces.
- Use `onSurfaceVariant` for secondary text and metadata.
- Avoid low-contrast white text on light tinted glass unless tested.

## Token Roles (Recommended)
Use centralized tokens for shared values. Naming can follow this set:

### Radius
- `glassSurfaceRadiusSm`
- `glassSurfaceRadiusMd`
- `glassSurfaceRadiusLg`
- `glassSurfaceRadiusXl`

### Blur
- `glassSurfaceBlurDefault`
- `glassSurfaceBlurDialog`

### Alpha
- `glassTintAlphaLight`
- `glassTintAlphaDark`
- `glassBorderAlphaLight`
- `glassBorderAlphaDark`
- `glassBarrierAlpha`

### Shadow
- `glassShadowBlurSm`
- `glassShadowBlurMd`
- `glassShadowBlurLg`
- `glassShadowOffsetYSm`
- `glassShadowOffsetYMd`

### Spacing
- `glassSpacingXs`
- `glassSpacingSm`
- `glassSpacingMd`
- `glassSpacingLg`
- `glassSpacingXl`

## Color Rules
- Use `ColorScheme` roles for semantic intent (`primary`, `error`, `onSurface`, `outline`, etc.).
- Avoid direct semantic colors like `Colors.red`, `Colors.amber`, `Colors.indigo`, `Colors.grey` for persistent UI states unless explicitly documented.
- Only use direct colors in tightly scoped decorative contexts and document why.

## Typography Rules
- Use theme text styles as base (`titleMedium`, `bodyLarge`, `bodyMedium`, `bodySmall`).
- Keep glass headings visually consistent (weight/size/letter spacing).
- Do not introduce per-screen ad-hoc typography unless unavoidable.

## Anti-Patterns
- Repeating local alpha tuples in multiple files.
- Re-implementing blur + border + tint recipes in feature widgets.
- Mixing legacy `Card`/`Dialog` surfaces with glass shells on the same screen.
- Hardcoding spacing and radius values when equivalent token roles exist.
