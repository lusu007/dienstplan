# Glass Design Consistency Audit

This audit checks consistency against the current glass design source of truth:
- `lib/presentation/widgets/common/glass_container.dart`
- `lib/presentation/widgets/common/glass_card.dart`
- `lib/presentation/widgets/common/glass_dialog_surface.dart`
- `lib/presentation/widgets/common/glass_bottom_sheet.dart`
- `lib/presentation/widgets/common/glass_screen_scaffold.dart`

Classification:
- **Compliant**: uses shared glass primitives directly.
- **Partially compliant**: uses shared shell but still contains custom/legacy inner surfaces.
- **Non-compliant**: mostly custom or legacy surfaces where glass primitives should be used.

## 1) File Inventory And Classification

### Core Glass System (Reference)
- **Compliant**
  - `lib/presentation/widgets/common/glass_container.dart`
  - `lib/presentation/widgets/common/glass_card.dart`
  - `lib/presentation/widgets/common/glass_dialog_surface.dart`
  - `lib/presentation/widgets/common/glass_bottom_sheet.dart`
  - `lib/presentation/widgets/common/glass_screen_scaffold.dart`
  - `lib/presentation/widgets/common/glass_icon_badge.dart`

### App Screens
- **Compliant**
  - `lib/presentation/screens/settings_screen.dart` (uses `GlassScreenScaffold`, section cards)
  - `lib/presentation/screens/about_screen.dart` (uses `GlassScreenScaffold`, `NavigationCard`)
- **Partially compliant**
  - `lib/presentation/screens/setup_screen.dart` (uses `CalendarBackdrop` and glass-like controls, but several local style constants and direct `Colors.white` alpha recipes)
- **Non-compliant**
  - `lib/presentation/screens/debug_screen.dart` (uses legacy `Card`, `Dialog`, and non-glass content panes under glass shell)

### Calendar Module
- **Compliant**
  - `lib/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart` (backdrop + glass action bar + glass bottom sheet flow)
  - `lib/presentation/widgets/screens/calendar/components/glass_action_bar.dart`
  - `lib/presentation/widgets/screens/calendar/components/schedules_bottom_sheet.dart` (glass sheet shell)
- **Partially compliant**
  - `lib/presentation/widgets/screens/calendar/date_selector/calendar_date_selector.dart` (uses `GlassDialogSurface` in modal, but also many local glass recipes and manual `BackdropFilter`)
  - `lib/presentation/widgets/screens/calendar/calendar_view/day_schedules_list_panel.dart` (custom inner surfaces)
  - `lib/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart`
  - `lib/presentation/widgets/screens/calendar/duty_list/vacation_day_item.dart`
  - `lib/presentation/widgets/screens/calendar/duty_list/duty_item_ui_builder.dart`

### Settings Module
- **Compliant**
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart` (wraps `GlassBottomSheet`)
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/calendar_export_bottomsheet.dart`
  - `lib/presentation/widgets/common/cards/navigation_card.dart`
  - `lib/presentation/widgets/common/cards/selection_card.dart`
