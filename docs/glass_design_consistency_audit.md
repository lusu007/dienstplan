# Glass Design Consistency Audit

This audit checks consistency against the current glass design source of truth:
- `lib/presentation/widgets/common/glass_container.dart`
- `lib/presentation/widgets/common/glass_card.dart`
- `lib/presentation/widgets/common/glass_dialog_surface.dart`
- `lib/presentation/widgets/common/glass_bottom_sheet.dart`
- `lib/presentation/widgets/common/glass_screen_scaffold.dart`
- `lib/presentation/widgets/common/glass_app_dialog.dart`
- `lib/presentation/widgets/common/glass_button_surface.dart`
- `lib/presentation/widgets/common/glass_filter_chip.dart`
- `lib/presentation/widgets/common/glass_icon_badge.dart`

Token reference: [`lib/core/constants/glass_tokens.dart`](../lib/core/constants/glass_tokens.dart).

Classification:
- **Compliant**: uses shared glass primitives directly and only token-bound values.
- **Partially compliant**: uses shared shell but still contains custom/legacy inner surfaces or non-tokenised numbers.
- **Non-compliant**: mostly custom or legacy surfaces where glass primitives should be used.

## 1) File Inventory And Classification

### Core Glass System (Reference)
- **Compliant**
  - `lib/presentation/widgets/common/glass_container.dart` (defaults bound to `glassSurfaceSubtle*` tokens; `CalendarBackdrop` blob alphas tokenised)
  - `lib/presentation/widgets/common/glass_card.dart` (active/disabled multipliers tokenised)
  - `lib/presentation/widgets/common/glass_dialog_surface.dart` (tints, borders, dialog shadow alpha, divider alpha tokenised)
  - `lib/presentation/widgets/common/glass_bottom_sheet.dart` (drag-handle dimensions and alpha tokenised)
  - `lib/presentation/widgets/common/glass_screen_scaffold.dart` (theme typography for title; `Semantics` label on glass back button)
  - `lib/presentation/widgets/common/glass_app_dialog.dart` (barrier alpha, blur, paddings tokenised)
  - `lib/presentation/widgets/common/glass_icon_badge.dart` (gradient/border/shadow alphas tokenised)
  - `lib/presentation/widgets/common/glass_filter_chip.dart` (theme `labelLarge` for chip label)

### App Screens
- **Compliant**
  - `lib/presentation/screens/settings_screen.dart` (uses `GlassScreenScaffold`, tokenised paddings, error block has retry CTA)
  - `lib/presentation/screens/about_screen.dart` (uses `GlassScreenScaffold`, `NavigationCard`)
  - `lib/presentation/screens/setup_screen.dart` (localised failure path with retry, theme-aware step indicator, tokenised paddings, theme typography for title)
  - `lib/presentation/screens/app_initializer_widget.dart` (failure path now wrapped in `CalendarBackdrop` and uses `tryAgain` key)
- **Partially compliant**
  - `lib/presentation/screens/debug_screen.dart` (now uses `GlassDialogSurface` for the JSON viewer, tokenised paddings/radii; English-only strings remain since the screen is dev-only and accessed via the 7-tap easter egg)

### Calendar Module
- **Compliant**
  - `lib/presentation/widgets/screens/calendar/calendar_view/calendar_view.dart`
  - `lib/presentation/widgets/screens/calendar/components/glass_action_bar.dart` (token-bound paddings, theme typography for the quick field, no more `Colors.white` literals)
  - `lib/presentation/widgets/screens/calendar/components/schedules_bottom_sheet.dart` (today pill uses `colorScheme.onPrimary`, barrier alpha and radii tokenised)
  - `lib/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart` (delete now goes through a `GlassAppDialog` confirmation; barrier alpha tokenised)
  - `lib/presentation/widgets/screens/calendar/components/calendar_header.dart` (theme typography, tokenised spacing)
