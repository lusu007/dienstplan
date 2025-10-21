import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/accent_color_bottomsheet_helper.dart';

class PartnerColorBottomsheet {
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
            stateProvider: ref.watch(scheduleCoordinatorProvider),
            selectedColorGetter: (state) => state?.partnerAccentColorValue,
            defaultColorValue: AccentColorDefaults.partnerAccentColorValue,
            title: l10n.accentColor,
            onColorSelected: (colorValue) async {
              await ref
                  .read(scheduleCoordinatorProvider.notifier)
                  .setPartnerAccentColor(colorValue);
            },
            heightPercentage: heightPercentage,
          );
        },
      ),
    );
  }
}