- **Partially compliant**
  - `lib/presentation/widgets/screens/settings/components/dialogs/app_license_page.dart` (glass shell, custom repeated glass card recipe)
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/language_bottomsheet.dart` (custom loading/error container with non-glass shape)
  - `lib/presentation/widgets/screens/settings/sections/app_section.dart` (uses direct `Colors.*` semantic indicators)

### Setup Module
- **Compliant**
  - `lib/presentation/widgets/screens/setup/components/skeleton_card.dart` (`GlassCard`)
- **Partially compliant**
  - `lib/presentation/widgets/screens/setup/action_button.dart` (primary path uses `GlassContainer`, secondary path uses custom style recipe)
  - `lib/presentation/widgets/screens/setup/setup_back_button.dart` (custom glass-like style not tokenized)
  - `lib/presentation/widgets/screens/setup/language_selector_button.dart` (custom glass-like style not tokenized)

## 2) Module Consistency Matrix

| Module | Shell/Scaffold | Cards/Surfaces | Dialogs/Sheets | Theme/Color Usage | Overall |
|---|---|---|---|---|---|
| Calendar | Good | Mixed | Good | Mixed | Partially compliant |
| Settings | Good | Mostly good | Mixed | Mixed | Partially compliant |
| Setup/About | Good | Mixed | Mixed | Mixed | Partially compliant |
| Debug | Mixed | Weak | Weak | Mixed | Non-compliant |

## 3) Prioritized Inconsistencies

### High Severity (user-visible drift, broad impact)
1. **Legacy surfaces in `debug_screen`**
   - `Card` and plain `Dialog` create a visual language break versus glass pages.
   - Affects a full screen with repeated sections.
2. **Calendar inner-component token drift**
   - `calendar_date_selector`, duty-list widgets, and day panel use repeated manual radii/blur/alpha/shadow values.
   - Core module with high interaction frequency.
3. **License page custom surface duplication**
   - `app_license_page` repeats custom card style instead of shared glass card variant.
   - Introduces maintenance and visual drift risk.

### Medium Severity (localized, recoverable)
1. **Settings language bottom sheet loading/error states**
   - Uses plain `Container` + `surface` instead of shared glass bottom sheet style.
2. **Setup controls with local recipes**
   - `ActionButton` secondary and setup control widgets rely on local border/alpha decisions.

### Low Severity (consistency polish)
1. **Direct semantic colors in settings icons**
   - `Colors.red`, `Colors.amber`, `Colors.indigo`, `Colors.grey` in `app_section`.
2. **Small repeated constants**
   - Radius set fragmentation (`14`, `16`, `18`, `22`, `28`, `32`) and repeated alpha pairs.

## 4) Remediation Order

### Phase 1 - Quick Wins (low risk, high consistency gain)
1. Migrate `debug_screen` section containers from `Card` to `GlassCard`.
2. Replace custom license entry/header containers in `app_license_page` with shared card component or dedicated glass list tile.
3. Update `language_bottomsheet` loading/error fallback to use `GlassBottomSheet` wrapper pattern.
4. Replace direct `Colors.*` semantic usage in `app_section` with `ColorScheme` roles.

### Phase 2 - Medium-Risk Consolidation
1. Refactor `calendar_date_selector` local glass controls into reusable picker subcomponents tied to glass tokens.
2. Standardize calendar duty-list inner surfaces (`duty_schedule_list`, `vacation_day_item`, `duty_item_ui_builder`) on shared surface primitives.
3. Align setup controls (`action_button`, `setup_back_button`, `language_selector_button`) with shared button/surface variants.

### Phase 3 - Deep Standardization
1. Introduce dedicated glass tokens for radii, blur, alpha, shadow, spacing.
2. Replace duplicated ambient-blob implementations with a single reusable primitive.
3. Add a lightweight design lint checklist for new widgets touching `BoxDecoration`/`BackdropFilter`.

## 5) Proposed Token Standard

Create centralized tokens under `lib/core/constants/` (or `lib/presentation/theme/`) and consume them from all glass widgets.

### Surface Tokens
- `glassSurfaceRadiusSm`, `glassSurfaceRadiusMd`, `glassSurfaceRadiusLg`, `glassSurfaceRadiusXl`
- `glassSurfaceBlurDefault`, `glassSurfaceBlurDialog`
- `glassTintAlphaLight`, `glassTintAlphaDark`
- `glassBorderAlphaLight`, `glassBorderAlphaDark`
- `glassShadowBlurSm`, `glassShadowBlurMd`, `glassShadowBlurLg`
- `glassShadowOffsetYSm`, `glassShadowOffsetYMd`

### Layout Tokens
- `glassSpacingXs`, `glassSpacingSm`, `glassSpacingMd`, `glassSpacingLg`, `glassSpacingXl`
- `glassInsetPageHorizontal`, `glassInsetSection`, `glassInsetCard`

### Interaction Tokens
- `glassPressedOpacity`
- `glassDisabledOpacity`
- `glassBarrierAlpha`

### Typography Role Tokens (glass-specific wrappers)
- `glassTitleStyle`
- `glassSectionTitleStyle`
- `glassActionLabelStyle`

## 6) Acceptance Criteria For Consistency

The design is considered consistent when:
1. New and existing surfaces in Calendar/Settings/Setup/Debug use shared glass primitives.
2. No screen-level custom glass recipes duplicate tokenized values.
3. Direct `Colors.*` usage is limited to truly semantic exceptions and explicitly documented.
4. Bottom sheets and dialogs share the same visual language and component stack.
5. Visual deltas between modules are intentional and traceable to tokens, not ad-hoc constants.
