# Android Glass Performance And Design Consistency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the reproducible Android frame drops during glass-modal transitions while making modal presentation, glass tokens, shared cards, semantic colors, and calendar contrast visually consistent.

**Architecture:** Keep the final glass appearance platform-neutral, but render a cheap static-tint surface while a modal route is moving and enable blur, ambient blobs, and scroll masks only after the route settles. Centralize modal route configuration in one presenter, then make shared primitives the sole source of tint, spacing, typography, semantic colors, and generic modal accents.

**Tech Stack:** Flutter 3.44, Dart 3.12, Material 3, Riverpod, `table_calendar`, Flutter widget tests, Windows Android Emulator/ADB profile measurements.

**Spec:** `docs/glass_design_consistency_audit.md`

## Global Constraints

- Do not add a permanent Android-only visual downgrade; the reduced-effects state exists only while a modal route is animating.
- A settled modal may have exactly one enabled root `BackdropFilter`; descendants remain disabled through `GlassBackdropBlurScope`.
- Modal contents stay mounted and interactive during route animation; only expensive visual effects are deferred.
- Use existing dependencies only.
- Preserve iOS behavior and the settled light/dark appearance.
- Use `glass_tokens.dart`, `ThemeData.textTheme`, and `ColorScheme` instead of new magic opacity, spacing, font-size, or semantic-color literals.
- The existing calendar rebuild optimization and its tests remain intact.
- Validate performance in profile mode, never debug mode.

---

## File Structure

- Modify: `lib/presentation/widgets/common/glass_dialog_surface.dart`
  - Support a static-tint transition state without a root blur or ambient blobs.
  - Use a theme-owned generic accent instead of a hard-coded partner default.
- Modify: `lib/presentation/widgets/common/glass_bottom_sheet.dart`
  - Drive all expensive effects from the modal route animation state.
- Create: `lib/presentation/widgets/common/glass_modal_bottom_sheet.dart`
  - Own the shared `showModalBottomSheet` route configuration.
- Modify: `lib/presentation/widgets/common/glass_container.dart`
  - Resolve light/dark tint and border tokens correctly and paint shadows outside clipping.
- Modify: `lib/core/constants/glass_tokens.dart`
  - Add only tokens required by the transition surface and shared cards.
- Modify: settings bottom-sheet launchers under `lib/presentation/widgets/screens/settings/components/bottomsheets/`
  - Route every settings sheet through the shared presenter.
- Modify: calendar modal launchers in `lib/presentation/widgets/screens/calendar/`
  - Route schedules, personal-entry, and date-selector sheets through the same presenter.
- Modify: `lib/presentation/widgets/common/cards/navigation_card.dart`
- Modify: `lib/presentation/widgets/common/cards/toggle_card.dart`
- Modify: `lib/presentation/widgets/common/cards/selection_card.dart`
  - Use shared typography and spacing tokens.
- Modify: `lib/presentation/widgets/common/error_display.dart`
  - Derive the default error color from `ColorScheme.error`.
- Modify: `lib/core/constants/calendar_config.dart`
- Modify: `lib/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart`
  - Define dark-mode weekday/outside-day contrast and constrain the full-layout selected surface.
- Modify: `docs/glass_design_consistency_audit.md`
  - Record the new source of truth and remaining deliberate exceptions.
- Modify: `test/presentation/glass_bottom_sheet_performance_test.dart`
- Create: `test/presentation/glass_modal_bottom_sheet_test.dart`
- Create: `test/presentation/glass_surface_tokens_test.dart`
- Create: `test/presentation/shared_card_style_test.dart`
- Modify: `test/presentation/calendar_day_builders_test.dart`
  - Lock down all performance and visual contracts.

---

### Task 1: Lock Down The Modal Transition Performance Contract

**Files:**
- Modify: `test/presentation/glass_bottom_sheet_performance_test.dart:40-105`

