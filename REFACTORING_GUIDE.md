# State Management Refactoring Guide

## Overview

This guide documents the refactoring of the monolithic `ScheduleNotifier` (847 lines) into smaller, focused notifiers following the Single Responsibility Principle.

## Problem

The original `ScheduleNotifier` was doing too much:
- Calendar state management (focused day, selected day, format)
- Schedule data loading and caching
- Configuration management (active config, duty groups)
- Partner settings management
- Complex orchestration between all these concerns

This violated the Single Responsibility Principle and made the code:
- Hard to test
- Difficult to maintain
- Prone to bugs
- Hard to understand

## Solution

We've broken down the monolithic notifier into four focused notifiers:

### 1. CalendarNotifier
**Responsibility**: Calendar UI state management
- `selectedDay` - Currently selected day
- `focusedDay` - Currently focused day (for month navigation)
- `calendarFormat` - Month/Week/TwoWeeks view
- `isLoading` - Loading state for calendar operations
- `error` - Error state for calendar operations

**Key Methods**:
- `setFocusedDay(DateTime day)`
- `setSelectedDay(DateTime? day)`
- `setCalendarFormat(CalendarFormat format)`
- `goToToday()`

### 2. ScheduleDataNotifier
**Responsibility**: Schedule data loading and caching
- `schedules` - List of loaded schedules
- `activeConfigName` - Currently active configuration name
- `preferredDutyGroup` - User's preferred duty group
- `selectedDutyGroup` - Currently selected duty group for filtering
- `isLoading` - Loading state for data operations
- `error` - Error state for data operations

**Key Methods**:
- `loadSchedulesForDateRange({required DateTime startDate, required DateTime endDate, required String configName})`
- `setPreferredDutyGroup(String? group)`
- `setSelectedDutyGroup(String? group)`
- `updateActiveConfigName(String? configName)`

### 3. ConfigNotifier
**Responsibility**: Configuration management
- `activeConfigName` - Currently active configuration name
- `dutyGroups` - Available duty groups for active config
- `configs` - All available configurations
- `activeConfig` - Currently active configuration object
- `isLoading` - Loading state for config operations
- `error` - Error state for config operations

**Key Methods**:
- `setActiveConfig(DutyScheduleConfig config)`
- `refreshConfigs()`

### 4. PartnerNotifier
**Responsibility**: Partner settings management
- `partnerConfigName` - Partner's configuration name
- `partnerDutyGroup` - Partner's duty group
- `partnerAccentColorValue` - Partner's accent color
- `myAccentColorValue` - User's accent color
- `isLoading` - Loading state for partner operations
- `error` - Error state for partner operations

**Key Methods**:
- `setPartnerConfigName(String? configName)`
- `setPartnerDutyGroup(String? group)`
- `setPartnerAccentColor(int? colorValue)`
- `setMyAccentColor(int? colorValue)`
- `clearPartnerSettings()`

### 5. ScheduleCoordinatorNotifier
**Responsibility**: Orchestrating between the individual notifiers
- Combines all individual states into the main `ScheduleUiState`
- Coordinates operations that affect multiple notifiers
- Provides a unified interface for complex operations

**Key Methods**:
- `setFocusedDay(DateTime day, {bool shouldLoad = true})`
- `setSelectedDay(DateTime? day)`
- `setActiveConfig(DutyScheduleConfig config)`
- All other methods that coordinate between notifiers

## Benefits

### 1. Single Responsibility Principle
Each notifier has one clear responsibility, making the code easier to understand and maintain.

### 2. Better Testability
Smaller, focused notifiers are much easier to unit test:
```dart
// Easy to test calendar operations in isolation
test('should update focused day', () async {
  final notifier = CalendarNotifier();
  await notifier.setFocusedDay(DateTime(2024, 1, 15));
  expect(notifier.state.value?.focusedDay, DateTime(2024, 1, 15));
});
```

### 3. Improved Performance
- Smaller state objects mean fewer unnecessary rebuilds
- More granular state updates
- Better memory management

### 4. Easier Debugging
- Clear separation of concerns makes it easier to identify issues
- Smaller codebases are easier to reason about
- Better error isolation

### 5. Better Maintainability
- Changes to calendar logic don't affect schedule data logic
- Easier to add new features
- Reduced coupling between different concerns

## Migration Strategy

### Phase 1: Create New Notifiers
1. ✅ Create individual state classes (`CalendarUiState`, `ScheduleDataUiState`, etc.)
2. ✅ Create individual notifiers (`CalendarNotifier`, `ScheduleDataNotifier`, etc.)
3. ✅ Create coordinator notifier (`ScheduleCoordinatorNotifier`)

### Phase 2: Update Providers
1. ✅ Update `riverpod_providers.dart` to include new notifiers
2. ✅ Ensure all dependencies are properly injected

