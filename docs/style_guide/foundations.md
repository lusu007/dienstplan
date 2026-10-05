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

- **App setup**: initialize `LiquidGlassWidgets` in `main.dart`; `AppGlassTheme` applies the package theme with `GlassQuality.standard` in both light and dark modes.
- **Shared rendering adapter**: `AppGlassSurface` uses library `GlassContainer` for refractive surfaces and `AdaptiveGlass.vibrancy` for passive cards or nested surfaces that avoid refraction.
- **Page backdrop**: `CalendarBackdrop` sets the ambient base.
- **Primary surfaces**: `GlassContainer`, `GlassCard`, `GlassDialogSurface`.
- **Modal shells**: `GlassBottomSheet`, `GlassDialogSurface`.
- **Interactive chips/badges**: glass-adjacent, but must use the same alpha/radius logic.

### Contrast And Readability

- Always verify text legibility over tinted/blurred backgrounds.
- Use `Theme.of(context).colorScheme.onSurface` for primary text on glass surfaces.
- Use `onSurfaceVariant` for secondary text and metadata.
- Avoid low-contrast white text on light tinted glass unless tested.

## Token Roles

Use the existing constants in [`glass_tokens.dart`](../../lib/core/constants/glass_tokens.dart). These are app defaults, not the library defaults:

### Radius

- `glassSurfaceRadiusSm`
- `glassSurfaceRadiusMd`
- `glassSurfaceRadiusLg`
- `glassSurfaceRadiusXl`

### Blur

- `glassSurfaceBlurDefault`: 20
- `glassSurfaceBlurDialog`: 28
- `glassSurfaceBlurBottomSheet`: 4
- `glassSurfaceBlurSubtle`: 18

Passive `GlassCard` surfaces use vibrancy rather than a separate backdrop blur per card. Preserve standard quality for refractive surfaces; do not switch the app to minimal quality as a blanket performance workaround.

### Alpha

- `glassTintAlphaLight`
- `glassTintAlphaDark`
- `glassBorderAlphaLight`
- `glassBorderAlphaDark`
- `glassBarrierAlpha`: 0.35 for all Light bottom sheets (including implicit Material routes and the live theme picker); preserve existing Dark route values.

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
- Use `AppTypography` for shared menu, secondary, page-title and sheet-title roles in both Light and Dark.
- Page titles: 22/700; sheet/step titles: 24/700; menu/selection titles: 17/700; supporting card text: 14; form/instruction text: 16; helper text: 12.
- Standard action labels: 16/700 (`AppTypography.actionSize`); compact segmented export actions retain 14/600. Do not add per-screen large-button font overrides without a clear role.
- Compound selection Widget titles inherit the shared menu-title style; explicit authority captions remain secondary.
- Headings and holiday rows grow with system fonts; do not impose fixed text heights or shrink text to fit.
- Keep glass headings visually consistent (weight/size/letter spacing).
- Do not introduce per-screen ad-hoc typography unless unavoidable.

## Anti-Patterns

- Repeating local alpha tuples in multiple files.
- Re-implementing blur + border + tint recipes in feature widgets.
- Mixing legacy `Card`/`Dialog` surfaces with glass shells on the same screen.
- Hardcoding spacing and radius values when equivalent token roles exist.