**Interfaces:**
- Consumes: existing `GlassBottomSheet.deferExpensiveEffects` and modal-route animation.
- Produces: failing tests that define the transition state required by Task 2.

- [ ] **Step 1: Replace the opening-blur expectation with the cheap transition contract**

Replace the test named `bottom sheet uses the same light root blur while opening` with:

```dart
testWidgets('bottom sheet defers root blur and masks while route opens', (
  WidgetTester tester,
) async {
  await tester.pumpWidget(_modalHarness());

  await tester.tap(find.text('Open'));
  await tester.pump();

  final GlassDialogSurface openingSurface = tester.widget(
    find.byType(GlassDialogSurface),
  );
  expect(openingSurface.expensiveEffectsEnabled, isFalse);
  expect(
    tester
        .widgetList<BackdropFilter>(find.byType(BackdropFilter))
        .where((BackdropFilter filter) => filter.enabled),
    isEmpty,
  );
  expect(find.byType(ShaderMask), findsNothing);

  await tester.pumpAndSettle();

  final GlassDialogSurface settledSurface = tester.widget(
    find.byType(GlassDialogSurface),
  );
  expect(settledSurface.expensiveEffectsEnabled, isTrue);
  expect(
    tester
        .widgetList<BackdropFilter>(find.byType(BackdropFilter))
        .where((BackdropFilter filter) => filter.enabled),
    hasLength(1),
  );
  expect(find.byType(ShaderMask), findsOneWidget);
});
```

Extract the existing modal setup into `_modalHarness()` so this test and the heavy-content test use the same route.

- [ ] **Step 2: Preserve the content-availability regression test**

Keep `bottom sheet shows heavy content while modal route opens` and add:

```dart
expect(find.byKey(heavyContentKey), findsOneWidget);
expect(
  tester.widget<GlassDialogSurface>(find.byType(GlassDialogSurface))
      .expensiveEffectsEnabled,
  isFalse,
);
```

This prevents an optimization that hides or rebuilds the sheet content.

- [ ] **Step 3: Run the test and verify the new contract fails**

Run:

```bash
flutter test test/presentation/glass_bottom_sheet_performance_test.dart
```

Expected: FAIL because `GlassDialogSurface.expensiveEffectsEnabled` does not exist and the root blur remains enabled while opening.

- [ ] **Step 4: Commit the failing contract**

```bash
git add test/presentation/glass_bottom_sheet_performance_test.dart
git commit -m "test: define cheap glass modal transition state"
```

---

### Task 2: Render A Static-Tint Surface During Modal Animation

**Files:**
- Modify: `lib/presentation/widgets/common/glass_dialog_surface.dart:12-123`
- Modify: `lib/presentation/widgets/common/glass_bottom_sheet.dart:115-227`
- Test: `test/presentation/glass_bottom_sheet_performance_test.dart`

**Interfaces:**
- Consumes: the route-settled state already tracked by `GlassBottomSheet`.
- Produces: `GlassDialogSurface.expensiveEffectsEnabled` as a required `bool` with a default of `true`.

- [ ] **Step 1: Add the explicit surface effect switch**

Add this field and constructor parameter to `GlassDialogSurface`:

```dart
final bool expensiveEffectsEnabled;

const GlassDialogSurface({
  super.key,
  required this.child,
  this.borderRadius = const BorderRadius.all(
    Radius.circular(glassSurfaceRadiusXl),
  ),
  this.backdropBlurSigma,
  this.expensiveEffectsEnabled = true,
});
```

- [ ] **Step 2: Omit blur and blobs instead of rendering zero-strength effects**

Build the shared tinted child once, then conditionally wrap it:

```dart
final Widget tintedSurface = Container(
  decoration: BoxDecoration(color: tintColor),
  child: Padding(
    padding: const EdgeInsets.all(1),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: innerBorderRadius,
        border: Border.all(color: innerBorderColor),
      ),
      child: child,
    ),
  ),
);

final Widget surface = expensiveEffectsEnabled
    ? BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: tintedSurface,
      )
    : tintedSurface;
```