### Phase 3: Update UI Components
1. ✅ Create example refactored calendar view
2. 🔄 Update existing UI components to use new notifiers
3. 🔄 Test all functionality

### Phase 4: Remove Old Code
1. 🔄 Remove old `ScheduleNotifier`
2. 🔄 Clean up unused imports and dependencies
3. 🔄 Update documentation

## Usage Examples

### Using Individual Notifiers
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only calendar state
    final calendarState = ref.watch(calendarNotifierProvider);
    
    return Text('Selected: ${calendarState.value?.selectedDay}');
  }
}
```

### Using Coordinator for Complex Operations
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch combined state
    final scheduleState = ref.watch(scheduleCoordinatorNotifierProvider);
    
    return ElevatedButton(
      onPressed: () {
        // Complex operation that affects multiple notifiers
        ref.read(scheduleCoordinatorNotifierProvider.notifier)
           .setActiveConfig(someConfig);
      },
      child: Text('Set Active Config'),
    );
  }
}
```

### Direct Access to Individual Notifiers
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // Direct access to specific notifier
        ref.read(calendarNotifierProvider.notifier)
           .setFocusedDay(DateTime.now());
      },
      child: Text('Go to Today'),
    );
  }
}
```

## File Structure

```
lib/presentation/state/
├── calendar/
│   ├── calendar_ui_state.dart
│   ├── calendar_ui_state.freezed.dart
│   └── calendar_notifier.dart
├── schedule_data/
│   ├── schedule_data_ui_state.dart
│   ├── schedule_data_ui_state.freezed.dart
│   └── schedule_data_notifier.dart
├── config/
│   ├── config_ui_state.dart
│   ├── config_ui_state.freezed.dart
│   └── config_notifier.dart
├── partner/
│   ├── partner_ui_state.dart
│   ├── partner_ui_state.freezed.dart
│   └── partner_notifier.dart
└── schedule/
    ├── schedule_ui_state.dart (existing)
    ├── schedule_ui_state.freezed.dart (existing)
    └── schedule_coordinator_notifier.dart
```

## Testing Strategy

### Unit Tests
Each notifier should have comprehensive unit tests:

```dart
group('CalendarNotifier', () {
  test('should initialize with current date', () async {
    final notifier = CalendarNotifier();
    final state = await notifier.build();
    expect(state.selectedDay, isNotNull);
    expect(state.focusedDay, isNotNull);
  });
  
  test('should update focused day', () async {
    final notifier = CalendarNotifier();
    await notifier.setFocusedDay(DateTime(2024, 1, 15));
    expect(notifier.state.value?.focusedDay, DateTime(2024, 1, 15));
  });
});
```

### Integration Tests
Test the coordinator notifier to ensure proper orchestration:

```dart
group('ScheduleCoordinatorNotifier', () {
  test('should coordinate between notifiers', () async {
    final coordinator = ScheduleCoordinatorNotifier();
    await coordinator.setActiveConfig(someConfig);
    
    // Verify that both config and schedule data notifiers are updated
    expect(coordinator.state.value?.activeConfig, someConfig);
    expect(coordinator.state.value?.schedules, isNotEmpty);
  });
});
```

## Performance Considerations

### 1. State Updates
- Each notifier only updates its own state
- Reduces unnecessary rebuilds
- More granular state management

### 2. Memory Usage
- Smaller state objects
- Better garbage collection
- Reduced memory footprint

### 3. Loading States
- Individual loading states for different operations
- Better user feedback
- More responsive UI

## Best Practices

### 1. Use Coordinator for Complex Operations
When an operation affects multiple notifiers, use the coordinator:

```dart
// Good: Use coordinator for complex operations
ref.read(scheduleCoordinatorNotifierProvider.notifier)
   .setActiveConfig(config);

// Avoid: Manually coordinating between notifiers
ref.read(configNotifierProvider.notifier).setActiveConfig(config);
ref.read(scheduleDataNotifierProvider.notifier).updateActiveConfigName(config.name);
```

### 2. Watch Specific Notifiers
Only watch the notifiers you need:

```dart
// Good: Watch only what you need
final calendarState = ref.watch(calendarNotifierProvider);

// Avoid: Watching everything
final allState = ref.watch(scheduleCoordinatorNotifierProvider);
```

### 3. Handle Loading States
Always handle loading and error states:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final calendarState = ref.watch(calendarNotifierProvider);
  
  return calendarState.when(
    data: (state) => MyWidget(state: state),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => ErrorWidget(error),
  );
}
```

## Conclusion

This refactoring significantly improves the codebase by:
- Following SOLID principles
- Improving testability
- Enhancing maintainability
- Better performance
- Clearer separation of concerns

The new architecture makes it much easier to add new features, fix bugs, and understand the codebase.
