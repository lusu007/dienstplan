import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/domain/entities/settings.dart';

class ThemeModeDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => const _ThemeModeDialogContent(),
    );
  }
}

class _ThemeModeDialogContent extends ConsumerStatefulWidget {
  const _ThemeModeDialogContent();

  @override
  ConsumerState<_ThemeModeDialogContent> createState() =>
      _ThemeModeDialogContentState();
}

class _ThemeModeDialogContentState
    extends ConsumerState<_ThemeModeDialogContent> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(settingsProvider).value;
    final ThemePreference current =
        state?.themePreference ?? ThemePreference.system;

    return AlertDialog(
      title: Text(l10n.themeMode),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context,
            l10n.themeModeLight,
            ThemePreference.light,
            current,
            Icons.light_mode,
          ),
          _buildThemeOption(
            context,
            l10n.themeModeDark,
            ThemePreference.dark,
            current,
            Icons.dark_mode,
          ),
          _buildThemeOption(
            context,
            l10n.themeModeSystem,
            ThemePreference.system,
            current,
            Icons.settings_system_daydream,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    ThemePreference value,
    ThemePreference current,
    IconData icon,
  ) {
    final isSelected = current == value;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
        onTap: () {
          ref.read(settingsProvider.notifier).setThemePreference(value);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
