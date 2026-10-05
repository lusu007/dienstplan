# Typography, hierarchy and modal barriers audit

Date: 2026-10-02. Scope: current Flutter source for all presentation screens, shared widgets, settings menus/sheets, setup, calendar modes, entry editor, pickers, export, legal/license/about pages, feedback, update dialog and debug views. Cross-check: existing S22 Ultra screenshots from today's UI validation (including 1.3 text scaling and narrow-screen captures), plus fresh device checks of changed modal barriers. Earlier screenshots document typography still present in the current source; they are not fresh captures of every page. No blanket typography change was implemented as part of this audit.

Original audit constraint (subsequently amended by the user): Dark Mode keeps its existing appearance outside the previously approved button changes. Any future typography corrections described below should initially apply to Light Mode. The calendar's compact and large views remain distinct.

## Implemented: consistent Light barriers

Most explicit modal routes used `glassBarrierAlpha = 0.35`. Theme selection used the library's 54% black; own/partner/holiday color, federal state and calendar export used Flutter's implicit 54% black.

The Light `BottomSheetThemeData.modalBarrierColor` now supplies the shared 35% black to all implicit routes. Explicit 35% routes retain that value. The theme selection route resolves the barrier against the navigator's current brightness, so it becomes 35% in Light even when switched within the open sheet, and returns to the original library 54% in Dark. Dark theme defaults and other Dark routes remain unchanged.

Regression checks cover the Light default, unchanged Dark default, actual rendered Light modal barrier, Dark barrier and transitions within the same theme-selection route.

## Current hierarchy

Sizes are unscaled logical sp at the default Material 3 text scale. User font scaling still applies. These roles are observed in the current source, not a proposal to force every label to one size.

| Role | Current size/weight | Assessment |
| --- | --- | --- |
| Normal page title | `titleLarge`, 22 / 700 | Shared scaffold: settings, categories, about, feedback, legal and license pages. Setup header matches. |
| Sheet title / setup step title | `headlineSmall`, 24 / 700 | Consistent across generic sheets, theme sheet, entry editor and setup steps. |
| App identity on About | `headlineMedium`, 28 / 700 | Intentional identity block beneath the page title. |
| Settings section caption | `labelSmall`, 11 / 600, uppercase, tracking 1.3 | Clear secondary hierarchy; short labels. |
| Navigation, toggle and simple selection titles | 17 / 700 | Consistent shared cards, including their loading skeletons. |
| Card descriptions and selected values | 14 / normal | Consistent shared cards. |
| Picker trigger value | 17 / 700 | Consistent date/time/calendar month values. |
| Fields and explanatory introductory copy | `bodyLarge`, 16 | Appropriate for input and instructions. |
| Long legal text | `bodyMedium`, 14, line height 1.5 | Consistent privacy/disclaimer; intentionally denser than introductory copy. |
| Helper text, footer and metadata | `bodySmall`, 12 | Consistent supporting information. |
| Standard glass buttons | `labelLarge`, 14 / 700 | Shared adapter. Setup primary 18 and feedback submit 16 override this. |
| Filter chips | `labelLarge`, 14 / 700 | Distinct from large buttons; reasonable. |
| Color grid labels | `bodyMedium`, 14 / 500 or 700 when selected | Consistent within the grid; lower density than selection rows. |
| Compact / large duty title | 15 / 18 | Intentional calendar density distinction. Secondary 12 / 15. |
| Compact / large calendar day number | 13 / 16 | Intentional calendar density distinction. |
| Month-cell duty badge | 10 | Restricted cell space; detailed day list supplies readable full names. |
| Day detail header / time wheel | 28–32 / 24 | Numerical orientation and selection, not ordinary menu text. |
| Debug technical values | Theme body styles plus monospace | Intentional technical exception. |

Font family: no custom font assets or alternative UI families are declared. Regular UI inherits the app/Flutter platform text theme. Monospace is explicitly confined to debug technical values. Font-family mixing is not the main issue.

## Findings and recommended corrections

### 1. Compound duty-plan selection titles lose the shared title style

`ConfigCard._buildTitle()` and `_ConfigSelectionBottomsheetState._buildConfigTitle()` return a widget containing `Text(config.meta.name)` without a text style. `SelectionCard._buildTitle()` returns widget titles unchanged. Consequently these names inherit ambient Material body text instead of the explicit 17-sp/700 style used for string selection titles. The authority caption is explicitly styled, and the description has the shared 14-sp body style, so the primary name is the missing hierarchy layer.

Affected: own/partner duty-plan selection in setup and settings. Confirmed in `light-setup-step2-checked.png` and `light-schedule-checked.png`.

Recommendation: make Light compound names use the same 17-sp/700/onSurface role as simple selection titles; retain the small authority caption and 14-sp description. Use a shared typography role instead of repeating the numbers in the two feature builders. Preserve the existing Dark rendering.

### 2. Calendar export has a separate switch-label style

The local `_ToggleCard` uses a Material switch/list-tile label rather than the shared settings `ToggleCard` typography. Its primary label is consequently visually weaker than equivalent 17-sp/700 menu/toggle labels. The difference is visible in `light-export-checked.png`.

