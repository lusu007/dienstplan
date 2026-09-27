# Calendar Rebuild Performance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce calendar rebuild cost by moving broad provider watches out of each visible day cell and narrowing `CalendarTable` to the state it actually needs.

**Architecture:** Add small immutable view models for calendar table state and shared calendar-day rendering inputs. `CalendarTable` reads those models once, passes plain values into `CalendarDayBuilders`, and `MemoizedCalendarDay` becomes a pure widget with no Riverpod watches. Selection rendering comes from `CalendarDayType.selected`, while `selectedDay` remains only in the table-level `selectedDayPredicate`.

**Tech Stack:** Flutter, Riverpod, `table_calendar`, existing schedule/settings/school-holiday providers.

---

## File Structure

- Modify: `lib/presentation/widgets/screens/calendar/components/table_calendar.dart`
  - Read narrow table state instead of `scheduleCoordinatorProvider.select((s) => s.value)`.
  - Read shared day-rendering inputs once and pass them into builders.
- Modify: `lib/presentation/widgets/screens/calendar/builders/calendar_day_builders.dart`
  - Accept shared day-rendering data and pass it to every `MemoizedCalendarDay`.
- Modify: `lib/presentation/widgets/screens/calendar/components/memoized_calendar_day.dart`
  - Remove all `ref.watch` calls from the day cell.
  - Convert the cell content to plain widget inputs.
  - Keep the existing duty-data cache and `RepaintBoundary`.
- Create: `lib/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart`
  - Define immutable `CalendarTableRenderingData` and `CalendarDayRenderingData`.
  - Define providers that project only the needed fields from existing app state.
- Test: `test/presentation/calendar_table_rendering_data_test.dart`
  - Cover view-model equality and computed effective partner/my fields.
- Test: `test/presentation/calendar_day_builders_test.dart`
  - Cover that builders pass `CalendarDayType.selected` and shared data into cells.

---

### Task 1: Add Narrow Calendar Rendering Models

**Files:**
- Create: `lib/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart`
- Test: `test/presentation/calendar_table_rendering_data_test.dart`

- [ ] **Step 1: Write model tests**

Create `test/presentation/calendar_table_rendering_data_test.dart`:

```dart
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarDayRenderingData', () {
    test('disables partner fields when partner visibility is false', () {
      final data = CalendarDayRenderingData(
        activeConfigName: 'main',
        preferredDutyGroup: 'A',
        myDutyGroup: 'A',
        partnerConfigName: 'partner',
        partnerDutyGroup: 'B',
        isPartnerVisible: false,
        partnerAccentColorValue: 0xff0000ff,
        myAccentColorValue: 0xffff0000,
        holidayAccentColorValue: 0xff00ff00,
        activeDutyTypes: const <String, DutyType>{},
        configs: const <DutyScheduleConfig>[],
        holidaysState: null,
        scheduleLookup: null,
      );

      expect(data.effectivePartnerConfigName, isNull);
      expect(data.effectivePartnerGroup, isNull);
      expect(data.effectiveMyGroup, 'A');
    });

    test('uses configured partner fields when partner visibility is true', () {
      final data = CalendarDayRenderingData(
        activeConfigName: 'main',
        preferredDutyGroup: null,
        myDutyGroup: 'A',
        partnerConfigName: 'partner',
        partnerDutyGroup: 'B',
        isPartnerVisible: true,
        partnerAccentColorValue: null,
        myAccentColorValue: null,
        holidayAccentColorValue: null,
        activeDutyTypes: const <String, DutyType>{},
        configs: const <DutyScheduleConfig>[],
        holidaysState: null,
        scheduleLookup: null,
      );

      expect(data.effectivePartnerConfigName, 'partner');
      expect(data.effectivePartnerGroup, 'B');
      expect(data.effectiveMyGroup, 'A');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/presentation/calendar_table_rendering_data_test.dart
```

Expected: fails because `calendar_day_rendering_data.dart` does not exist yet.

- [ ] **Step 3: Add rendering data types and providers**

Create `lib/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart`:

