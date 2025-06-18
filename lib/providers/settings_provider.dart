import 'package:flutter/foundation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienstplan/models/settings.dart';
import 'package:dienstplan/services/database_service.dart';
import 'package:dienstplan/utils/logger.dart';

class SettingsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  String _language = 'de';

  String get language => _language;

  Future<void> initialize() async {
    try {
      final settings = await _databaseService.loadSettings();
      if (settings != null && settings.language != null) {
        _language = settings.language!;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error loading language settings', e, stackTrace);
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      _language = language;
      final settings = Settings(
        calendarFormat: CalendarFormat.month,
        focusedDay: DateTime.now(),
        selectedDay: DateTime.now(),
        language: language,
      );
      await _databaseService.saveSettings(settings);
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.e('Error saving language settings', e, stackTrace);
    }
  }
}
