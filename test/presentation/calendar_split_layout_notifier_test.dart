import 'package:dienstplan/core/constants/prefs_keys.dart';
import 'package:dienstplan/presentation/state/calendar/calendar_split_layout_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CalendarSplitLayoutNotifier', () {
    test('hydrateFromPrefs reads stored true', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        kPrefsKeyCalendarSplitLayout: true,
      });
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      await container
          .read(calendarSplitLayoutProvider.notifier)
          .hydrateFromPrefs();
      expect(container.read(calendarSplitLayoutProvider), true);
    });

    test('hydrateFromPrefs reads stored false', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        kPrefsKeyCalendarSplitLayout: false,
      });
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      await container
          .read(calendarSplitLayoutProvider.notifier)
          .hydrateFromPrefs();
      expect(container.read(calendarSplitLayoutProvider), false);
    });

    test('hydrateFromPrefs uses false when key is absent', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      await container
          .read(calendarSplitLayoutProvider.notifier)
          .hydrateFromPrefs();
      expect(container.read(calendarSplitLayoutProvider), false);
    });

    test('setSplitLayout persists true to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      await container
          .read(calendarSplitLayoutProvider.notifier)
          .setSplitLayout(true);
      expect(container.read(calendarSplitLayoutProvider), true);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kPrefsKeyCalendarSplitLayout), true);
    });

    test('setSplitLayout persists false to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        kPrefsKeyCalendarSplitLayout: true,
      });
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      await container
          .read(calendarSplitLayoutProvider.notifier)
          .hydrateFromPrefs();
      await container
          .read(calendarSplitLayoutProvider.notifier)
          .setSplitLayout(false);
      expect(container.read(calendarSplitLayoutProvider), false);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(kPrefsKeyCalendarSplitLayout), false);
    });
  });
}
