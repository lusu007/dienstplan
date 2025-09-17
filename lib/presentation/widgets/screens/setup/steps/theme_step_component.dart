import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/setup_step_wrapper.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/step_header.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class ThemeStepComponent extends ConsumerWidget {
  final ThemePreference selectedTheme;
  final Function(ThemePreference) onThemeChanged;
  final ScrollController scrollController;

  const ThemeStepComponent({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.scrollController,
  });

  Widget _buildThemeCard(IconData icon, String title, ThemePreference pref) {
    final bool isSelected = selectedTheme == pref;
    return SelectionCard(
      title: title,
      leadingIcon: icon,
      isSelected: isSelected,
      onTap: () async {
        final newTheme = selectedTheme == pref ? ThemePreference.system : pref;
        onThemeChanged(newTheme);
      },
      mainColor: AppColors.primary,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SetupStepWrapper(
      scrollController: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepHeader(
            title: l10n.welcome,
            description: l10n.themeModeDescription,
          ),
          _buildThemeCard(
            Icons.wb_sunny_outlined,
            l10n.themeModeLight,
            ThemePreference.light,
          ),
          _buildThemeCard(
            Icons.nightlight_round,
            l10n.themeModeDark,
            ThemePreference.dark,
          ),
          _buildThemeCard(
            Icons.brightness_auto,
            l10n.themeModeSystem,
            ThemePreference.system,
          ),
        ],
      ),
    );
  }
}
