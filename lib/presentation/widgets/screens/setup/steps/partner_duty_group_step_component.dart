import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/step_header.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/components/duty_group_card.dart';
import 'package:dienstplan/presentation/widgets/common/scroll_fade_mask.dart';

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
          child: ScrollFadeMask(
            child: dutyGroups.isEmpty
                ? _buildEmptyState(context)
                : SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(top: 12, bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: dutyGroups
                          .map(
                            (group) => DutyGroupCard(
                              dutyGroupName: group.name,
                              isSelected:
                                  selectedPartnerDutyGroup == group.name,
                              onTap: () {
                                onPartnerDutyGroupChanged(
                                  selectedPartnerDutyGroup == group.name
                                      ? null
                                      : group.name,
                                );
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
            Icons.inbox_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: glassSpacingMd),
          Text(
            l10n.dutyGroupSelectionEmptyMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
