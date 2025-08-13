import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

extension AccentColorX on AccentColor {
  String toLabel(AppLocalizations l10n) {
    switch (this) {
      case AccentColor.primaryBlue:
        return l10n.accentPrimaryBlue;
      case AccentColor.amber:
        return l10n.accentWarmOrange;
      case AccentColor.purple:
        return l10n.accentViolet;
      case AccentColor.green:
        return l10n.accentFreshGreen;
      case AccentColor.pink:
        return l10n.accentPink;
      case AccentColor.teal:
        return l10n.accentTurquoiseGreen;
      case AccentColor.indigo:
        return l10n.accentSunnyYellow;
      case AccentColor.red:
        return l10n.accentRed;
      case AccentColor.blueGrey:
        return l10n.accentLightGrey;
    }
  }
}
