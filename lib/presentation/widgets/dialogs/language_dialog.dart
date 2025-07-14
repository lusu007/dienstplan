import 'package:flutter/material.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/dialogs/dialog_selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:get_it/get_it.dart';

class LanguageDialog {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageService = GetIt.instance<LanguageService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogSelectionCard(
              title: l10n.german,
              isSelected: languageService.currentLocale.languageCode == 'de',
              onTap: () {
                languageService.setLanguage('de');
                Navigator.pop(context);
              },
              mainColor: AppColors.primary,
            ),
            DialogSelectionCard(
              title: l10n.english,
              isSelected: languageService.currentLocale.languageCode == 'en',
              onTap: () {
                languageService.setLanguage('en');
                Navigator.pop(context);
              },
              mainColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
