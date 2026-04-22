import 'package:flutter_riverpod/flutter_riverpod.dart';

/// View-only toggle that controls whether partner duty abbreviations are
/// rendered in the calendar cells.
///
/// This does NOT mutate the persisted partner configuration in settings — it
/// only hides or shows the partner layer in the current calendar view.
class CalendarPartnerVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }

  void show() {
    state = true;
  }

  void hide() {
    state = false;
  }
}

final calendarPartnerVisibilityProvider =
    NotifierProvider<CalendarPartnerVisibilityNotifier, bool>(
      CalendarPartnerVisibilityNotifier.new,
    );
