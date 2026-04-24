import 'package:flutter/material.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/selection_bottomsheet.dart';

class LanguageBottomsheet {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final languageAsync = ref.watch(languageServiceProvider);
          return languageAsync.when(
            loading: () => GenericBottomsheet(
              title: l10n.selectLanguage,
              shrinkToContent: true,
              children: const [
                SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            error: (e, st) => GenericBottomsheet(
              title: l10n.selectLanguage,
              shrinkToContent: true,
              children: [
                SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(l10n.errorLoading, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
            data: (languageService) {
              final currentLanguage =
                  languageService.currentLocale.languageCode;
              return SelectionBottomsheet(
                title: l10n.selectLanguage,
                items: [
                  SelectionItem(title: l10n.german, value: 'de'),
                  SelectionItem(title: l10n.english, value: 'en'),
                ],
                selectedValue: currentLanguage,
                onItemSelected: (language) async {
                  if (language != null) {
                    languageService.setLanguage(language);
                    await ref
                        .read(settingsProvider.notifier)
                        .setLanguage(language);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