Only add the two `AmbientBlob` children when `expensiveEffectsEnabled` is true. Keep the outer and inner borders in both states so the opening frame still reads as a glass sheet.

- [ ] **Step 3: Pass the route phase into both bottom-sheet layouts**

In both `GlassDialogSurface` calls inside `GlassBottomSheet`, add:

```dart
expensiveEffectsEnabled: expensiveEffectsEnabled,
```

Continue passing the same boolean to `ScrollFadeMask.enabled`. Do not defer the sheet children.

- [ ] **Step 4: Run the focused performance tests**

```bash
flutter test test/presentation/glass_bottom_sheet_performance_test.dart
```

Expected: all tests PASS; opening has zero enabled filters, settled state has exactly one, and content exists in both phases.

- [ ] **Step 5: Run static analysis and commit**

```bash
flutter analyze
git add lib/presentation/widgets/common/glass_dialog_surface.dart lib/presentation/widgets/common/glass_bottom_sheet.dart test/presentation/glass_bottom_sheet_performance_test.dart
git commit -m "perf: defer glass modal compositing until route settles"
```

---

### Task 3: Centralize Glass Modal Route Configuration

**Files:**
- Create: `lib/presentation/widgets/common/glass_modal_bottom_sheet.dart`
- Create: `test/presentation/glass_modal_bottom_sheet_test.dart`
- Modify: `lib/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart:25-47`

**Interfaces:**
- Consumes: Flutter's `showModalBottomSheet<T>`.
- Produces: `Future<T?> showGlassModalBottomSheet<T>({required BuildContext context, required WidgetBuilder builder, bool isScrollControlled, bool useSafeArea, bool isDismissible, bool enableDrag})`.

- [ ] **Step 1: Write a route-configuration test**

Create a recording navigator observer and assert the public route properties:

```dart
class RecordingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? lastPushed;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPushed = route;
  }
}

testWidgets('glass modal presenter applies the shared route recipe', (
  WidgetTester tester,
) async {
  final observer = RecordingNavigatorObserver();
  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: <NavigatorObserver>[observer],
      home: Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () => showGlassModalBottomSheet<void>(
            context: context,
            builder: (_) => const SizedBox(key: Key('sheet')),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await tester.pump();

  final ModalBottomSheetRoute<dynamic> route =
      observer.lastPushed! as ModalBottomSheetRoute<dynamic>;
  expect(route.isScrollControlled, isTrue);
  expect(route.backgroundColor, Colors.transparent);
  expect(route.barrierColor, Colors.black.withValues(alpha: glassBarrierAlpha));
  expect(route.clipBehavior, Clip.antiAlias);
  expect(find.byKey(const Key('sheet')), findsOneWidget);
});
```

- [ ] **Step 2: Run the new test and verify it fails**

```bash
flutter test test/presentation/glass_modal_bottom_sheet_test.dart
```

Expected: FAIL because `showGlassModalBottomSheet` does not exist.

- [ ] **Step 3: Implement the presenter**

Create `glass_modal_bottom_sheet.dart`:

```dart
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:flutter/material.dart';

Future<T?> showGlassModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
    clipBehavior: Clip.antiAlias,
    builder: builder,
  );
}
```

- [ ] **Step 4: Make `GenericBottomsheet.show` delegate to the presenter**

Replace its direct `showModalBottomSheet<T>` call with `showGlassModalBottomSheet<T>`, preserving its generic result and builder.

- [ ] **Step 5: Verify and commit**

```bash
flutter test test/presentation/glass_modal_bottom_sheet_test.dart test/presentation/glass_bottom_sheet_performance_test.dart
flutter analyze
git add lib/presentation/widgets/common/glass_modal_bottom_sheet.dart lib/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart test/presentation/glass_modal_bottom_sheet_test.dart
git commit -m "refactor: centralize glass modal route styling"
```

