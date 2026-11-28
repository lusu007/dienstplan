import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/domain/models/release_notes.dart';
import 'package:dienstplan/presentation/widgets/common/app_typography.dart';
import 'package:material_ui/material_ui.dart';

/// Shared readable content, transparent inside a dialog or a glass list group.
class ReleaseChangeRow extends StatelessWidget {
  const ReleaseChangeRow({super.key, required this.change});

  final ReleaseChange change;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (change.importance) {
      ReleaseImportance.feature => Icons.add_circle_outline_rounded,
      ReleaseImportance.fix => Icons.build_outlined,
      ReleaseImportance.maintenance => Icons.refresh_rounded,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ExcludeSemantics(
            child: Icon(
              icon,
              size: 22,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: glassSpacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  change.title,
                  style: AppTypography.menuTitle(theme),
                ),
              ),
              const SizedBox(height: glassSpacingXs),
              Text(
                change.description,
                style: AppTypography.secondary(theme).copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
