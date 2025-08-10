import 'package:dienstplan/core/constants/my_accent_palette.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

extension MyAccentColorExtensions on MyAccentColor {
  String toLabel(AppLocalizations l10n) {
    switch (this) {
      case MyAccentColor.primaryBlue:
        return l10n.accentPrimaryBlue;
      case MyAccentColor.amber:
        return l10n.accentWarmOrange;
      case MyAccentColor.purple:
        return l10n.accentViolet;
      case MyAccentColor.green:
        return l10n.accentFreshGreen;
      case MyAccentColor.pink:
        return l10n.accentPink;
      case MyAccentColor.teal:
        return l10n.accentTurquoiseGreen;
      case MyAccentColor.indigo:
        return l10n.accentSunnyYellow;
      case MyAccentColor.red:
        return l10n.accentRed;
      case MyAccentColor.blueGrey:
        return l10n.accentLightGrey;
    }
  }
}
