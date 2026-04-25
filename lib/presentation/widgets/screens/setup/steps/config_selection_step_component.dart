import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/state/setup/setup_ui_state.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/step_header.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/skeleton_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/config_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/police_authority_filter_chips.dart';
import 'package:dienstplan/presentation/widgets/common/error_display.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';

class ConfigSelectionStepComponent extends StatelessWidget {
  final SetupUiState state;
  final Function(DutyScheduleConfig?) onConfigChanged;
  final Object? loadingError;
  final StackTrace? loadingErrorStackTrace;
  final VoidCallback onRetry;
  final ScrollController scrollController;
  final Function(String) onPoliceAuthorityToggled;
  final VoidCallback onClearAllFilters;

  const ConfigSelectionStepComponent({
    super.key,
    required this.state,
    required this.onConfigChanged,
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
          title: l10n.myDutySchedule,
          description: l10n.welcomeMessage,
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
          child: ScrollFadeMask(
            child: _buildScrollableContent(
              context: context,
              isLoading: state.isLoading,
              loadingError: loadingError,
              loadingErrorStackTrace: loadingErrorStackTrace,
              onRetry: onRetry,
              filteredConfigs: state.filteredConfigs,
              selectedConfig: state.selectedConfig,
              onConfigChanged: onConfigChanged,
              scrollController: scrollController,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableContent({
    required BuildContext context,
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
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        child: Column(
          children: List.generate(3, (index) => const SkeletonCard()),
        ),
      );
    }

    if (loadingError != null) {
      return SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        child: ErrorDisplay(
          error: loadingError,
          stackTrace: loadingErrorStackTrace,
          onRetry: onRetry,
        ),
      );
    }

    if (filteredConfigs.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 12, bottom: 32),
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

  Widget _buildEmptyState(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        glassSpacingLg,
        glassSpacingXl,
        glassSpacingLg,
        glassSpacingXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt_off_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: glassSpacingMd),
          Text(
            l10n.configSelectionEmptyTitle,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: glassSpacingSm),
          Text(
            l10n.configSelectionEmptyMessage,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (state.selectedPoliceAuthorities.isNotEmpty) ...[
            const SizedBox(height: glassSpacingLg),
            TextButton(
              onPressed: onClearAllFilters,
              child: Text(l10n.clearAll),
            ),
          ],
        ],
      ),
    );
  }
}
