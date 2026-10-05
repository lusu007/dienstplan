import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_icon_button.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as liquid;

/// Glass-styled back button used inside the setup flow.
///
/// Matches the back-button in `GlassScreenScaffold` so the setup header feels
/// consistent with the rest of the glass UI.
class SetupBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  /// Unused tint override - kept for backwards compatibility with existing
  /// call sites that still pass `mainColor`. The button now derives its
  /// foreground from the theme.
  final Color? mainColor;
  final double size;

  const SetupBackButton({
    super.key,
    this.onPressed,
    this.mainColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassIconButton(
      icon: Icons.arrow_back_rounded,
      onPressed: onPressed,
      tooltip: AppLocalizations.of(context).back,
      size: size,
      iconSize: 24,
      shape: liquid.GlassIconButtonShape.roundedSquare,
      borderRadius: 16,
    );
  }
}
