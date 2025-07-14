import 'package:flutter/material.dart';

abstract class LanguageServiceInterface {
  Locale get currentLocale;
  List<Locale> get supportedLocales;

  Future<void> setLocale(Locale locale);
  Future<void> loadSavedLocale();
  Future<void> resetToDefault();
}
