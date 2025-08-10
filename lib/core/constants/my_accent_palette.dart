import 'package:flutter/material.dart';

enum MyAccentColor {
  // Primary blue as default
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
  const MyAccentColor(this.argb, this.l10nKey);

  Color toColor() => Color(argb);

  static MyAccentColor? fromValue(int? value) {
    if (value == null) return null;
    for (final MyAccentColor c in MyAccentColor.values) {
      if (c.argb == value) return c;
    }
    return null;
  }
}

// Default my accent color - primary blue
const int kDefaultMyAccentColorValue = 0xFF005B8C; // primary blue
const Color kDefaultMyAccentColor = Color(kDefaultMyAccentColorValue);
