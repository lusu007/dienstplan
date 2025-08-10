import 'package:flutter/material.dart';

enum PartnerAccentColor {
  // Mapped to the requested palette
  // Keep enum case names for backwards compatibility, update values and l10n keys
  amber(0xFFFF7A33, 'accentWarmOrange'), // Warm Orange
  purple(0xFFA55EEA, 'accentViolet'), // Violett
  green(0xFF5FBF3A, 'accentFreshGreen'), // Frisches Grün
  pink(0xFFE94B8C, 'accentPink'), // Pink
  teal(0xFF00B89F, 'accentTurquoiseGreen'), // Türkisgrün
  indigo(0xFFFFC933, 'accentSunnyYellow'), // Sonnengelb
  red(0xFFE74C3C, 'accentRed'), // Rot
  blueGrey(0xFFB0BEC5, 'accentLightGrey'); // Hellgrau

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
const int kDefaultPartnerAccentColorValue = 0xFF00B89F; // teal (Türkisgrün)
const Color kDefaultPartnerAccentColor = Color(kDefaultPartnerAccentColorValue);
