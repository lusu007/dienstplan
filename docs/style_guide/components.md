# Components

## Component Standards
This document defines when and how to use shared glass components.

## Shared Primitives

### `GlassContainer`
Use for reusable frosted surfaces that need blur + tint + border in one primitive.

Use when:
- Building call-to-action bars and prominent interactive surfaces.
- A widget needs blur behavior that should match existing glass surfaces.

Do not:
- Copy the same `BackdropFilter` recipe into feature widgets.
- Override every default value without reason.

### `GlassCard`
Use for list cards, setting tiles, and selection surfaces.

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
- You need stronger blur and layered borders for modal depth.

Do not:
- Wrap it inside another custom glass container with duplicated blur/border logic.

### `GlassBottomSheet`
Use as the default shell for bottom sheets.

Use when:
- Presenting selection, settings, or informational sheets.
- You need consistent handle, header, and sheet paddings.

Do not:
- Build loading/error sheet states with plain `Container` if the main state uses `GlassBottomSheet`.

### `GlassScreenScaffold`
Use for full-screen layouts that should follow the glass shell standard.

Use when:
- Building top-level app screens with shared glass header/back behavior.

Do not:
- Mix unrelated legacy surfaces throughout the same screen.

## Current Inconsistency Hotspots
Based on the consistency audit:
- `lib/presentation/screens/debug_screen.dart`
- `lib/presentation/widgets/screens/calendar/date_selector/calendar_date_selector.dart`
- `lib/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart`
- `lib/presentation/widgets/screens/calendar/calendar_view/day_schedules_list_panel.dart`
- `lib/presentation/widgets/screens/settings/components/dialogs/app_license_page.dart`

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
