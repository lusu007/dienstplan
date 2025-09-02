import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class DutyGroupSelectorWidget extends StatelessWidget {
  final List<String> dutyGroups;
  final String? selectedDutyGroup;
  final Function(String?)? onDutyGroupSelected;
  final bool showAllOption;
  final String? allOptionText;

  const DutyGroupSelectorWidget({
    super.key,
    required this.dutyGroups,
    this.selectedDutyGroup,
    this.onDutyGroupSelected,
    this.showAllOption = true,
    this.allOptionText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mainColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter status text
          Text(
            '${l10n.filteredBy}: ${selectedDutyGroup ?? (allOptionText ?? l10n.all)}',
            style: TextStyle(
              fontSize: 12.0,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),

          // Duty group chips
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              if (showAllOption)
                _buildDutyGroupChip(
                  context,
                  null,
                  allOptionText ?? l10n.all,
                  mainColor,
                ),
              ...dutyGroups.map((group) => _buildDutyGroupChip(
                    context,
                    group,
                    group,
                    mainColor,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDutyGroupChip(
    BuildContext context,
    String? dutyGroup,
    String displayText,
    Color mainColor,
  ) {
    final isSelected = selectedDutyGroup == dutyGroup;

    return FilterChip(
      label: Text(
        displayText,
        style: TextStyle(
          color:
              isSelected ? Theme.of(context).colorScheme.onPrimary : mainColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (onDutyGroupSelected != null) {
          onDutyGroupSelected!(selected ? dutyGroup : null);
        }
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: mainColor,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      side: BorderSide(
        color: isSelected
            ? mainColor
            : Theme.of(context).colorScheme.outlineVariant,
        width: isSelected ? 2 : 1,
      ),
      elevation: isSelected ? 2 : 1,
      pressElevation: 3,
    );
  }
}

class DutyGroupDropdownWidget extends StatelessWidget {
  final List<String> dutyGroups;
  final String? selectedDutyGroup;
  final Function(String?)? onDutyGroupSelected;
  final bool showAllOption;
  final String? allOptionText;
  final String? hintText;

  const DutyGroupDropdownWidget({
    super.key,
    required this.dutyGroups,
    this.selectedDutyGroup,
    this.onDutyGroupSelected,
    this.showAllOption = true,
    this.allOptionText,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<String?>(
        initialValue: selectedDutyGroup,
        decoration: InputDecoration(
          labelText: hintText ?? l10n.selectDutyGroup,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          if (showAllOption)
            DropdownMenuItem<String?>(
              value: null,
              child: Text(allOptionText ?? l10n.all),
            ),
          ...dutyGroups.map((group) => DropdownMenuItem<String?>(
                value: group,
                child: Text(group),
              )),
        ],
        onChanged: onDutyGroupSelected,
      ),
    );
  }
}
