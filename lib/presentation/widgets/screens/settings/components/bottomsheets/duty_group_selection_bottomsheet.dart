import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class DutyGroupSelectionBottomsheet extends StatelessWidget {
  final String title;
  final List<String> dutyGroups;
  final String? selectedDutyGroup;
  final Function(String?) onDutyGroupSelected;
  final bool showNoGroupOption;
  final String? noGroupTitle;
  final double? heightPercentage;

  const DutyGroupSelectionBottomsheet({
    super.key,
    required this.title,
    required this.dutyGroups,
    required this.selectedDutyGroup,
    required this.onDutyGroupSelected,
    this.showNoGroupOption = false,
    this.noGroupTitle,
    this.heightPercentage,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<String> dutyGroups,
    required String? selectedDutyGroup,
    required Function(String?) onDutyGroupSelected,
    bool showNoGroupOption = false,
    String? noGroupTitle,
    double? heightPercentage,
  }) {
    return GenericBottomsheet.show(
      context: context,
      title: title,
      heightPercentage: heightPercentage,
      children: [
        _buildDutyGroupList(
          context,
          dutyGroups,
          selectedDutyGroup,
          onDutyGroupSelected,
          showNoGroupOption,
          noGroupTitle,
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
        _buildDutyGroupList(
          context,
          dutyGroups,
          selectedDutyGroup,
          onDutyGroupSelected,
          showNoGroupOption,
          noGroupTitle,
        ),
      ],
    );
  }

  static Widget _buildDutyGroupList(
    BuildContext context,
    List<String> dutyGroups,
    String? selectedDutyGroup,
    Function(String?) onDutyGroupSelected,
    bool showNoGroupOption,
    String? noGroupTitle,
  ) {
    final l10n = AppLocalizations.of(context);

    if (dutyGroups.isEmpty) {
      return Center(
        child: Text(
          'No duty groups available',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dutyGroups.length + (showNoGroupOption ? 1 : 0),
      itemBuilder: (context, index) {
        // Show "No Group" option at the end if enabled
        if (showNoGroupOption && index == dutyGroups.length) {
          return SelectionCard(
            title: noGroupTitle ?? l10n.noDutyGroup,
            isSelected: (selectedDutyGroup ?? '').isEmpty,
            onTap: () {
              Navigator.of(context).pop();
              onDutyGroupSelected(null);
            },
            mainColor: AppColors.primary,
            useDialogStyle: true,
          );
        }

        final group = dutyGroups[index];
        return SelectionCard(
          title: group,
          isSelected: selectedDutyGroup == group,
          onTap: () {
            Navigator.of(context).pop();
            onDutyGroupSelected(group);
          },
          mainColor: AppColors.primary,
          useDialogStyle: true,
        );
      },
    );
  }
}