- **Partially compliant**
  - `lib/presentation/widgets/screens/calendar/date_selector/calendar_date_selector.dart` (radius now `glassSurfaceRadiusXl`, drag handle uses tokens, but the picker still uses a manual `showModalBottomSheet` instead of `GlassBottomSheet`)
  - `lib/presentation/widgets/screens/calendar/calendar_view/day_schedules_list_panel.dart` (header padding still uses `20`/`8` literals)
  - `lib/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart` (glass tints/borders now reference tokens; non-glass card path keeps a local recipe by design for the `card` visual style)
  - `lib/presentation/widgets/screens/calendar/duty_list/vacation_day_item.dart` (token-bound tints; non-glass branch keeps the same legacy recipe as the duty list)
  - `lib/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart` (badge text uses contrast-aware foreground via `calendarDayBadgeForegroundColor`; outside-day fill via `calendarDayBadgeOutsideFillColor`)

### Settings Module
- **Compliant**
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart`
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/duty_schedule_bottomsheet.dart` (empty state now wrapped in `GlassBottomSheet`)
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/partner_config_bottomsheet.dart` (empty state now `GlassBottomSheet`)
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/my_duty_group_bottomsheet.dart` (empty state now `GlassBottomSheet` with `selectMyDutyScheduleFirst`)
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/partner_group_bottomsheet.dart` (empty state now `GlassBottomSheet` with `selectPartnerDutyScheduleFirst`)
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/calendar_export_bottomsheet.dart` (uses `Theme.of(context).colorScheme.primary`)
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/reset_bottomsheet.dart` (uses `colorScheme.errorContainer`/`error`/`onError`)
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/color_selection_card.dart` (radius/spacing/shadow tokenised)
  - `lib/presentation/widgets/screens/settings/components/dialogs/app_license_page.dart` (default `GlassCard` radius, tokenised paddings)
  - `lib/presentation/widgets/screens/settings/components/dialogs/app_dialog.dart` (theme typography for close button)
  - `lib/presentation/widgets/screens/settings/sections/app_section.dart` (icon uses `colorScheme.error`)
  - `lib/presentation/widgets/screens/settings/sections/privacy_section.dart` (error branch shows distinct `NavigationCard` with retry)
  - `lib/presentation/widgets/screens/settings/sections/footer_section.dart` (theme `bodySmall`, `Semantics` wrapper for the hidden 7-tap target)
- **Partially compliant**
  - `lib/presentation/widgets/screens/settings/components/bottomsheets/duty_group_selection_bottomsheet.dart` (empty hint colour now `onSurfaceVariant`; remaining padding literals kept)

### Setup Module
- **Compliant**
  - `lib/presentation/widgets/screens/setup/steps/config_selection_step_component.dart` (empty state with filter-aware CTA)
  - `lib/presentation/widgets/screens/setup/steps/partner_config_step_component.dart` (empty state)
  - `lib/presentation/widgets/screens/setup/steps/duty_group_step_component.dart` (empty state)
  - `lib/presentation/widgets/screens/setup/steps/partner_duty_group_step_component.dart` (empty state)
  - `lib/presentation/widgets/screens/setup/components/config_card.dart` (uses `colorScheme.primary`, theme `labelSmall` for police authority)
  - `lib/presentation/widgets/screens/setup/components/duty_group_card.dart` (uses `colorScheme.primary`)
  - `lib/presentation/widgets/screens/setup/steps/theme_step_component.dart` (uses `colorScheme.primary`)
  - `lib/presentation/widgets/screens/setup/components/skeleton_card.dart`
  - `lib/presentation/widgets/screens/setup/language_selector_button.dart` (theme `labelLarge`, `glassSurfaceRadiusPill`, tokenised padding)
- **Partially compliant**
  - `lib/presentation/widgets/screens/setup/action_button.dart` (shared glass surface, keeps a documented secondary recipe)
  - `lib/presentation/widgets/screens/setup/setup_back_button.dart` (custom shape kept for back-button affordance)

## 2) Module Consistency Matrix

