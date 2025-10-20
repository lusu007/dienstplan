import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/color_selection_card.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class ColorSelectionBottomsheet extends StatelessWidget {
  final String title;
  final List<AccentColor> colors;
  final int selectedColorValue;
  final Function(int) onColorSelected;
  final double? heightPercentage;

  const ColorSelectionBottomsheet({
    super.key,
    required this.title,
    required this.colors,
    required this.selectedColorValue,
    required this.onColorSelected,
    this.heightPercentage,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<AccentColor> colors,
    required int selectedColorValue,
    required Function(int) onColorSelected,
    double? heightPercentage,
  }) {
    return GenericBottomsheet.show(
      context: context,
      title: title,
      heightPercentage: heightPercentage,
      children: [
        _buildColorGrid(context, colors, selectedColorValue, onColorSelected),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GenericBottomsheet(
      title: title,
      heightPercentage: heightPercentage,
      children: [
        _buildColorGrid(context, colors, selectedColorValue, onColorSelected),
      ],
    );
  }

  static Widget _buildColorGrid(
    BuildContext context,
    List<AccentColor> colors,
    int selectedColorValue,
    Function(int) onColorSelected,
  ) {
    final l10n = AppLocalizations.of(context);

    return GridContent(
      crossAxisCount: 3,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: 1.0,
      children: colors.map((color) {
        return ColorSelectionCard(
          color: color.toColor(),
          colorName: _getLocalizedColorNameStatic(color, l10n),
          isSelected: selectedColorValue == color.argb,
          onTap: () {
            Navigator.of(context).pop();
            onColorSelected(color.argb);
          },
        );
      }).toList(),
    );
  }

  static String _getLocalizedColorNameStatic(
    AccentColor color,
    AppLocalizations l10n,
  ) {
    switch (color.l10nKey) {
      case 'accentPrimaryBlue':
        return l10n.accentPrimaryBlue;
      case 'accentWarmOrange':
        return l10n.accentWarmOrange;
      case 'accentPink':
        return l10n.accentPink;
      case 'accentViolet':
        return l10n.accentViolet;
      case 'accentFreshGreen':
        return l10n.accentFreshGreen;
      case 'accentTurquoiseGreen':
        return l10n.accentTurquoiseGreen;
      case 'accentSunnyYellow':
        return l10n.accentSunnyYellow;
      case 'accentRed':
        return l10n.accentRed;
      case 'accentLightGrey':
        return l10n.accentLightGrey;
      default:
        return color.name;
    }
  }
}