---

### Task 4: Migrate Every Settings Bottom Sheet To The Shared Presenter

**Files:**
- Modify: `lib/presentation/widgets/screens/settings/components/bottomsheets/german_state_bottomsheet.dart`
- Modify: `lib/presentation/widgets/screens/settings/components/bottomsheets/holiday_color_bottomsheet.dart`
- Modify: `lib/presentation/widgets/screens/settings/components/bottomsheets/my_accent_color_bottomsheet.dart`
- Modify: `lib/presentation/widgets/screens/settings/components/bottomsheets/partner_color_bottomsheet.dart`
- Modify: `lib/presentation/widgets/screens/settings/components/bottomsheets/theme_mode_bottomsheet.dart`
- Modify: all remaining direct settings launchers reported by `rg -n "showModalBottomSheet" lib/presentation/widgets/screens/settings`
- Test: `test/presentation/glass_modal_bottom_sheet_test.dart`

**Interfaces:**
- Consumes: `showGlassModalBottomSheet<T>` from Task 3.
- Produces: no direct settings-level `showModalBottomSheet` calls.

- [ ] **Step 1: Add representative result and dismissal tests**

Extend `glass_modal_bottom_sheet_test.dart` with one `String` result and one `void` dismissal case:

```dart
final Future<String?> result = showGlassModalBottomSheet<String>(
  context: context,
  builder: (BuildContext sheetContext) => TextButton(
    onPressed: () => Navigator.pop(sheetContext, 'HE'),
    child: const Text('Choose'),
  ),
);
expect(await result, 'HE');
```

This protects the generic result used by the German-state picker.

- [ ] **Step 2: Migrate the five inconsistent settings sheets**

For each launcher, preserve its return type and replace only the route call:

```dart
return showGlassModalBottomSheet<String>(
  context: context,
  builder: (BuildContext context) => SelectionBottomsheet(...),
);
```

Remove duplicated `backgroundColor`, `barrierColor`, and `clipBehavior` arguments and their now-unused imports.

- [ ] **Step 3: Migrate the remaining settings launchers**

Apply the same delegation to duty schedule, partner config/group, duty group, calendar export, reset, and config selection sheets. Preserve any non-default `isDismissible`, `enableDrag`, or `useSafeArea` value by forwarding it explicitly.

- [ ] **Step 4: Verify there is one route owner**

```bash
rg -n "showModalBottomSheet" lib/presentation/widgets/screens/settings
```

Expected: no matches.

- [ ] **Step 5: Run tests and commit**

```bash
flutter test test/presentation/glass_modal_bottom_sheet_test.dart test/presentation/glass_bottom_sheet_performance_test.dart
flutter analyze
git add lib/presentation/widgets/screens/settings/components/bottomsheets
git commit -m "refactor: unify settings glass sheets"
```

---

### Task 5: Migrate Calendar Modals Without Changing Their Content Layout

**Files:**
- Modify: `lib/presentation/widgets/screens/calendar/components/schedules_bottom_sheet.dart:25-45`
- Modify: `lib/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart:989-1040`
- Modify: `lib/presentation/widgets/screens/calendar/date_selector/calendar_date_selector.dart:155-322`
- Test: `test/presentation/glass_modal_bottom_sheet_test.dart`
- Test: `test/presentation/calendar_year_picker_layout_test.dart`

**Interfaces:**
- Consumes: `showGlassModalBottomSheet<T>`.
- Produces: the same schedules, personal-entry, month, and year picker contents under one route recipe.

- [ ] **Step 1: Add a custom-content regression test**

Add a test proving the presenter does not impose `GlassBottomSheet` layout. Launch it from a button callback so the test can continue pumping the route:

