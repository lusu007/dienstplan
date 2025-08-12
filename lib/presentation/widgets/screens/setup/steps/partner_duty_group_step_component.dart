import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/setup_step_wrapper.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/step_header.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/duty_group_card.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/core/constants/app_colors.dart';

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

    return SetupStepWrapper(
      scrollController: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepHeader(
            title: l10n.selectPartnerDutyGroup,
            description: l10n.selectPartnerDutyGroupMessage,
          ),
          ...List.generate(
            dutyGroups.length + 1,
            (index) {
              if (index < dutyGroups.length) {
                final group = dutyGroups[index];
                return DutyGroupCard(
                  dutyGroupName: group.name,
                  isSelected: selectedPartnerDutyGroup == group.name,
                  onTap: () {
                    onPartnerDutyGroupChanged(
                        selectedPartnerDutyGroup == group.name
                            ? null
                            : group.name);
                  },
                );
              }

              return SelectionCard(
                title: l10n.noPartnerGroup,
                subtitle: l10n.noMyDutyGroupDescription,
                leadingIcon: Icons.clear,
                isSelected: selectedPartnerDutyGroup == null,
                onTap: () {
                  if (selectedPartnerDutyGroup == null) {
                    onPartnerDutyGroupChanged('DESELECTED');
                  } else {
                    onPartnerDutyGroupChanged(null);
                  }
                },
                mainColor: AppColors.primary,
              );
            },
          ),
        ],
      ),
    );
  }
}
