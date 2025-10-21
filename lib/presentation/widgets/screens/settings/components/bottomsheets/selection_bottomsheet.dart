import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class SelectionBottomsheet extends StatelessWidget {
  final String title;
  final List<SelectionItem> items;
  final String? selectedValue;
  final Function(String?) onItemSelected;
  final double? heightPercentage;

  const SelectionBottomsheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onItemSelected,
    this.heightPercentage,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<SelectionItem> items,
    required String? selectedValue,
    required Function(String?) onItemSelected,
    double? heightPercentage,
  }) {
    return GenericBottomsheet.show(
      context: context,
      title: title,
      heightPercentage: heightPercentage,
      children: [
        SelectionList(
          items: items,
          selectedValue: selectedValue,
          onItemSelected: onItemSelected,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GenericBottomsheet(
      title: title,
      heightPercentage: heightPercentage,
      children: [
        SelectionList(
          items: items,
          selectedValue: selectedValue,
          onItemSelected: onItemSelected,
        ),
      ],
    );
  }
}
