import 'package:dienstplan/core/constants/partner_accent_palette.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

extension PartnerAccentColorX on PartnerAccentColor {
  String toLabel(AppLocalizations l10n) {
    switch (this) {
      case PartnerAccentColor.amber:
        return l10n.accentWarmOrange;
      case PartnerAccentColor.purple:
        return l10n.accentViolet;
      case PartnerAccentColor.green:
        return l10n.accentFreshGreen;
      case PartnerAccentColor.pink:
        return l10n.accentPink;
      case PartnerAccentColor.teal:
        return l10n.accentTurquoiseGreen;
      case PartnerAccentColor.indigo:
        return l10n.accentSunnyYellow;
      case PartnerAccentColor.red:
        return l10n.accentRed;
      case PartnerAccentColor.blueGrey:
        return l10n.accentLightGrey;
    }
  }
}
