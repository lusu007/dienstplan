import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dienstplan/core/constants/prefs_keys.dart';
import 'package:dienstplan/core/utils/logger.dart';

part 'calendar_split_layout_notifier.g.dart';

@Riverpod(keepAlive: true)
class CalendarSplitLayout extends _$CalendarSplitLayout {
  @override
  bool build() => false;

  Future<void> hydrateFromPrefs() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(kPrefsKeyCalendarSplitLayout) ?? false;
    } catch (e, st) {
      AppLogger.e('Failed to hydrate calendar split layout preference', e, st);
    }
  }

  Future<void> setSplitLayout(bool value) async {
    state = value;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kPrefsKeyCalendarSplitLayout, value);
    } catch (e, st) {
      AppLogger.e(
        'Failed to persist calendar split layout preference (value=$value)',
        e,
        st,
      );
    }
  }
}
