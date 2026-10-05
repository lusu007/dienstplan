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

Inside a Light `AppModalSurfaceScope`, neutral cards use `onSurface` tint at 5% and an `onSurface` outline at 22%, instead of white on the pale modal canvas. The same neutral recipe applies to unselected month/year tiles and secondary modal controls. Active/custom semantic decoration remains unchanged. Cards outside modals and all Dark material retain their existing recipe.

Use `GlassCardGroup` (also in `glass_card.dart`) for related settings rows: one outer surface and dividers. Normal rows remain transparent; active rows and custom tints/borders use lightweight per-row decoration without another glass layer. Disabled custom emphasis uses the existing disabled alpha multiplier; navigation rows retain their own disabled text/icon styling. Set `modalTrigger: true` on `GlassCard` or `NavigationCard` when it opens a modal; this suppresses the background ink splash/highlight while retaining the tap handler.

Use when:

- The element is card-like and participates in selection/active states.
- A surface should visually align with settings cards.

Do not:

- Replace with plain `Card` on glass screens.
- Re-implement borders/shadows for card-like UI in feature modules.

### `GlassDialogSurface`

Use as root container for glass dialogs and modal content.

`GlassDialogSurface` supplies `AppModalSurfaceScope`; the native theme sheet supplies the same scope explicitly. Light modal handles use `onSurface` at 50%. Entry fields use the neutral 5% fill and a stronger 50% `onSurface` outline so unfocused fields remain identifiable. Keep this stronger functional boundary distinct from decorative card borders. Translucent Light badges use readable `onSurface` labels rather than assuming the fill is opaque primary.

Light Mode adds a semantic surface content fill at `glassDialogContentAlphaLight` (0.90), inside the existing glass layer. This protects text from the content behind the modal. Dark Mode keeps its existing composition; sheet blur remains 4. The theme picker applies the Light tint to its entire native glass shell, including the handle and footer, and updates within its existing route. Light `GlassAppDialog` constrains scrollable content with a loose flexible area so actions stay reachable on short/narrow screens; Dark layout stays unchanged.

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

The theme picker is an explicit exception: `ThemeModeBottomsheet` builds the library `GlassSheet` reactively inside a general dialog, using standard quality, the app sheet blur token, and the library’s slide transition and dismissal behavior. The library provides its shell and handle; do not nest `GlassBottomSheet` inside it. Resolve the whole shell tint from the current theme so the handle and footer update when the picker changes that theme. Dark uses its original untinted glass settings. The theme route updates its barrier with navigator brightness: shared 35% black in Light, original library barrier in Dark. Light Material bottom-sheet defaults also use the shared 35% barrier.

### `AppGlassButton` and `AppGlassIconButton`

Use these adapters for app actions instead of Material buttons or new local glass recipes. They use the installed native `GlassButton` / `GlassIconButton` library controls and the app glass settings.

- `primary`: prominent style for Continue, Save, Send, Retry and confirmation.
- `secondary`: filled style for supporting actions such as an attachment.
- `quiet`: transparent style for Cancel and low-priority actions.
- `destructive`: filled style with semantic error tint for deletion/reset confirmation; Light labels use `onErrorContainer` for contrast, Dark labels retain `error`.

Pass `isLoading` for work in progress: the callback is blocked and a spinner remains at full opacity. `enabled: false` or a null callback disables the action; do not add another caller opacity. Button height is a minimum of 48 dp; labels can wrap and expand vertically. For secondary inline actions, `compact: true` allows a 36 dp visual surface inside the same 48 dp touch target. The shared authority-filter clear action uses this compact variant with 14 sp text and 10/6 dp horizontal/vertical padding in setup and all plan pickers. The `.icon` constructor adds a leading icon, replaced by the spinner during loading.

`AppGlassIconButton` requires a tooltip and exposes button/selected semantics. Visible sizes below 48 dp retain a centered 48 × 48 dp touch target. Reserve space for that complete target; neighboring targets must not overlap. Use the existing circle or rounded-square shape parameter. Colors outside the new buttons stay unchanged in Dark Mode.

### `AppSnackBar` and tooltips

Use `AppSnackBar` for transient messages through `ScaffoldMessenger`. Its `AppGlassSurface` uses the installed library's `GlassContainer`, with a 96% semantic surface fill and an onSurface outline (Light 22%, Dark 28%) so content underneath does not compromise readability. Text uses onSurface, 14 sp, weight 500 and line height 1.4. Messages wrap without a line limit. Keep caller durations and the messenger's route handoff, queue and dismissal behavior. Optional `SnackBarAction` is placed below the message and remains persistent until acted on or dismissed.