| Module | Shell/Scaffold | Cards/Surfaces | Dialogs/Sheets | Theme/Color Usage | Overall |
|---|---|---|---|---|---|
| Calendar | Good | Mostly good | Good | Good | Compliant |
| Settings | Good | Good | Good | Good | Compliant |
| Setup/About | Good | Good | Good | Good | Compliant |
| Debug | Good | Good | Good | Mixed (English-only copy by design) | Partially compliant |

## 3) Fixed In This Iteration

### High severity
- Centralised glass primitives now derive their alphas, radii, blur and shadow values from tokens in `glass_tokens.dart` (`glassSurfaceSubtleTint*`, `glassDialogTintAlpha*`, `glassDialogOuter/InnerBorderAlpha*`, `glassDividerAlpha*`, `glassDragHandle*`, `glassIconBadge*`, `glassCardActive*`, `glassBackdropBlob*`).
- Removed `Colors.white`-based ad-hoc tints from the calendar action bar, today pill, schedules sheet, date selector handle, animated calendar day badges, duty list, and vacation list.
- Migrated the four settings bottomsheets that previously fell back to a plain `Container` + grey handle to `GlassBottomSheet` and added explanatory copy referencing existing `selectMy/PartnerDutyScheduleFirst` keys.
- Personal calendar entry deletion now requires an explicit `GlassAppDialog` confirmation with localised `deletePersonalEntryConfirmation*` strings.
- Setup-load failure path no longer leaks raw `error.toString()`; both the setup loader and the language loader expose localised text and a real `tryAgain` retry action; `app_initializer` failure renders inside `CalendarBackdrop` and re-uses the same key.
- Settings schedule error block and `PrivacySection` error branch now expose retry / try-again actions.

### Medium severity
- Replaced `Colors.red`/`Colors.white` on the reset confirmation with `colorScheme.error`, `errorContainer`, `onError`, `onErrorContainer`.
- Replaced `Colors.grey[300/600]` with `onSurfaceVariant` and tokenised tints across the duty-group selection sheet.
- Replaced `AppColors.primary` brand-token usages in `config_card`, `duty_group_card`, `theme_step_component`, `config_selection_bottomsheet`, `duty_group_selection_bottomsheet`, and `calendar_export_bottomsheet` with `Theme.of(context).colorScheme.primary` so the dynamic accent stays consistent.
- Hardened typography drift: `calendar_header`, `glass_screen_scaffold`, `setup_screen`, `glass_filter_chip`, `glass_action_bar`, `language_selector_button`, `footer_section`, `config_card`, `config_selection_bottomsheet`, `app_dialog`, `duty_item_ui_builder`, `police_authority_filter_chips` now read from `textTheme` instead of literal `fontSize` values.
- `step_indicator` defaults `inactiveColor` to `colorScheme.outlineVariant` (was `Colors.grey.shade300`).
- `app.dart` now updates `SystemUiOverlayStyle` per resolved theme so the status/navigation bar icons stay readable in dark mode.
- `app_license_page` now relies on the default `GlassCard` radius and uses `glassSpacing*` paddings.
- `ErrorDisplay` default retry label now uses the new `tryAgain` localisation key (en: `Try again`, de: `Erneut versuchen`) instead of the ambiguous `continueButton` (`Continue`).
- ARB: `exportCalendarButton` is now `Export` / `Exportieren` and no longer collides semantically with `continueButton`. `dutySchedule` is documented as the deprecated alias of `myDutySchedule`.
- `glass_screen_scaffold` glass back button is now wrapped in `Semantics(button: true, label: l10n.back)`.
- Footer easter-egg target now hits `behavior: HitTestBehavior.opaque` and is scoped with `Semantics`/`ExcludeSemantics`.

## 4) Remaining Polish (Low Severity)

