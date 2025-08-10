import 'package:flutter/material.dart';

enum PartnerAccentColor {
  amber(0xFF8C3D00, 'accentAmber'),
  purple(0xFF6A1B9A, 'accentPurple'),
  green(0xFF2E7D32, 'accentGreen'),
  pink(0xFFAD1457, 'accentPink'),
  teal(0xFF00796B, 'accentTeal'),
  indigo(0xFF283593, 'accentIndigo'),
  red(0xFFB71C1C, 'accentRed'),
  blueGrey(0xFF455A64, 'accentBlueGrey');

  final int argb;
  final String l10nKey;
  const PartnerAccentColor(this.argb, this.l10nKey);

  Color toColor() => Color(argb);

  static PartnerAccentColor? fromValue(int? value) {
    if (value == null) return null;
    for (final PartnerAccentColor c in PartnerAccentColor.values) {
      if (c.argb == value) return c;
    }
    return null;
  }
}

// Default partner accent color used when none is selected explicitly
const int kDefaultPartnerAccentColorValue = 0xFF283593; // indigo
const Color kDefaultPartnerAccentColor = Color(kDefaultPartnerAccentColorValue);
