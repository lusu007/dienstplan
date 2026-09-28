# Components


## Component Standards

This document defines when and how to use shared glass components.

## Shared Primitives


### `AppGlassTheme` and `AppGlassSurface`

`AppGlassTheme` owns library theming. `AppGlassSurface` bridges existing app components to the library and preserves semantic tints using `GlassBodyMode.clear`. Feature code should normally use the higher-level adapters below. Avoid adding independent package layers around every row or control.

### `GlassContainer`

Use the app adapter for reusable surfaces backed by `AppGlassSurface`, with shared tint, blur, and border defaults.

Use when:

- Building call-to-action bars and prominent interactive surfaces.
- A widget needs blur behavior that should match existing glass surfaces.

Do not:

- Copy the same `BackdropFilter` recipe into feature widgets.
- Override every default value without reason.

### `GlassCard`

Use for list cards, setting tiles, and selection surfaces. Cards use non-refractive vibrancy. Their own foreground outline is normally 1 logical pixel wide with a translucent white color; active and custom-color variants use the existing card parameters.

For passive surfaces with this app-defined outline, `AppGlassSurface` disables the library specular rim (`lightIntensity: 0`). This avoids the extra rim changing contrast during Android scroll stretch while keeping the app outline and stretch behavior.

Use `GlassCardGroup` (also in `glass_card.dart`) for related settings rows: one outer surface and dividers. Normal rows remain transparent; active rows and custom tints/borders use lightweight per-row decoration without another glass layer. Disabled custom emphasis uses the existing disabled alpha multiplier; navigation rows retain their own disabled text/icon styling. Set `modalTrigger: true` on `GlassCard` or `NavigationCard` when it opens a modal; this suppresses the background ink splash/highlight while retaining the tap handler.

Use when:

- The element is card-like and participates in selection/active states.
- A surface should visually align with settings cards.

Do not:

- Replace with plain `Card` on glass screens.
- Re-implement borders/shadows for card-like UI in feature modules.

### `GlassDialogSurface`

Use as root container for glass dialogs and modal content.

Use when:

- Building custom dialogs, picker dialogs, or sheet-like modal cards.
- You need the shared modal tint and dialog blur (28 by default; sheets pass their separate blur token).

Do not:

- Wrap it inside another custom glass container with duplicated blur/border logic.

### `GlassBottomSheet`

Use as the default shell for bottom sheets.

Use when:

- Presenting selection, settings, or informational sheets.
- You need consistent handle, header, and sheet paddings.

Do not:

- Build loading/error sheet states with plain `Container` if the main state uses `GlassBottomSheet`.
- Remove the slide animation to hide rendering cost.

The theme picker is an explicit exception: `ThemeModeBottomsheet` uses library `GlassSheet.show()` with standard quality and the app sheet blur token. Let the library provide its shell, handle, and animation; do not nest `GlassBottomSheet` inside it. Resolve content colors from the current theme and avoid freezing a tint when the picker can change that theme.

### `GlassScreenScaffold`

Use for full-screen layouts that should follow the glass shell standard.

Use when:

- Building top-level app screens with shared glass header/back behavior.

Do not:

- Mix unrelated legacy surfaces throughout the same screen.
- Enable `fadeScrollEdges` on settings pages: the viewport-wide mask previously hid glass group text on Android/Impeller. It remains off by default.

This is the app’s custom scaffold and header, not the package `GlassScaffold`.

## Existing Adoption Examples

- Settings: `SettingsScreen`, `SettingsCategoryScreen`, `SettingsSection`, and `GlassCardGroup`.
- Calendar: `GlassActionBar`, `GlassPickerTile`, `GlassPickerIconButton`, and `GlassIconToggleChip`.
- Debug and licenses: `debug_screen.dart` and `app_license_page.dart` already use shared glass primitives. Do not treat the historical audit as a list of unmigrated screens.

## Migration Rules


### Rule 1: Replace Legacy Surfaces First

- Migrate plain `Card` and plain `Dialog` usage on glass screens to shared glass primitives.

### Rule 2: Consolidate Repeated Recipes

- If 2 or more widgets use same local alpha/radius/shadow values, move to a shared component or token.

### Rule 3: Keep One Source Of Visual Truth

- If a pattern already exists in `common/`, use it.
- If it does not exist, create a shared primitive first, then adopt it in feature widgets.

### Rule 4: Preserve Behavior While Standardizing

- Refactor presentation only; avoid functional side effects.
- Validate tap states, focus states, and disabled states after migration.

## Review Checklist For Component PRs

- Is a shared primitive used where appropriate?
- Are hardcoded colors avoided in reusable UI?
- Are radii/blur/alpha values tokenized or justified?
- Does the component match existing modal/card/header language?