- `calendar_date_selector` still opens its picker via `showModalBottomSheet` with a manual `GlassDialogSurface` rather than `GlassBottomSheet`. Migration is non-trivial because the picker needs an embedded `PageView`; left for a focused refactor.
- `duty_schedule_list` non-glass `card` visual style keeps a local `Container + Material + InkWell + BoxDecoration` recipe; this is the legacy pre-glass surface that is intentionally retained as a fallback for screens that opt out of glass.
- Duty list `_DutyListItemMetrics` still scales `fontSize` at runtime to balance compact/normal layouts; values are encapsulated in metric classes rather than token-named.
- Several other bottomsheets (`language_bottomsheet`, `theme_mode_bottomsheet`, `german_state_bottomsheet`, `holiday_color_bottomsheet`, `my_accent_color_bottomsheet`, `partner_color_bottomsheet`) call `showModalBottomSheet` directly. They still render `GenericBottomsheet` content but do not get the centralised barrier/clip behaviour from `GenericBottomsheet.show`.
- ARB keys `dutySchedule` and `exportCalendarButton` remain in the file for backwards-compatibility. They can be removed in a future cleanup pass.
- Debug screen copy is still English-only by design (developer-only flow accessed via the 7-tap easter egg). Consider gating it behind `kDebugMode` if it should be removed from release builds.

## 5) Token Surface (Current)

The following token roles are now in `glass_tokens.dart` and are the single source of truth for derived widgets:

- Radius: `glassSurfaceRadiusSm/Md/Lg/Xl`, `glassSurfaceRadiusPill`.
- Blur: `glassSurfaceBlurDefault`, `glassSurfaceBlurDialog`, `glassSurfaceBlurSubtle`.
- Tint / border alpha: `glassTintAlphaLight/Dark`, `glassBorderAlphaLight/Dark`, `glassTintAlphaActiveLight/Dark`, `glassBorderAlphaActive`, `glassBarrierAlpha`.
- Subtle surface: `glassSurfaceSubtleTintAlphaLight/Dark`, `glassSurfaceSubtleBorderAlphaLight/Dark`.
- Backdrop blobs: `glassBackdropGradientTopAlpha*`, `glassBackdropBlobLargeAlpha*`, `glassBackdropBlobMediumAlpha*`, `glassBackdropBlobSoftAlpha*`.
- Dialog surface: `glassDialogTintAlpha*`, `glassDialogOuter/InnerBorderAlpha*`.
- Drag handle: `glassDragHandleWidth`, `glassDragHandleHeight`, `glassDragHandleTopGap`, `glassDragHandleAlpha*`.
- Icon badge: `glassIconBadge{Shadow,Gradient,Border}Alpha*`, `glassIconBadgeShadowBlur`, `glassIconBadgeShadowOffsetY`.
- Glass card: `glassCardActiveTintAlpha*`, `glassCardActiveBorderAlpha`, `glassCardActiveBorderWidth`, `glassCardBaseTintAlphaDarkMultiplier`, `glassCardBaseBorderAlphaDarkMultiplier`, `glassCardDisabledMultiplier`.
- Shadow: `glassShadowBlurSm/Md/Lg`, `glassShadowOffsetYSm/Md`, `glassShadowAlpha{Light,Dark,DialogLight,DialogDark,ActiveLight,ActiveDark}`.
- Divider: `glassDividerAlphaLight/Dark`.
- Spacing: `glassSpacingXs/Sm/Md/Lg/Xl/Xxl`.

## 6) Acceptance Criteria For Consistency

The design is considered consistent when:
1. New and existing surfaces in Calendar/Settings/Setup/Debug use shared glass primitives.
2. No screen-level custom glass recipes duplicate tokenised values.
3. Direct `Colors.*` usage is limited to truly semantic exceptions and explicitly documented (the duty-list non-glass card recipe is the only remaining intentional case).
4. Bottom sheets and dialogs share the same visual language and component stack (the four empty-state sheets now do).
5. Visual deltas between modules are intentional and traceable to tokens, not ad-hoc constants.
6. Destructive actions (reset, delete personal entry) have explicit confirmation with semantic copy and `error`-themed CTA.
7. Async failures expose a localised retry action that uses the dedicated `tryAgain` key.
