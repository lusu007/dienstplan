import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dienstplan/core/constants/prefs_keys.dart';
import 'package:dienstplan/core/constants/locale_constants.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = kPrefsKeyLanguage;
  late SharedPreferences _prefs;
  Locale _currentLocale = const Locale(kDefaultLanguageCode);

  Locale get currentLocale => _currentLocale;

  List<Locale> get supportedLocales => const <Locale>[Locale('de')];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final String? savedLanguage = _prefs.getString(_languageKey);
    if (savedLanguage == null) {
      return;
    }
    if (savedLanguage != kDefaultLanguageCode) {
      _currentLocale = const Locale(kDefaultLanguageCode);
      await _prefs.setString(_languageKey, kDefaultLanguageCode);
      notifyListeners();
      return;
    }
    _currentLocale = Locale(savedLanguage);
    notifyListeners();
  }

  Future<void> loadSavedLocale() async {
    await initialize();
  }

  Future<void> resetToDefault() async {
    _currentLocale = const Locale('de');
    await _prefs.setString(_languageKey, kDefaultLanguageCode);
    notifyListeners();
  }
}