```dart
import 'package:dienstplan/core/utils/duty_type_display.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/duty_type.dart';
import 'package:dienstplan/domain/entities/schedule.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_partner_visibility_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_ui_state.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_schedule_lookup.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/duty_group_fallback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarTableRenderingData {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final String? activeConfigName;

  const CalendarTableRenderingData({
    required this.focusedDay,
    required this.selectedDay,
    required this.activeConfigName,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CalendarTableRenderingData &&
            other.focusedDay == focusedDay &&
            other.selectedDay == selectedDay &&
            other.activeConfigName == activeConfigName;
  }

  @override
  int get hashCode => Object.hash(focusedDay, selectedDay, activeConfigName);
}

class CalendarDayRenderingData {
  final CalendarDayScheduleLookup? scheduleLookup;
  final String? activeConfigName;
  final String? preferredDutyGroup;
  final String? myDutyGroup;
  final String? partnerConfigName;
  final String? partnerDutyGroup;
  final bool isPartnerVisible;
  final int? partnerAccentColorValue;
  final int? myAccentColorValue;
  final int? holidayAccentColorValue;
  final Map<String, DutyType>? activeDutyTypes;
  final List<DutyScheduleConfig> configs;
  final SchoolHolidaysUiState? holidaysState;

  const CalendarDayRenderingData({
    required this.scheduleLookup,
    required this.activeConfigName,
    required this.preferredDutyGroup,
    required this.myDutyGroup,
    required this.partnerConfigName,
    required this.partnerDutyGroup,
    required this.isPartnerVisible,
    required this.partnerAccentColorValue,
    required this.myAccentColorValue,
    required this.holidayAccentColorValue,
    required this.activeDutyTypes,
    required this.configs,
    required this.holidaysState,
  });

  String? get effectivePartnerConfigName =>
      isPartnerVisible ? partnerConfigName : null;

  String? get effectivePartnerGroup => isPartnerVisible ? partnerDutyGroup : null;

  String? get effectiveMyGroup => computeEffectiveMyGroup(
        preferredGroup: preferredDutyGroup,
        myDutyGroup: myDutyGroup,
      );

  Map<String, DutyType>? get partnerDutyTypes {
    final String? partnerName = effectivePartnerConfigName;
    if (partnerName == null || partnerName.isEmpty) {
      return null;
    }
    for (final DutyScheduleConfig config in configs) {
      if (config.name == partnerName) {
        return config.dutyTypes;
      }
    }
    return null;
  }

  int signatureForMonth(DateTime day) {
    return scheduleLookup?.signatureForMonth(day) ?? 0;
  }
}

final calendarTableRenderingDataProvider =
    Provider<CalendarTableRenderingData>((ref) {
  final DateTime now = DateTime.now();
  final focusedDay = ref.watch(
    scheduleCoordinatorProvider.select(
      (state) => state.value?.focusedDay,
    ),
  );
  final selectedDay = ref.watch(
    scheduleCoordinatorProvider.select(
      (state) => state.value?.selectedDay,
    ),
  );
  final activeConfigName = ref.watch(
    scheduleCoordinatorProvider.select(
      (state) => state.value?.activeConfigName,
    ),
  );

  return CalendarTableRenderingData(
    focusedDay: focusedDay ?? now,
    selectedDay: selectedDay,
    activeConfigName: activeConfigName,
  );
});

final calendarDayScheduleLookupProvider = Provider<CalendarDayScheduleLookup>((
  ref,
) {
  final List<Schedule> schedules = ref.watch(
    scheduleCoordinatorProvider.select(
      (state) => state.value?.schedules ?? const <Schedule>[],
    ),
  );
  return CalendarDayScheduleLookup(schedules);
});

final calendarDayRenderingDataProvider = Provider<CalendarDayRenderingData>((
  ref,
) {
  final settings = ref.watch(settingsProvider.select((s) => s.value));
  final scheduleLookup = ref.watch(calendarDayScheduleLookupProvider);

  return CalendarDayRenderingData(
    scheduleLookup: scheduleLookup,
    activeConfigName: ref.watch(
      scheduleCoordinatorProvider.select((state) => state.value?.activeConfigName),
    ),
    preferredDutyGroup: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.preferredDutyGroup,
      ),
    ),
    myDutyGroup: settings?.myDutyGroup,
    partnerConfigName: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerConfigName,
      ),
    ),
    partnerDutyGroup: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerDutyGroup,
      ),
    ),
    isPartnerVisible: ref.watch(calendarPartnerVisibilityProvider),
    partnerAccentColorValue: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.partnerAccentColorValue,
      ),
    ),
    myAccentColorValue: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.myAccentColorValue,
      ),
    ),
    holidayAccentColorValue: settings?.holidayAccentColorValue,
    activeDutyTypes: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.activeConfig?.dutyTypes,
      ),
    ),
    configs: ref.watch(
      scheduleCoordinatorProvider.select(
        (state) => state.value?.configs ?? const <DutyScheduleConfig>[],
      ),
    ),
    holidaysState: ref.watch(schoolHolidaysProvider.select((s) => s.value)),
  );
});
```

