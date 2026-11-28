import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/data/releases/app_release_notes.dart';
import 'package:dienstplan/domain/models/release_history_group.dart';
import 'package:dienstplan/presentation/widgets/common/app_typography.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/common/release_change_row.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section_header.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Browsing history is independent of the automatic summary's read state.
Future<void> showReleaseHistory(
  BuildContext context, {
  String? currentVersion,
}) async {
  final installed =
      currentVersion ?? (await PackageInfo.fromPlatform()).version;
  if (!context.mounted) return;
  await Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      builder: (_) => ReleaseHistoryScreen(currentVersion: installed),
    ),
  );
}

class ReleaseHistoryScreen extends StatelessWidget {
  const ReleaseHistoryScreen({super.key, required this.currentVersion});

  final String currentVersion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final history = groupReleaseHistory(
      current: currentVersion,
      releases: appReleaseNotes,
    );
    final theme = Theme.of(context);
    return GlassScreenScaffold(
      title: l10n.releaseHistoryTitle,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              glassSpacingXl - 4,
              glassSpacingMd,
              glassSpacingXl - 4,
              glassSpacingXxl,
            ),
            itemCount: history.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: glassSpacingMd),
                  child: Text(
                    history.isEmpty
                        ? l10n.whatsNewEmpty
                        : l10n.releaseHistoryIntro,
                    style: AppTypography.secondary(theme),
                  ),
                );
              }
              final group = history[index - 1];
              final label = group.isRange
                  ? l10n.releaseVersionRange(
                      group.oldestVersion,
                      group.latestVersion,
                    )
                  : l10n.releaseVersion(group.latestVersion);
              return Padding(
                padding: const EdgeInsets.only(bottom: glassSpacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: SettingsSectionHeader(title: label),
                    ),
                    GlassCardGroup(
                      children: [
                        for (final change in group.changes)
                          GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(glassSpacingLg),
                              child: ReleaseChangeRow(change: change),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
