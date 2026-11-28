import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
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
    title: l10n.whatsNewTitle,
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(highlights.isEmpty ? l10n.whatsNewEmpty : l10n.whatsNewIntro),
          for (final change in highlights) ...[
            const SizedBox(height: glassSpacingLg),
            Semantics(
              header: true,
              child: Text(
                change.title,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: glassSpacingXs),
            Text(change.description),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
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
