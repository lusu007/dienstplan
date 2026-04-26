import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';

@RoutePage()
class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextStyle? bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(height: 1.5);
    return GlassScreenScaffold(
      title: l10n.disclaimer,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          glassSpacingXl - 4,
          glassSpacingXl - 4,
          glassSpacingXl - 4,
          glassSpacingXxl,
        ),
        child: SelectionArea(
          child: Text(l10n.disclaimerLong, style: bodyStyle),
        ),
      ),
    );
  }
}
