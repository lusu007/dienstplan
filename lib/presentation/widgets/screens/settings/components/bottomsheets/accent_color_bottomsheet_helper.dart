import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/color_selection_bottomsheet.dart';

class AccentColorBottomsheetHelper {
  static Widget buildColorBottomsheet<T>({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<T?> stateProvider,
    required int? Function(T?) selectedColorGetter,
    required int defaultColorValue,
    required String title,
    required Future<void> Function(int) onColorSelected,
    double? heightPercentage,
  }) {
    final state = stateProvider.value;
    final selected = selectedColorGetter(state) ?? defaultColorValue;

    return ColorSelectionBottomsheet(
      title: title,
      colors: AccentColor.values,
      selectedColorValue: selected,
      heightPercentage: heightPercentage,
      onColorSelected: onColorSelected,
    );
  }
}
