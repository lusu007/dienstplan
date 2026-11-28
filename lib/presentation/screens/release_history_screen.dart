import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/data/releases/app_release_notes.dart';
import 'package:dienstplan/domain/models/release_notes.dart';
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
    final history = releaseHistory(
      current: currentVersion,
      releases: appReleaseNotes,
    );
    final theme = Theme.of(context);
    return GlassScreenScaffold(
      title: l10n.releaseHistoryTitle,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          glassSpacingXl,
          glassSpacingMd,
          glassSpacingXl,
          glassSpacingXxl,
        ),
        itemCount: history.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: glassSpacingXl),
              child: Text(
                history.isEmpty ? l10n.whatsNewEmpty : l10n.releaseHistoryIntro,
              ),
            );
          }
          final release = history[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: glassSpacingXl),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(glassSurfaceRadiusLg),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(glassSpacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.releaseVersion(release.version),
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    for (final change in release.changes) ...[
                      const SizedBox(height: glassSpacingLg),
                      Text(
                        change.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: glassSpacingXs),
                      Text(change.description),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
