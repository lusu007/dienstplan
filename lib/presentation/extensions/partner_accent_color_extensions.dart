import 'package:dienstplan/core/constants/partner_accent_palette.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

extension PartnerAccentColorX on PartnerAccentColor {
  String toLabel(AppLocalizations l10n) {
    switch (this) {
      case PartnerAccentColor.amber:
        return l10n.accentAmber;
      case PartnerAccentColor.purple:
        return l10n.accentPurple;
      case PartnerAccentColor.green:
        return l10n.accentGreen;
      case PartnerAccentColor.pink:
        return l10n.accentPink;
      case PartnerAccentColor.teal:
        return l10n.accentTeal;
      case PartnerAccentColor.indigo:
        return l10n.accentIndigo;
      case PartnerAccentColor.red:
        return l10n.accentRed;
      case PartnerAccentColor.blueGrey:
        return l10n.accentBlueGrey;
    }
  }
}


