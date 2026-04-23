import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

export 'generic_bottomsheet.dart' show SelectionItem;

class SelectionBottomsheet extends StatelessWidget {
  final String title;
  final List<SelectionItem> items;
  final String? selectedValue;
  final Function(String?) onItemSelected;

  const SelectionBottomsheet({
    super.key,
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onItemSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<SelectionItem> items,
    required String? selectedValue,
    required Function(String?) onItemSelected,
  }) {
    return GenericBottomsheet.show(
      context: context,
      title: title,
      shrinkToContent: true,
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
      shrinkToContent: true,
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
