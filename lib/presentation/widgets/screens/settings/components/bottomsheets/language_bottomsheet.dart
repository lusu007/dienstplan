import 'package:flutter/material.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/selection_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class LanguageBottomsheet {
  static void show(BuildContext context, {double? heightPercentage}) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final languageAsync = ref.watch(languageServiceProvider);
          return languageAsync.when(
            loading: () => Container(
              height: heightPercentage != null
                  ? MediaQuery.of(context).size.height * heightPercentage
                  : MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Container(
              height: heightPercentage != null
                  ? MediaQuery.of(context).size.height * heightPercentage
                  : MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(child: Text(l10n.errorLoading)),
            ),
            data: (languageService) {
              final currentLanguage =
                  languageService.currentLocale.languageCode;
              return SelectionBottomsheet(
                title: l10n.selectLanguage,
                heightPercentage: heightPercentage,
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
