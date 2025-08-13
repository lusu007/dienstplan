import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/step_header.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/duty_group_card.dart';

class PartnerDutyGroupStepComponent extends StatelessWidget {
  final DutyScheduleConfig? selectedPartnerConfig;
  final String? selectedPartnerDutyGroup;
  final Function(String?) onPartnerDutyGroupChanged;
  final ScrollController scrollController;

  const PartnerDutyGroupStepComponent({
    super.key,
    required this.selectedPartnerConfig,
    required this.selectedPartnerDutyGroup,
    required this.onPartnerDutyGroupChanged,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (selectedPartnerConfig == null) return const SizedBox.shrink();

    final dutyGroups = selectedPartnerConfig!.dutyGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(
          title: l10n.partnerDutyGroup,
          description: l10n.selectPartnerDutyGroupMessage,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: dutyGroups
                  .map((group) => DutyGroupCard(
                        dutyGroupName: group.name,
                        isSelected: selectedPartnerDutyGroup == group.name,
                        onTap: () {
                          onPartnerDutyGroupChanged(
                              selectedPartnerDutyGroup == group.name
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
