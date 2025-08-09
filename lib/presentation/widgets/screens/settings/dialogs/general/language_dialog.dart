import 'package:flutter/material.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';

class LanguageDialog {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageService = GetIt.instance<LanguageService>();

    showDialog(
      context: context,
      builder: (context) => Consumer(
          builder: (context, ref, _) => AlertDialog(
                title: Text(l10n.selectLanguage),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectionCard(
                      title: l10n.german,
                      isSelected:
                          languageService.currentLocale.languageCode == 'de',
                      onTap: () async {
                        languageService.setLanguage('de');
                        await ref
                            .read(settingsNotifierProvider.notifier)
                            .setLanguage('de');
                        if (context.mounted) Navigator.pop(context);
                      },
                      mainColor: AppColors.primary,
                      useDialogStyle: true,
                    ),
                    SelectionCard(
                      title: l10n.english,
                      isSelected:
                          languageService.currentLocale.languageCode == 'en',
                      onTap: () async {
                        languageService.setLanguage('en');
                        await ref
                            .read(settingsNotifierProvider.notifier)
                            .setLanguage('en');
                        if (context.mounted) Navigator.pop(context);
                      },
                      mainColor: AppColors.primary,
                      useDialogStyle: true,
                    ),
                  ],
                ),
              )),
    );
  }
}
