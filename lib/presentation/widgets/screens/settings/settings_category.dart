import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum SettingsCategory {
  schedule,
  partner,
  appearance,
  holidays,
  app;

  String title(AppLocalizations l10n) => switch (this) {
    schedule => l10n.myDutySchedule,
    partner => l10n.partnerDutySchedule,
    appearance => l10n.settingsAppearance,
    holidays => l10n.schoolHolidays,
    app => l10n.settingsAppAndPrivacy,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    schedule => l10n.settingsScheduleSummary,
    partner => l10n.settingsPartnerSummary,
    appearance => l10n.settingsAppearanceSummary,
    holidays => l10n.settingsHolidaysSummary,
    app => l10n.settingsAppSummary,
  };

  IconData get icon => switch (this) {
    schedule => Icons.calendar_month_outlined,
    partner => Icons.people_outline_rounded,
    appearance => Icons.palette_outlined,
    holidays => Icons.school_outlined,
    app => Icons.settings_outlined,
  };
}