```dart
onPressed: () {
  showGlassModalBottomSheet<void>(
    context: context,
    builder: (_) => const GlassDialogSurface(
      child: SizedBox(key: Key('custom-dialog'), height: 240),
    ),
  );
},
```

Open it without awaiting inside the button callback and assert `custom-dialog` is present. This protects the date selector's custom dialog surface.

- [ ] **Step 2: Migrate `SchedulesBottomSheet.show`**

Delegate its route construction to `showGlassModalBottomSheet<void>`. Keep the existing `.then` focus cleanup unchanged.

- [ ] **Step 3: Migrate the personal-entry launcher**

Replace only its route creation. Preserve its current height, keyboard inset handling, result semantics, and `GlassBottomSheet` body.

- [ ] **Step 4: Migrate the calendar date selector**

Use the shared presenter around the existing `StatefulBuilder` and `GlassDialogSurface`. Do not wrap it in `GlassBottomSheet`; its page controllers and fixed picker layout remain unchanged.

- [ ] **Step 5: Verify calendar modal ownership and behavior**

```bash
rg -n "showModalBottomSheet" lib/presentation/widgets/screens/calendar
flutter test test/presentation/glass_modal_bottom_sheet_test.dart test/presentation/calendar_year_picker_layout_test.dart test/presentation/glass_bottom_sheet_performance_test.dart
```

Expected: no direct calendar matches and all focused tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/widgets/screens/calendar test/presentation/glass_modal_bottom_sheet_test.dart
git commit -m "refactor: unify calendar glass modal routes"
```

---

### Task 6: Make Glass Tokens And Painting Order The Actual Source Of Truth

**Files:**
- Modify: `lib/presentation/widgets/common/glass_container.dart:12-83`
- Modify: `lib/presentation/widgets/common/glass_dialog_surface.dart:31-77`
- Modify: `lib/core/constants/glass_tokens.dart`
- Create: `test/presentation/glass_surface_tokens_test.dart`

**Interfaces:**
- Consumes: light/dark surface, border, and shadow tokens.
- Produces: nullable `GlassContainer.tintOpacity` and `borderOpacity` overrides; defaults resolve by brightness.

- [ ] **Step 1: Write light/dark token-resolution tests**

Pump `GlassContainer` once with a light theme and once with a dark theme. Locate the decorated surface by key and assert:

```dart
expect(
  decoration.color,
  scheme.primary.withValues(alpha: glassSurfaceSubtleTintAlphaDark),
);
expect(
  decoration.border!.top.color,
  Colors.white.withValues(alpha: glassSurfaceSubtleBorderAlphaDark),
);
```

Add a third case with `tintOpacity: 0.12` and `borderOpacity: 0.21` to prove explicit overrides are preserved in both brightness modes.

- [ ] **Step 2: Run the token test and verify it fails**

```bash
flutter test test/presentation/glass_surface_tokens_test.dart
```

Expected: FAIL because the dark tint currently uses `light + 0.08` and the dark border uses a multiplier.

- [ ] **Step 3: Resolve default tokens by brightness**

Change the fields to nullable overrides and resolve them explicitly:

```dart
final double resolvedTintOpacity = tintOpacity ??
    (isDark
        ? glassSurfaceSubtleTintAlphaDark
        : glassSurfaceSubtleTintAlphaLight);
final double resolvedBorderOpacity = borderOpacity ??
    (isDark
        ? glassSurfaceSubtleBorderAlphaDark
        : glassSurfaceSubtleBorderAlphaLight);
