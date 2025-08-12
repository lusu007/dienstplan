import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/setup_step_wrapper.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/step_header.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/skeleton_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/config_card.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SetupStepWrapper(
      scrollController: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepHeader(
            title: l10n.myDutySchedule,
            description: l10n.welcomeMessage,
          ),
          if (isLoading)
            ...List.generate(3, (index) => const SkeletonCard())
          else if (loadingError != null)
            ErrorDisplay(
              error: loadingError!,
              stackTrace: loadingErrorStackTrace,
              onRetry: onRetry,
            )
          else
            ...configs.map((config) => ConfigCard(
                  config: config,
                  isSelected: selectedConfig == config,
                  onTap: () {
                    onConfigChanged(selectedConfig == config ? null : config);
                  },
                )),
        ],
      ),
    );
  }
}
