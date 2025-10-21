import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/config_filter_utils.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/police_authority_filter_chips.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class ConfigSelectionBottomsheet extends ConsumerStatefulWidget {
  final String title;
  final List<DutyScheduleConfig> configs;
  final String? selectedConfigName;
  final Function(DutyScheduleConfig?) onConfigSelected;
  final bool showNoConfigOption;
  final String? noConfigTitle;
  final double? heightPercentage;

  const ConfigSelectionBottomsheet({
    super.key,
    required this.title,
    required this.configs,
    required this.selectedConfigName,
    required this.onConfigSelected,
    this.showNoConfigOption = false,
    this.noConfigTitle,
    this.heightPercentage,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<DutyScheduleConfig> configs,
    required String? selectedConfigName,
    required Function(DutyScheduleConfig?) onConfigSelected,
    bool showNoConfigOption = false,
    String? noConfigTitle,
    double? heightPercentage,
  }) {
    return GenericBottomsheet.show(
      context: context,
      title: title,
      heightPercentage: heightPercentage,
      children: [
        ConfigSelectionBottomsheet(
          title: title,
          configs: configs,
          selectedConfigName: selectedConfigName,
          onConfigSelected: onConfigSelected,
          showNoConfigOption: showNoConfigOption,
          noConfigTitle: noConfigTitle,
          heightPercentage: heightPercentage,
        ),
      ],
    );
  }

  @override
  ConsumerState<ConfigSelectionBottomsheet> createState() =>
      _ConfigSelectionBottomsheetState();
}

class _ConfigSelectionBottomsheetState
    extends ConsumerState<ConfigSelectionBottomsheet> {
  late Set<String> _selectedAuthorities;
  late List<DutyScheduleConfig> _filteredConfigs;

  @override
  void initState() {
    super.initState();
    _selectedAuthorities = {};
    _filteredConfigs = widget.configs;
  }

  void _toggleAuthorityFilter(String authority) {
    setState(() {
      if (_selectedAuthorities.contains(authority)) {
        _selectedAuthorities.remove(authority);
      } else {
        _selectedAuthorities.add(authority);
      }
      _updateFilteredConfigs();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedAuthorities.clear();
      _updateFilteredConfigs();
    });
  }

  void _updateFilteredConfigs() {
    _filteredConfigs = ConfigFilterUtils.filterConfigsByAuthorities(
      widget.configs,
      _selectedAuthorities,
    );
  }

  Widget _buildConfigTitle(DutyScheduleConfig config) {
    if (config.meta.policeAuthority != null &&
        config.meta.policeAuthority!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.meta.policeAuthority!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(config.meta.name),
        ],
      );
    }
    return Text(config.meta.name);
  }

  String? _buildConfigSubtitle(DutyScheduleConfig config) {
    return config.meta.description.isNotEmpty ? config.meta.description : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final availableAuthorities = ConfigFilterUtils.extractAvailableAuthorities(
      widget.configs,
    );

    return GenericBottomsheet(
      title: widget.title,
      heightPercentage: widget.heightPercentage,
      children: [
        // Filter chips section
        if (availableAuthorities.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PoliceAuthorityFilterChips(
              availableAuthorities: availableAuthorities,
              selectedAuthorities: _selectedAuthorities,
              onAuthorityToggled: _toggleAuthorityFilter,
              onClearAll: _clearAllFilters,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Config list
        Expanded(
          child: _filteredConfigs.isEmpty
              ? Center(
                  child: Text(
                    l10n.noDutySchedules,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount:
                      _filteredConfigs.length +
                      (widget.showNoConfigOption ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show "No Config" option at the end if enabled
                    if (widget.showNoConfigOption &&
                        index == _filteredConfigs.length) {
                      return SelectionCard(
                        title: widget.noConfigTitle ?? l10n.noDutySchedule,
                        isSelected: (widget.selectedConfigName ?? '').isEmpty,
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onConfigSelected(null);
                        },
                        useDialogStyle: true,
                      );
                    }

                    final config = _filteredConfigs[index];
                    return SelectionCard(
                      title: _buildConfigTitle(config),
                      subtitle: _buildConfigSubtitle(config),
                      isSelected: widget.selectedConfigName == config.name,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onConfigSelected(config);
                      },
                      mainColor: AppColors.primary,
                      useDialogStyle: true,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