```

Use those values directly. Keep the existing light primary-border factor only if `glassSurfaceSubtleBorderAlphaLight` represents the pre-factor base; otherwise move the final light alpha into one token and remove the multiplier.

- [ ] **Step 4: Move the container shadow outside the clip**

Use an outer `DecoratedBox` for the shadow and keep tint/border inside `ClipRRect`:

```dart
final Widget content = DecoratedBox(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: <BoxShadow>[resolvedShadow],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      enabled: isBackdropBlurEnabled,
      child: decoratedTintAndBorder,
    ),
  ),
);
```

The inner decoration must no longer contain `boxShadow`.

- [ ] **Step 5: Remove partner semantics from generic modal decoration**

In `GlassDialogSurface`, remove `AccentColorDefaults.partnerAccentColorValue` and its import. Use `colorScheme.tertiary` for the second ambient blob while retaining the existing tokenized alpha. Calendar-specific partner colors remain in `CalendarBackdrop`, where they represent user data.

- [ ] **Step 6: Verify and commit**

```bash
flutter test test/presentation/glass_surface_tokens_test.dart test/presentation/glass_bottom_sheet_performance_test.dart
flutter analyze
git add lib/core/constants/glass_tokens.dart lib/presentation/widgets/common/glass_container.dart lib/presentation/widgets/common/glass_dialog_surface.dart test/presentation/glass_surface_tokens_test.dart
git commit -m "fix: align glass surfaces with theme tokens"
```

---

### Task 7: Unify Shared Card Typography, Spacing, And Error Color

**Files:**
- Modify: `lib/presentation/widgets/common/cards/navigation_card.dart:37-76`
- Modify: `lib/presentation/widgets/common/cards/toggle_card.dart:38-84`
- Modify: `lib/presentation/widgets/common/cards/selection_card.dart:48-150`
- Modify: `lib/presentation/widgets/common/error_display.dart:11-60`
- Modify: `lib/core/constants/glass_tokens.dart`
- Create: `test/presentation/shared_card_style_test.dart`

**Interfaces:**
- Consumes: `textTheme.titleMedium`, `textTheme.bodyMedium`, glass spacing tokens, and `colorScheme.error`.
- Produces: the same visual hierarchy for navigation, toggle, and selection cards without local font-size recipes.

- [ ] **Step 1: Write shared-style widget tests**

Pump all three card types in the same `MaterialApp` and assert their title and subtitle styles inherit the theme sizes:

```dart
expect(title.style?.fontSize, theme.textTheme.titleMedium?.fontSize);
expect(subtitle.style?.fontSize, theme.textTheme.bodyMedium?.fontSize);
```

Pump `ErrorDisplay` with an immediately available language-service override and assert its default icon color equals `Theme.of(context).colorScheme.error`. Add a second case proving an explicit `iconColor` still wins.

- [ ] **Step 2: Run the test and verify it fails**

```bash
flutter test test/presentation/shared_card_style_test.dart
```

Expected: FAIL because the cards force sizes `17` and `14`, and `ErrorDisplay` defaults to `Colors.red`.

- [ ] **Step 3: Remove local font sizes and tokenize spacing**

Keep weight and semantic colors, but remove `fontSize` from all title/subtitle `copyWith` calls. Replace repeated values as follows:

```dart
8  -> glassSpacingSm
12 -> glassSpacingMd
14 -> glassCardContentGap
16 -> glassSpacingLg
20 -> glassCardContentPaddingHorizontal
```

Add `glassCardContentGap = 14` and `glassCardContentPaddingHorizontal = 20` to `glass_tokens.dart`; these values express stable component dimensions that do not fit the 4/8/12/16/24 spacing scale.

- [ ] **Step 4: Make the error default theme-derived**

Change the constructor default to `null` and resolve it during build:

```dart
final Color resolvedIconColor = iconColor ?? Theme.of(context).colorScheme.error;
```

Pass `resolvedIconColor` to the icon.

- [ ] **Step 5: Verify and commit**

```bash
flutter test test/presentation/shared_card_style_test.dart
flutter analyze
git add lib/core/constants/glass_tokens.dart lib/presentation/widgets/common/cards lib/presentation/widgets/common/error_display.dart test/presentation/shared_card_style_test.dart
git commit -m "style: unify shared card and error semantics"
```

---

### Task 8: Improve Calendar Contrast And Full-Layout Selection Proportion

**Files:**
- Modify: `lib/core/constants/calendar_config.dart:7-20`
- Modify: `lib/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart:79-119`
- Modify: `test/presentation/calendar_day_builders_test.dart`
- Create: `test/presentation/calendar_style_test.dart`

**Interfaces:**
- Consumes: `ColorScheme.onSurface`, `onSurfaceVariant`, current `CalendarDayType`, and `useCompactDutyStripes`.
- Produces: explicit calendar label styles and a bounded selected/today plate in tall full-layout cells.

- [ ] **Step 1: Write calendar style tests for both brightness modes**

Call `CalendarConfig.createCalendarStyle(context)` in light and dark harnesses and assert:

```dart
expect(style.defaultTextStyle.color, scheme.onSurface);
expect(style.weekendTextStyle.color, scheme.onSurface);
expect(style.outsideTextStyle.color, scheme.onSurfaceVariant);
expect(style.disabledTextStyle.color, scheme.onSurfaceVariant);
```

Also inspect the `DaysOfWeekStyle` passed by `CalendarTable` and require weekday/weekend labels to use `scheme.onSurfaceVariant` with `FontWeight.w600`.

- [ ] **Step 2: Run the new tests and verify they fail**

```bash
flutter test test/presentation/calendar_style_test.dart test/presentation/calendar_day_builders_test.dart
```

Expected: FAIL because only selected/today decorations are currently specified.

- [ ] **Step 3: Define explicit themed calendar styles**

Extend `CalendarConfig.createCalendarStyle` with theme-derived text styles. Do not introduce opacity literals; use semantic scheme colors. Add `CalendarConfig.createDaysOfWeekStyle(BuildContext)` and pass it from `CalendarTable`.

- [ ] **Step 4: Bound the selected surface without shrinking duty content**

In `AnimatedCalendarDay`, separate the background plate from the content. For non-compact cells taller than `CalendarConfig.kCalendarDayHeight`, center a selected/today plate with a maximum height of `CalendarConfig.kCalendarDayHeight`; keep the content column laid out against the full cell height:

```dart
final double plateHeight = compactCell
    ? effectiveHeight
    : effectiveHeight.clamp(
        0.0,
        CalendarConfig.kCalendarDayHeight,
      ).toDouble();