Recommendation: align its Light primary label to the menu-title role and retain 14-sp supporting copy. Keep disabled state, export behavior and Dark layout unchanged.

### 3. Vacation/holiday rows are much smaller than the adjacent duty list

`vacation_day_item.dart` defines compact title/description/chip as 13/10/8 and large as 14/11/9, versus adjacent duty rows 15/12 and 18/15. Fixed 40/44-dp row heights compound the problem when system fonts grow. The 8–9-sp chip text is the clearest readability risk. The month-grid's 10-sp badges are a separate constrained-space case and should not be enlarged indiscriminately.

Recommendation: bring Light holiday list text closer to the duty-list hierarchy (compact primary 15, supporting 12; large primary 17–18, supporting 14–15), make tiny chips at least 11–12 where feasible, and replace fixed row height with a minimum height/content-driven layout. Validate at 1.0/1.3 font scale and narrow width before choosing final sizes. Preserve compact-versus-large distinction and Dark rendering.

### 4. Button label sizes need an explicit role policy

Standard adapter labels are 14/700; setup primary defaults to 18; feedback submit explicitly uses 16; export actions use 14/600. These differences can be deliberate, but are currently local overrides rather than documented roles.

Recommendation: document normal action versus prominent primary action; use one shared size for each role. Do not blindly change every button to 18. This should be assessed alongside button height and wrapping; the current shared adapter already supports multiline labels and scaling.

### 5. Long page titles are limited to one line

The shared header uses a fixed 56-dp height, `height: 1.0` and ellipsis. Long titles such as the privacy page have less room when font scaling grows. This is a layout constraint, not a font-family inconsistency.

Recommendation: allow the Light header to grow/wrap for long titles at increased font scale, keeping short titles in the current compact layout. Check back-button alignment and ensure no calendar/header movement in Dark.

### 6. Supporting text has several line-height treatments

Feedback intro uses 16-sp/1.35; legal pages use 14-sp/1.5; normal cards inherit the text-theme body line height. Different long-text versus short-card treatments are appropriate. The style guide currently only says to use theme styles, leaving these role choices undocumented.

Recommendation: name and document short description, instruction paragraph and long reading-text roles. Preserve readable legal text rather than forcing it into the compact card description style.

## Proposed Light typography contract

Keep the existing font family and established sizes: page title 22/700; sheet/step title 24/700; menu/selection title 17/700; card secondary 14; input/instruction 16; helper 12; section caption 11/600. Numerical calendar and picker roles remain separate. Define these centrally and migrate the identified exceptions first. Avoid changing global `TextTheme.titleMedium` to 17/700: it is also used for form group headings, license entries and other legitimate roles, and would affect Dark.

Suggested implementation order: compound selection title and export switch; holiday row readability with scalable layout; named action-label roles; adaptive long Light page headers. No new font or general redesign is needed.

## Evidence locations

Sources: `lib/presentation/widgets/common/cards/selection_card.dart`, `navigation_card.dart`, `toggle_card.dart`; `glass_screen_scaffold.dart`, `glass_bottom_sheet.dart`, `glass_picker_controls.dart`, `app_glass_button.dart`; `lib/presentation/widgets/screens/setup/components/config_card.dart`; settings `config_selection_bottomsheet.dart` and `calendar_export_bottomsheet.dart`; calendar `vacation_day_item.dart`, `duty_schedule_list.dart`, `animated_calendar_day.dart`; page and dialog implementations under `lib/presentation/screens` and settings `components/dialogs`.

Device screenshot archive: `/tmp/dienstplan-ui-2026-10-02`. Contact sheets `typography-audit-pages-0.png` through `-3.png` cover 24 representative captures; individual captures also cover the remaining setup steps, month/year picker, larger text and narrow layouts. Screenshots were read alongside current source, with differences in capture font scale taken into account rather than comparing raw pixel font size across captures.

## Final validation of implemented barriers

- Full suite: 123 passing tests (`suite-typography-barrier.log`).
- `flutter analyze --no-pub`: no issues (`analyze-typography-barrier.log`).
- ARM64 dev debug APK built and installed successfully with `pm install -r`; app data preserved.
- Fresh native captures: `typography-theme-light-35.png`, `typography-color-light-35.png`, `typography-export-light-35.png`. For color and export, background pixel channels are 0.649–0.652 of the same page without a modal, confirming approximately 35% black consistently.
- `typography-theme-dark-preserved.png` versus the prior `theme-dark-final.png`: zero pixel difference across the whole sheet (0,1810)–(1440,3032) and background cards (0,385)–(1440,1700).
- Theme preference remains System; temporary Android Light test override restored to Night mode `yes`. No export, color change, reset, feedback send or setup completion was performed.


Implementation update: the user subsequently authorized typography and text-driven layout corrections in both modes. Changes are now implemented; see `2026-10-02-typography-and-sheet-implementation.md` for the final scope and verification. Dark palette/glass decoration remains unchanged. The actual shared action adapter default is 16 sp; the initial typography audit's 14-sp value described the underlying Material label role without accounting for that override. Current role policy uses 16-sp standard actions and 14-sp compact segmented export actions.
