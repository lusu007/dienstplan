import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/accent_color_bottomsheet_helper.dart';

class HolidayColorBottomsheet {
  static void show(BuildContext context, {double? heightPercentage}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final l10n = AppLocalizations.of(context);

          return AccentColorBottomsheetHelper.buildColorBottomsheet(
            context: context,
            ref: ref,
            stateProvider: ref.watch(settingsProvider),
            selectedColorGetter: (state) => state?.holidayAccentColorValue,
            defaultColorValue: AccentColorDefaults.holidayAccentColorValue,
            title: l10n.holidayAccentColor,
            onColorSelected: (colorValue) async {
              await ref
                  .read(settingsProvider.notifier)
                  .setHolidayAccentColor(colorValue);
            },
            heightPercentage: heightPercentage,
          );
        },
      ),
    );
  }
}
