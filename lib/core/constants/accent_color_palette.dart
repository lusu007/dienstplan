import 'package:flutter/material.dart';

enum AccentColor {
  // Primary blue as first color
  primaryBlue(0xFF005B8C, 'accentPrimaryBlue'), // Primäres Blau
  // Additional colors for variety
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
  const AccentColor(this.argb, this.l10nKey);

  Color toColor() => Color(argb);

  static AccentColor? fromValue(int? value) {
    if (value == null) return null;
    for (final AccentColor c in AccentColor.values) {
      if (c.argb == value) return c;
    }
    return null;
  }
}

// Default colors for different contexts
class AccentColorDefaults {
  // My accent color default - primary blue
  static const int myAccentColorValue = 0xFF005B8C; // primary blue
  static const Color myAccentColor = Color(myAccentColorValue);

  // Partner accent color default - turquoise green
  static const int partnerAccentColorValue = 0xFF00B89F; // teal (Türkisgrün)
  static const Color partnerAccentColor = Color(partnerAccentColorValue);
}
