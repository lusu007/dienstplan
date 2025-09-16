import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/step_header.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/skeleton_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/config_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/police_authority_filter_chips.dart';
import 'package:dienstplan/presentation/widgets/common/error_display.dart';

class ConfigSelectionStepComponent extends StatelessWidget {
  final List<DutyScheduleConfig> configs;
  final DutyScheduleConfig? selectedConfig;
  final Function(DutyScheduleConfig?) onConfigChanged;
  final bool isLoading;
  final Object? loadingError;
  final StackTrace? loadingErrorStackTrace;
  final VoidCallback onRetry;
  final ScrollController scrollController;
  final Set<String> selectedPoliceAuthorities;
  final Function(String) onPoliceAuthorityToggled;
  final VoidCallback onClearAllFilters;

  const ConfigSelectionStepComponent({
    super.key,
    required this.configs,
    required this.selectedConfig,
    required this.onConfigChanged,
    required this.isLoading,
    this.loadingError,
    this.loadingErrorStackTrace,
    required this.onRetry,
    required this.scrollController,
    required this.selectedPoliceAuthorities,
    required this.onPoliceAuthorityToggled,
    required this.onClearAllFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Get available police authorities from configs
    final availableAuthorities = configs
        .map((config) => config.meta.policeAuthority)
        .where((authority) => authority != null && authority.isNotEmpty)
        .cast<String>()
        .toSet();

    // Filter configs based on selected authorities
    final filteredConfigs = selectedPoliceAuthorities.isEmpty
        ? configs
        : configs
            .where((config) =>
                config.meta.policeAuthority != null &&
                selectedPoliceAuthorities.contains(config.meta.policeAuthority))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed header section
        StepHeader(
          title: l10n.myDutySchedule,
          description: l10n.welcomeMessage,
        ),

        // Fixed filter section (if available)
        if (availableAuthorities.isNotEmpty &&
            !isLoading &&
            loadingError == null) ...[
          PoliceAuthorityFilterChips(
            availableAuthorities: availableAuthorities,
            selectedAuthorities: selectedPoliceAuthorities,
            onAuthorityToggled: onPoliceAuthorityToggled,
            onClearAll: onClearAllFilters,
          ),
          const SizedBox(height: 16),
        ],

        // Scrollable content section
        Expanded(
          child: _buildScrollableContent(
            isLoading: isLoading,
            loadingError: loadingError,
            loadingErrorStackTrace: loadingErrorStackTrace,
            onRetry: onRetry,
            filteredConfigs: filteredConfigs,
            selectedConfig: selectedConfig,
            onConfigChanged: onConfigChanged,
            scrollController: scrollController,
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableContent({
    required bool isLoading,
    required Object? loadingError,
    required StackTrace? loadingErrorStackTrace,
    required VoidCallback onRetry,
    required List<DutyScheduleConfig> filteredConfigs,
    required DutyScheduleConfig? selectedConfig,
    required Function(DutyScheduleConfig?) onConfigChanged,
    required ScrollController scrollController,
  }) {
    if (isLoading) {
      return SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: List.generate(3, (index) => const SkeletonCard()),
        ),
      );
    }

    if (loadingError != null) {
      return SingleChildScrollView(
        controller: scrollController,
        child: ErrorDisplay(
          error: loadingError,
          stackTrace: loadingErrorStackTrace,
          onRetry: onRetry,
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: filteredConfigs.length,
      itemBuilder: (context, index) {
        final config = filteredConfigs[index];
        return ConfigCard(
          config: config,
          isSelected: selectedConfig == config,
          onTap: () {
            onConfigChanged(selectedConfig == config ? null : config);
          },
        );
      },
    );
  }
}
