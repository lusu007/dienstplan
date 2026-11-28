import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/app_typography.dart';
import 'package:dienstplan/presentation/widgets/common/release_change_row.dart';
import 'package:dienstplan/data/releases/app_release_notes.dart';
import 'package:dienstplan/domain/models/release_notes.dart';
import 'package:dienstplan/presentation/screens/release_history_screen.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:dienstplan/presentation/widgets/common/glass_app_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Manual preview defaults to the latest installed release. The upgrade host
/// supplies every unseen release, so skipping versions never loses highlights.
Future<void> showWhatsNewDialog(
  BuildContext context, {
  List<AppReleaseNotes>? releases,
  String? currentVersion,
}) async {
  final installed =
      currentVersion ?? (await PackageInfo.fromPlatform()).version;
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  final highlights = releaseHighlights(
    releases ??
        releaseHistory(current: installed, releases: appReleaseNotes).take(1),
  );
  await GlassAppDialog.show<void>(
    context: context,
    adaptToCompactHeight: true,
    title: l10n.whatsNewTitle,
    content: _ReleaseSummaryContent(highlights: highlights),
    actions: [
      AppGlassButton(
        role: AppGlassButtonRole.quiet,
        fullWidth: true,
        height: 48,
        onPressed: () => showReleaseHistory(context, currentVersion: installed),
        child: Text(l10n.releaseHistoryTitle),
      ),
      AppGlassButton(
        role: AppGlassButtonRole.secondary,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        height: 48,
        fullWidth: true,
        child: Center(child: Text(l10n.whatsNewGotIt)),
      ),
    ],
  );
}

class _ReleaseSummaryContent extends StatelessWidget {
  const _ReleaseSummaryContent({required this.highlights});

  final List<ReleaseChange> highlights;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            highlights.isEmpty ? l10n.whatsNewEmpty : l10n.whatsNewIntro,
            style: AppTypography.secondary(theme),
          ),
          for (final importance in [
            ReleaseImportance.feature,
            ReleaseImportance.fix,
          ])
            if (highlights.any(
              (change) => change.importance == importance,
            )) ...[
              const SizedBox(height: glassSpacingXl),
              Semantics(
                header: true,
                child: Text(
                  importance == ReleaseImportance.feature
                      ? l10n.releaseNotesNew
                      : l10n.releaseNotesImproved,
                  style: AppTypography.menuTitle(theme),
                ),
              ),
              const SizedBox(height: glassSpacingMd),
              for (final change in highlights.where(
                (change) => change.importance == importance,
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: glassSpacingLg),
                  child: ReleaseChangeRow(change: change),
                ),
            ],
        ],
      ),
    );
  }
}