return InkWell(
  onTap: widget.onTap,
  child: Stack(
    fit: StackFit.expand,
    children: <Widget>[
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: effectiveWidth,
          height: plateHeight,
          child: DecoratedBox(decoration: resolvedDecoration),
        ),
      ),
      contentColumn,
    ],
  ),
);
```

Apply the bounded plate only to selected/today decoration; ordinary, outside-month, and holiday-strip geometry must remain unchanged.

- [ ] **Step 5: Add geometry assertions**

Extend `calendar_day_builders_test.dart` with a full-layout selected cell of height `120`. Assert that the cell remains `120` high, its selected plate is `CalendarConfig.kCalendarDayHeight`, and duty chips remain present. Retain the existing compact-stripe test unchanged.

- [ ] **Step 6: Verify and commit**

```bash
flutter test test/presentation/calendar_style_test.dart test/presentation/calendar_day_builders_test.dart test/presentation/calendar_table_key_test.dart test/presentation/calendar_table_rendering_data_test.dart
flutter analyze
git add lib/core/constants/calendar_config.dart lib/presentation/widgets/screens/calendar/date_selector/animated_calendar_day.dart lib/presentation/widgets/screens/calendar/components/table_calendar.dart test/presentation/calendar_style_test.dart test/presentation/calendar_day_builders_test.dart
git commit -m "style: improve calendar contrast and selection geometry"
```

---

### Task 9: Reprofile Android And Update The Design Audit

**Files:**
- Modify: `docs/glass_design_consistency_audit.md`

**Interfaces:**
- Consumes: the completed implementation and Windows AVD `Dienstplan_Android35`.
- Produces: measured before/after evidence and an audit matching the actual code.

- [ ] **Step 1: Run the complete automated verification**

```bash
flutter analyze
flutter test
flutter build apk --profile --flavor dev
```

Expected: all commands exit `0`.

- [ ] **Step 2: Install the profile APK on the Windows AVD**

From Windows PowerShell:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 install -r "C:\Users\lukas\AppData\Local\Temp\dienstplan-dev-profile.apk"
& $adb -s emulator-5554 shell am force-stop io.scelus.dienstplan.dev
& $adb -s emulator-5554 shell monkey -p io.scelus.dienstplan.dev 1
```

