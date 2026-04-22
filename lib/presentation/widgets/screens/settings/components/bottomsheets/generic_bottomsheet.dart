import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';

/// Thin compatibility wrapper around [GlassBottomSheet] so the many existing
/// call sites in the settings bottom sheets don't need to change.
class GenericBottomsheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double? heightPercentage;
  final bool showHandleBar;
  final bool shrinkToContent;

  const GenericBottomsheet({
    super.key,
    required this.title,
    required this.children,
    this.heightPercentage,
    this.showHandleBar = true,
    this.shrinkToContent = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    double? heightPercentage,
    bool showHandleBar = true,
    bool shrinkToContent = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      clipBehavior: Clip.antiAlias,
      builder: (context) => GenericBottomsheet(
        title: title,
        heightPercentage: heightPercentage,
        showHandleBar: showHandleBar,
        shrinkToContent: shrinkToContent,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomSheet(
      title: title,
      heightPercentage: heightPercentage,
      showHandleBar: showHandleBar,
      shrinkToContent: shrinkToContent,
      children: children,
    );
  }
}

// Helper class for simple selection items
class SelectionItem {
  final String title;
  final String? subtitle;
  final String value;

  const SelectionItem({
    required this.title,
    this.subtitle,
    required this.value,
  });
}

// Helper widget for simple selection lists
class SelectionList extends StatelessWidget {
  final List<SelectionItem> items;
  final String? selectedValue;
  final Function(String?) onItemSelected;

  const SelectionList({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final SelectionItem item in items)
            SelectionCard(
              title: item.title,
              subtitle: item.subtitle,
              isSelected: selectedValue == item.value,
              onTap: () {
                onItemSelected(item.value);
              },
              useDialogStyle: true,
            ),
        ],
      ),
    );
  }
}

// Helper widget for grid layouts (like color selection)
class GridContent extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const GridContent({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
