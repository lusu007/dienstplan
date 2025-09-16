import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/state/setup/setup_ui_state.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/step_header.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/skeleton_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/config_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/police_authority_filter_chips.dart';
import 'package:dienstplan/presentation/widgets/common/error_display.dart';

class PartnerConfigStepComponent extends StatelessWidget {
  final SetupUiState state;
  final Function(DutyScheduleConfig?) onPartnerConfigChanged;
  final Object? loadingError;
  final StackTrace? loadingErrorStackTrace;
  final VoidCallback onRetry;
  final ScrollController scrollController;
  final Function(String) onPoliceAuthorityToggled;
  final VoidCallback onClearAllFilters;

  const PartnerConfigStepComponent({
    super.key,
    required this.state,
    required this.onPartnerConfigChanged,
    this.loadingError,
    this.loadingErrorStackTrace,
    required this.onRetry,
    required this.scrollController,
    required this.onPoliceAuthorityToggled,
    required this.onClearAllFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed header section
        StepHeader(
          title: l10n.partnerSetupTitle,
          description: l10n.partnerSetupDescription,
        ),

        // Fixed filter section (if available)
        if (state.availablePoliceAuthorities.isNotEmpty &&
            !state.isLoading &&
            loadingError == null) ...[
          const SizedBox(height: 16),
          PoliceAuthorityFilterChips(
            availableAuthorities: state.availablePoliceAuthorities,
            selectedAuthorities: state.selectedPoliceAuthorities,
            onAuthorityToggled: onPoliceAuthorityToggled,
            onClearAll: onClearAllFilters,
          ),
          const SizedBox(height: 16),
        ],

        // Scrollable content section
        Expanded(
          child: _buildScrollableContent(
            isLoading: state.isLoading,
            loadingError: loadingError,
            loadingErrorStackTrace: loadingErrorStackTrace,
            onRetry: onRetry,
            filteredConfigs: state.filteredConfigs,
            selectedPartnerConfig: state.selectedPartnerConfig,
            onPartnerConfigChanged: onPartnerConfigChanged,
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
    required DutyScheduleConfig? selectedPartnerConfig,
    required Function(DutyScheduleConfig?) onPartnerConfigChanged,
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
      padding: const EdgeInsets.only(bottom: 32),
      itemCount: filteredConfigs.length,
      itemBuilder: (context, index) {
        final config = filteredConfigs[index];
        return ConfigCard(
          config: config,
          isSelected: selectedPartnerConfig == config,
          onTap: () {
            onPartnerConfigChanged(
                selectedPartnerConfig == config ? null : config);
          },
        );
      },
    );
  }
}
