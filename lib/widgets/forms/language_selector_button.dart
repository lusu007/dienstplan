import 'package:flutter/material.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/services/language_service.dart';

class LanguageSelectorButton extends StatelessWidget {
  final LanguageService languageService;
  final VoidCallback? onLanguageChanged;
  final bool disabled;

  const LanguageSelectorButton({
    super.key,
    required this.languageService,
    this.onLanguageChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: disabled
            ? null
            : () {
                const locales = LanguageService.supportedLocales;
                final currentIndex =
                    locales.indexOf(languageService.currentLocale);
                final nextIndex = (currentIndex + 1) % locales.length;
                languageService.setLanguage(locales[nextIndex].languageCode);
                onLanguageChanged?.call();
              },
        child: Text(
          languageService.currentLocale.languageCode == 'de'
              ? l10n.german
              : l10n.english,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