The installed library's `GlassToast` fixes text to two lines with ellipsis and does not expose text styling. Use its shared glass material through the adapter rather than truncating long messages, including reset confirmation and schedule updates.

`AppFeedbackStyle` defines the matching global tooltip theme for Light and Dark. The library has no standalone tooltip component; retain Flutter's `Tooltip` placement, long-press behavior and semantics. Tooltips use the same readable surface/text/outline recipe, a smaller radius and 12/8 dp horizontal/vertical padding. Do not give individual tooltips an inverse Material palette.

Inside the personal-entry editor, failures remain in the sheet: missing-title feedback belongs to the title field, and operation errors use a library-backed `GlassCard` above Save. Announce feedback as a live region and reveal it when the form has been scrolled. Clear the title error when the user supplies a nonblank title. Reserve main-scaffold notifications for success after the editor closes; a notification on that scaffold is covered by an open modal route.

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


### Shared sheet and typography rules (2026-10-02)

`AppSheetStyle` and `AppSheetHandle` define Light shell radius 32, outer margins 8 including bottom safe area, a readable semantic neutral handle (44×4, 16 top gap), and common bottom spacing. Dark keeps its existing radius/margins/white handle. Theme selection retains its native reactive route and mirrors the Light handle/body rhythm; month/year selection retains its specialized header while sharing Light outer margins and handle. Never add a second system inset inside a Light export action area.

Simple group/color pickers use content-sized Light shells capped by available screen space, with one outer scrolling surface. Filterable configuration lists, export and day detail retain useful larger layouts. Color tiles adapt their height for large fonts in either theme; default Dark tiles retain their existing aspect ratio. The entry editor still owns keyboard padding.

Plan selection toggles: tapping the selected plan clears it and its associated duty group, then dismisses. Own and partner plan pickers have no extra no-plan row (user decision 2026-10-03). Group selection retains its no-op confirmation and explicit localized no-group choice. Color selection closes; theme selection stays open for live comparison. Reset keeps its explicit cancellation action.

Typography follows `AppTypography` in both modes. Compound names and export switch labels use the menu title role; page headers can wrap; holiday text is 15/12 compact, 18/14 large with 11-sp chips and content-driven row height. Palette and glass decoration remain unchanged in Dark.

### Filterzustände und neutrale Navigation (2026-10-03)

Filterchips verwenden weiterhin `liquid.GlassChip` mit nativer `GlassBodyMode.adaptive`-Tönung. Ausgewählt: Akzentfarbe mit den Deckkraftwerten der aktiven Karten (Light .18 / Dark .22), eine einzelne äußere 1,5-dp-Kontur und normale onSurface-Schrift. Dark verändert den Akzentton nicht künstlich. Behördenfilter ergänzen ein Häkchen; zweigeteilte Termin-/Dienst-Chips behalten den Platz für ihre Labels. Die innere Library-Auswahlfläche bleibt transparent. Die Auswahl wird über Kontur/Häkchen vermittelt, nicht durch eine nahezu deckende Fläche. Tests sichern adaptive Tönung, niedrige Deckkraft, Auswahlkontur und Lesbarkeit ab.

Normale Light-Steuerelemente (Monats-/Jahres-Trigger, Zurück/Navigation, sekundäre Aktionen) verwenden neutrale Surface-Tönung und eine zurückhaltende onSurface-Kante. Primäre/destruktive Aktionen und explizite Auswahlzustände behalten ihre semantische Akzentfarbe. Dark-Navigationsflächen bleiben erhalten.

### Feste Konturen beim Ziehen

Das gemeinsame `AppGlassTheme` behält `GlassInteractionSettings(stretch: 0)` für nicht angepasste Library-Komponenten. Text-/Pickerbuttons überschreiben dies explizit mit `stretch: .4`; Iconbuttons erhalten denselben Wert in einem lokalen Glass-Theme. Beide verwenden `anchorStretch: true` mit Intensität/Squash .1, Translation 0 und Bounciness 0. Der semantische Rand liegt innerhalb des animierten Library-Inhalts: Rand, Glas und Inhalt verformen sich zusammen dezent, statt aus einer festen Außenkontur zu gleiten. Bei Reduce Motion und deaktivierten Aktionen bleibt die Verformung aus. Chips und Bottomsheet-Bewegung bleiben unverändert. Drag-Tests prüfen gemeinsame Rand-/Glasgeometrie, begrenzte Verformung, Rückkehr nach Abbruch und Reduce Motion.