Copy the newly built APK from WSL before running the PowerShell commands:

```bash
cp build/app/outputs/flutter-apk/app-dev-profile.apk /mnt/c/Users/lukas/AppData/Local/Temp/dienstplan-dev-profile.apk
```

- [ ] **Step 3: Repeat the same interaction sequence five times**

Measure these separately after one warm-up run:

1. Open the schedules bottom sheet from the full calendar.
2. Dismiss it.
3. Swipe to the next month.
4. Open and scroll a settings selection sheet.

Use `adb shell dumpsys SurfaceFlinger --latency <surface-name>` and exclude only the initial sample plus intervals after the route has visibly settled. Record frame count, p50, p90, p95, maximum, intervals over 20 ms, and intervals over 32 ms for every run.

- [ ] **Step 4: Apply the acceptance gate**

The work passes on the existing Pixel 6 / Android 35 AVD when:

- each sheet-opening run has p95 at or below 20 ms;
- no sheet-opening run has more than one core-transition interval above 32 ms;
- steady sheet scrolling has p95 at or below 20 ms;
- no regression is visible in settled light or dark screenshots;
- the profile log still reports Impeller and no runtime exception.

If the gate fails, stop before design-polish follow-ups and capture a Flutter DevTools raster/UI frame trace for the failing interaction. Do not compensate by lowering the settled blur globally.

- [ ] **Step 5: Update the audit with the verified state**

Update `docs/glass_design_consistency_audit.md` so it states:

- all settings and calendar sheets use `showGlassModalBottomSheet`;
- modal transitions use static tint until settled;
- generic dialogs use `ColorScheme.tertiary`, while `CalendarBackdrop` alone uses live duty accents;
- the stronger settled dialog tint is an intentional modal-separation role, distinct from the subtler inline action-bar glass;
- shared cards inherit theme typography;
- remaining literal values are either removed or explicitly documented component dimensions;
- include the before/after Android profile table and exact device/API/renderer.

- [ ] **Step 6: Confirm repository scope and commit**

```bash
git status --short
git diff --check
git add docs/glass_design_consistency_audit.md
git commit -m "docs: record glass performance and consistency verification"
```

Expected: no unrelated user files are staged, especially the pre-existing `docs/superpowers/plans/2026-06-27-calendar-rebuild-performance.md` unless the user explicitly adds it.

---

## Final Review Checklist

- [ ] Opening a modal has zero enabled backdrop filters until the route settles.
- [ ] A settled modal has exactly one enabled backdrop filter.
- [ ] Sheet contents remain mounted throughout the route animation.
- [ ] `rg -n "showModalBottomSheet" lib/presentation/widgets/screens` reports no direct screen-level calls.
- [ ] Dark and light glass defaults resolve from their matching tokens.
- [ ] Generic dialog decoration has no partner-duty semantic dependency.
- [ ] Shared cards inherit theme font sizes and use shared spacing tokens.
- [ ] Default error visuals use `ColorScheme.error`.
- [ ] Calendar labels have explicit semantic colors in light and dark mode.
- [ ] The tall-calendar selected plate is bounded without removing duty chips.
- [ ] Full `flutter analyze`, `flutter test`, and profile APK build pass.
- [ ] Android profile measurements meet the acceptance gate.
