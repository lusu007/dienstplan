import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'language';
  late SharedPreferences _prefs;
  Locale _currentLocale = const Locale('de');

  Locale get currentLocale => _currentLocale;

  List<Locale> get supportedLocales => const [
        Locale('de'),
        Locale('en'),
      ];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs.getString(_languageKey);
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await _prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    await _prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> loadSavedLocale() async {
    await initialize();
  }

  Future<void> resetToDefault() async {
    _currentLocale = const Locale('de');
    await _prefs.setString(_languageKey, 'de');
    notifyListeners();
  }
}
