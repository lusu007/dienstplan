import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

class GenericBottomsheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double? heightPercentage;
  final bool showHandleBar;

  const GenericBottomsheet({
    super.key,
    required this.title,
    required this.children,
    this.heightPercentage,
    this.showHandleBar = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    double? heightPercentage,
    bool showHandleBar = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenericBottomsheet(
        title: title,
        heightPercentage: heightPercentage,
        showHandleBar: showHandleBar,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heightPercentage = this.heightPercentage ?? 0.8; // Default 80%
    final height = screenHeight * heightPercentage;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          if (showHandleBar)
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          // Content - use Expanded to fill remaining space
          if (children.isNotEmpty)
            Expanded(
              child: children.length == 1
                  ? children.first
                  : Column(mainAxisSize: MainAxisSize.min, children: children),
            ),

          // Bottom padding for safe area
          const SizedBox(height: 16),
        ],
      ),
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return SelectionCard(
          title: item.title,
          subtitle: item.subtitle,
          isSelected: selectedValue == item.value,
          onTap: () {
            Navigator.of(context).pop();
            onItemSelected(item.value);
          },
          mainColor: AppColors.primary,
          useDialogStyle: true,
        );
      },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}
