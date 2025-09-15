import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/step_header.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/duty_group_card.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';

class DutyGroupStepComponent extends ConsumerWidget {
  final DutyScheduleConfig? selectedConfig;
  final String? selectedDutyGroup;
  final Function(String?) onDutyGroupChanged;
  final ScrollController scrollController;

  const DutyGroupStepComponent({
    super.key,
    required this.selectedConfig,
    required this.selectedDutyGroup,
    required this.onDutyGroupChanged,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheduleState = ref.watch(scheduleCoordinatorProvider).value;
    final currentDutyGroup = scheduleState?.preferredDutyGroup;
    final hasExistingDutyGroup =
        currentDutyGroup != null && currentDutyGroup.isNotEmpty;

    if (selectedConfig == null) return const SizedBox.shrink();

    final dutyGroups = selectedConfig!.dutyGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(
          title: l10n.myDutyGroup,
          description: hasExistingDutyGroup
              ? l10n.myDutyGroupMessage
              : l10n.selectDutyGroupMessage,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: dutyGroups
                  .map((group) => DutyGroupCard(
                        dutyGroupName: group.name,
                        isSelected: selectedDutyGroup == group.name,
                        onTap: () {
                          onDutyGroupChanged(selectedDutyGroup == group.name
                              ? null
                              : group.name);
                        },
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
