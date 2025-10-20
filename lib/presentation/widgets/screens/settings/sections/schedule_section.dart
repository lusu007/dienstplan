import 'package:flutter/material.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/presentation/extensions/accent_color_extensions.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_ui_state.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/duty_schedule_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/my_duty_group_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/my_accent_color_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/partner_group_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/partner_config_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/partner_color_bottomsheet.dart';

class ScheduleSection extends StatelessWidget {
  final ScheduleUiState state;

  const ScheduleSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSection(
          title: l10n.myDutySchedule,
          cards: [
            NavigationCard(
              icon: Icons.calendar_month_outlined,
              title: l10n.myDutySchedule,
              subtitle: _getDutyScheduleDisplayName(state, l10n),
              onTap: () => DutyScheduleBottomsheet.show(
                context,
                heightPercentage: 0.8, // 80% für Config-Auswahl mit Filtern
              ),
            ),
            NavigationCard(
              icon: Icons.favorite_outlined,
              title: l10n.myDutyGroup,
              subtitle: _getPreferredDutyGroupDisplayName(state, l10n),
              onTap: () => MyDutyGroupBottomsheet.show(
                context,
                heightPercentage: 0.5, // 50% für einfache Gruppenauswahl
              ),
            ),
            NavigationCard(
              icon: Icons.color_lens_outlined,
              title: l10n.myAccentColor,
              subtitle: _getMyAccentColorName(state, l10n),
              trailing: _buildMyAccentColorChip(
                context,
                state.myAccentColorValue,
              ),
              onTap: () => MyAccentColorBottomsheet.show(
                context,
                heightPercentage: 0.6, // 60% für Farbauswahl
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SettingsSection(
          title: l10n.partnerDutySchedule,
          cards: [
            NavigationCard(
              icon: Icons.calendar_month_outlined,
              title: l10n.partnerDutySchedule,
              subtitle: state.partnerConfigName?.isNotEmpty == true
                  ? state.partnerConfigName!
                  : l10n.noDutySchedule,
              onTap: () => PartnerConfigBottomsheet.show(
                context,
                heightPercentage: 0.8, // 80% für Config-Auswahl mit Filtern
              ),
            ),
            NavigationCard(
              icon: Icons.group_outlined,
              title: l10n.partnerDutyGroup,
              subtitle: _getPartnerGroupDisplayName(state, l10n),
              onTap: () => PartnerGroupBottomsheet.show(
                context,
                heightPercentage: 0.5, // 50% für einfache Gruppenauswahl
              ),
              enabled: _isPartnerDutyGroupEnabled(state),
            ),
            NavigationCard(
              icon: Icons.color_lens_outlined,
              title: l10n.accentColor,
              subtitle: _getPartnerAccentColorName(state, l10n),
              trailing: _buildAccentColorChip(
                context,
                state.partnerAccentColorValue,
              ),
              onTap: () => PartnerColorBottomsheet.show(
                context,
                heightPercentage: 0.6, // 60% für Farbauswahl
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getPartnerAccentColorName(
    ScheduleUiState state,
    AppLocalizations l10n,
  ) {
    final int value =
        state.partnerAccentColorValue ??
        AccentColorDefaults.partnerAccentColorValue;
    final AccentColor? match = AccentColor.fromValue(value);
    if (match != null) return match.toLabel(l10n);
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  Widget _buildAccentColorChip(BuildContext context, int? colorValue) {
    final Color color = Color(
      colorValue ?? AccentColorDefaults.partnerAccentColorValue,
    );
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
    );
  }

  String _getDutyScheduleDisplayName(
    ScheduleUiState state,
    AppLocalizations l10n,
  ) {
    try {
      if ((state.activeConfigName ?? '').isEmpty) {
        return l10n.noDutySchedules;
      }
      return state.activeConfig?.meta.name ?? state.activeConfigName!;
    } catch (e) {
      AppLogger.e(
        'ScheduleSection: Error getting duty schedule display name',
        e,
      );
      return l10n.noDutySchedules;
    }
  }

  String _getPreferredDutyGroupDisplayName(
    ScheduleUiState state,
    AppLocalizations l10n,
  ) {
    try {
      if ((state.preferredDutyGroup ?? '').isEmpty) {
        return l10n.noMyDutyGroup;
      }
      return state.preferredDutyGroup!;
    } catch (e) {
      AppLogger.e(
        'ScheduleSection: Error getting preferred duty group display name',
        e,
      );
      return l10n.noMyDutyGroup;
    }
  }

  String _getMyAccentColorName(ScheduleUiState state, AppLocalizations l10n) {
    final int value =
        state.myAccentColorValue ?? AccentColorDefaults.myAccentColorValue;
    final AccentColor? match = AccentColor.fromValue(value);
    if (match != null) return match.toLabel(l10n);
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  Widget _buildMyAccentColorChip(BuildContext context, int? colorValue) {
    final Color color = Color(
      colorValue ?? AccentColorDefaults.myAccentColorValue,
    );
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
    );
  }

  String _getPartnerGroupDisplayName(
    ScheduleUiState state,
    AppLocalizations l10n,
  ) {
    try {
      // If no partner duty plan is selected, show a helpful message
      if ((state.partnerConfigName ?? '').isEmpty) {
        return l10n.noDutySchedule;
      }
      if ((state.partnerDutyGroup ?? '').isEmpty) {
        return l10n.noPartnerGroup;
      }
      return state.partnerDutyGroup!;
    } catch (_) {
      return l10n.noPartnerGroup;
    }
  }

  bool _isPartnerDutyGroupEnabled(ScheduleUiState state) {
    return (state.partnerConfigName ?? '').isNotEmpty;
  }
}