- [ ] **Step 4: Run model test**

Run:

```bash
flutter test test/presentation/calendar_table_rendering_data_test.dart
```

Expected: pass.

---

### Task 2: Narrow `CalendarTable` Watch Scope

**Files:**
- Modify: `lib/presentation/widgets/screens/calendar/components/table_calendar.dart`
- Test: `test/presentation/calendar_table_key_test.dart`

- [ ] **Step 1: Extend the existing table-key test**

Modify `test/presentation/calendar_table_key_test.dart`:

```dart
import 'package:dienstplan/presentation/widgets/screens/calendar/components/table_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calendarTableKeyForTesting', () {
    test('is stable for structural calendar inputs', () {
      expect(
        calendarTableKeyForTesting(
          focusedDay: DateTime(2026, 5, 4),
          activeConfigName: 'main',
          localeLanguageCode: 'de',
          rowHeight: 72.04,
        ),
        'cal_2026_5_main_de_rh72.0',
      );
    });

    test('does not include selected day', () {
      final String key = calendarTableKeyForTesting(
        focusedDay: DateTime(2026, 5, 4),
        activeConfigName: 'main',
        localeLanguageCode: 'de',
        rowHeight: 72.04,
      );

      expect(key, isNot(contains('2026-05-06')));
    });
  });
}
```

- [ ] **Step 2: Run table-key test**

Run:

```bash
flutter test test/presentation/calendar_table_key_test.dart
```

Expected: pass. This locks in that selection changes must not recreate the table key.

- [ ] **Step 3: Refactor `CalendarTable` to use narrow models**

In `lib/presentation/widgets/screens/calendar/components/table_calendar.dart`:

- Import `calendar_day_rendering_data.dart`.
- Replace:

```dart
final state = ref.watch(scheduleCoordinatorProvider.select((s) => s.value));
final DateTime focusedDay = state?.focusedDay ?? DateTime.now();
```

with:

```dart
final CalendarTableRenderingData tableData = ref.watch(
  calendarTableRenderingDataProvider,
);
final CalendarDayRenderingData dayData = ref.watch(
  calendarDayRenderingDataProvider,
);
final DateTime focusedDay = tableData.focusedDay;
```

- Replace all remaining `state?.selectedDay` and `state?.activeConfigName` reads with `tableData.selectedDay` and `tableData.activeConfigName`.
- Change the builders call to:

```dart
calendarBuilders: CalendarDayBuilders.create(
  cellHeight: cellHeight,
  renderingData: dayData,
),
```

- [ ] **Step 4: Run focused tests**

Run:

```bash
flutter test test/presentation/calendar_table_key_test.dart test/presentation/calendar_table_rendering_data_test.dart
```

Expected: pass.

---

### Task 3: Make Calendar Day Cells Pure Widgets

**Files:**
- Modify: `lib/presentation/widgets/screens/calendar/builders/calendar_day_builders.dart`
- Modify: `lib/presentation/widgets/screens/calendar/components/memoized_calendar_day.dart`
- Test: `test/presentation/calendar_day_builders_test.dart`

- [ ] **Step 1: Write builder wiring test**

Create `test/presentation/calendar_day_builders_test.dart`:

```dart
import 'package:dienstplan/presentation/widgets/screens/calendar/builders/calendar_day_builders.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/memoized_calendar_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selected builder creates selected calendar day cell', (
    WidgetTester tester,
  ) async {
    const renderingData = CalendarDayRenderingData(
      scheduleLookup: null,
      activeConfigName: null,
      preferredDutyGroup: null,
      myDutyGroup: null,
      partnerConfigName: null,
      partnerDutyGroup: null,
      isPartnerVisible: false,
      partnerAccentColorValue: null,
      myAccentColorValue: null,
      holidayAccentColorValue: null,
      activeDutyTypes: null,
      configs: [],
      holidaysState: null,
    );
    final builders = CalendarDayBuilders.create(
      cellHeight: 48,
      renderingData: renderingData,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: builders.selectedBuilder!(
          tester.element(find.byType(MaterialApp)),
          DateTime(2026, 5, 4),
          DateTime(2026, 5, 1),
        ),
      ),
    );

    final widget = tester.widget<MemoizedCalendarDay>(
      find.byType(MemoizedCalendarDay),
    );
    expect(widget.renderingData, same(renderingData));
    expect(widget.day, DateTime(2026, 5, 4));
  });
}
```

- [ ] **Step 2: Run builder test to verify it fails**

