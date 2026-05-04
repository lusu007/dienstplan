import 'package:dienstplan/presentation/state/calendar/calendar_notifier.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_ui_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarNotifier', () {
    test(
      'selectFocusedDay updates selected and focused day with one emit',
      () async {
        final ProviderContainer container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(calendarProvider.future);

        int emits = 0;
        final ProviderSubscription<AsyncValue<CalendarUiState>> subscription =
            container.listen(calendarProvider, (_, _) {
              emits++;
            });
        addTearDown(subscription.close);

        final DateTime selectedDay = DateTime(2026, 5, 4);
        final DateTime focusedDay = DateTime(2026, 5, 1);

        await container
            .read(calendarProvider.notifier)
            .selectFocusedDay(selectedDay: selectedDay, focusedDay: focusedDay);

        final CalendarUiState state = container.read(calendarProvider).value!;
        expect(state.selectedDay, selectedDay);
        expect(state.focusedDay, focusedDay);
        expect(emits, 1);
      },
    );
  });
}
