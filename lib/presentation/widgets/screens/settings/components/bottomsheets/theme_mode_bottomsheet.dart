import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_theme.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

class ThemeModeBottomsheet {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    await liquid.GlassSheet.show<void>(
      context: context,
      quality: liquid.GlassQuality.standard,
      settings: appGlassSettings(context, blur: glassSurfaceBlurBottomSheet),
      padding: EdgeInsets.zero,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(settingsProvider).value;
          final current = state?.themePreference ?? ThemePreference.system;

          return Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    glassSpacingLg,
                    glassSpacingLg,
                    glassSpacingLg,
                    glassSpacingSm,
                  ),
                  child: Text(
                    l10n.themeMode,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SelectionList(
                  items: [
                    SelectionItem(
                      title: l10n.themeModeLight,
                      value: ThemePreference.light.name,
                    ),
                    SelectionItem(
                      title: l10n.themeModeDark,
                      value: ThemePreference.dark.name,
                    ),
                    SelectionItem(
                      title: l10n.themeModeSystem,
                      value: ThemePreference.system.name,
                    ),
                  ],
                  selectedValue: current.name,
                  onItemSelected: (themeName) async {
                    if (themeName != null) {
                      ThemePreference preference;
                      switch (themeName) {
                        case 'light':
                          preference = ThemePreference.light;
                          break;
                        case 'dark':
                          preference = ThemePreference.dark;
                          break;
                        case 'system':
                          preference = ThemePreference.system;
                          break;
                        default:
                          preference = ThemePreference.system;
                      }
                      await ref
                          .read(settingsProvider.notifier)
                          .setThemePreference(preference);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