Run:

```bash
flutter test test/presentation/calendar_day_builders_test.dart
```

Expected: fails because `CalendarDayBuilders.create` and `MemoizedCalendarDay` do not accept `renderingData` yet.

- [ ] **Step 3: Update `CalendarDayBuilders`**

In `lib/presentation/widgets/screens/calendar/builders/calendar_day_builders.dart`:

- Import `calendar_day_rendering_data.dart`.
- Change the factory signature:

```dart
static tc.CalendarBuilders create({
  double? cellHeight,
  required CalendarDayRenderingData renderingData,
}) {
```

- Add `renderingData: renderingData` to every `MemoizedCalendarDay`.

- [ ] **Step 4: Refactor `MemoizedCalendarDay`**

In `lib/presentation/widgets/screens/calendar/components/memoized_calendar_day.dart`:

- Remove the `flutter_riverpod` import.
- Remove the local `calendarDayScheduleLookupProvider`; it now lives in `calendar_day_rendering_data.dart`.
- Add import:

```dart
import 'package:dienstplan/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart';
```

- Change `MemoizedCalendarDay` from `ConsumerWidget` to `StatelessWidget`.
- Add:

```dart
final CalendarDayRenderingData renderingData;
```

- Pass `renderingData` into `_MemoizedCalendarDayContent`.
- Change `_MemoizedCalendarDayContent` from `ConsumerWidget` to `StatelessWidget`.
- Replace all provider reads in `_MemoizedCalendarDayContent.build` with `renderingData` fields.
- Replace selected calculation with:

```dart
final bool isSelected = dayType == CalendarDayType.selected;
```

- Replace duty calculation guard with:

```dart
final CalendarDayScheduleLookup? scheduleLookup = renderingData.scheduleLookup;
final dutyData = scheduleLookup == null
    ? const DutyData(myDuty: '', partnerDuty: '', personalCalendarTitles: [])
    : _MemoizedDutyCalculator.calculateDutyData(
        day: day,
        scheduleLookup: scheduleLookup,
        activeConfigName: renderingData.activeConfigName,
        preferredGroup: renderingData.effectiveMyGroup,
        partnerConfigName: renderingData.effectivePartnerConfigName,
        partnerGroup: renderingData.effectivePartnerGroup,
        activeDutyTypes: renderingData.activeDutyTypes,
        partnerDutyTypes: renderingData.partnerDutyTypes,
      );
```

- Compute holidays from `renderingData.holidaysState`.

- [ ] **Step 5: Run builder test**

Run:

```bash
flutter test test/presentation/calendar_day_builders_test.dart
```

Expected: pass.

- [ ] **Step 6: Run calendar-focused test set**

Run:

```bash
flutter test test/presentation/calendar_table_key_test.dart test/presentation/calendar_table_rendering_data_test.dart test/presentation/calendar_day_builders_test.dart
```

Expected: pass.

---

### Task 4: Verify and Clean Up

**Files:**
- Modify only if analyzer reports unused imports or type issues.

- [ ] **Step 1: Run formatter**

Run:

```bash
dart format lib/presentation/widgets/screens/calendar/components/calendar_day_rendering_data.dart lib/presentation/widgets/screens/calendar/components/table_calendar.dart lib/presentation/widgets/screens/calendar/builders/calendar_day_builders.dart lib/presentation/widgets/screens/calendar/components/memoized_calendar_day.dart test/presentation/calendar_table_rendering_data_test.dart test/presentation/calendar_day_builders_test.dart test/presentation/calendar_table_key_test.dart
```

Expected: files formatted.

- [ ] **Step 2: Run analyzer**

Run:

```bash
flutter analyze
```

Expected: no new analyzer errors.

- [ ] **Step 3: Run full test suite**

Run:

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 4: Manual smoke test**

Run:

```bash
flutter run --flavor dev
```

Expected:
- Month swiping still updates the table.
- Selecting a day still highlights exactly that day.
- Opening the day bottomsheet still shows my duty, partner duty, personal entries, and school holidays.
- Toggling partner visibility updates calendar cells.
- Changing accent colors updates calendar cells.

---

## Self-Review

- Spec coverage: Item 1 is covered by Task 3; per-cell provider watches are removed. Item 2 is covered by Task 2; `CalendarTable` no longer watches the whole `ScheduleUiState.value`.
- Placeholder scan: no planned task relies on unspecified follow-up work.
- Type consistency: `CalendarDayRenderingData` and `CalendarTableRenderingData` are introduced before all consumers use them.
