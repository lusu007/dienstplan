import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_category.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/appearance_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/app_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/school_holidays_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/privacy_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/other_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/settings_schedule_block.dart';

@RoutePage(name: 'SettingsCategoryRoute')
class SettingsCategoryScreen extends StatelessWidget {
  const SettingsCategoryScreen({
    super.key,
    @PathParam('category') required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    final selected = SettingsCategory.values
        .where((value) => value.name == category)
        .firstOrNull;
    final l10n = AppLocalizations.of(context);
    return GlassScreenScaffold(
      title: selected?.title(l10n) ?? l10n.settings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: switch (selected) {
          SettingsCategory.schedule => const [
            SettingsScheduleBlock(partner: false),
          ],
          SettingsCategory.partner => const [
            SettingsScheduleBlock(partner: true),
          ],
          SettingsCategory.appearance => const [AppearanceSection()],
          SettingsCategory.holidays => const [SchoolHolidaysSection()],
          SettingsCategory.app => const [
            AppSection(),
            SizedBox(height: 20),
            PrivacySection(),
            SizedBox(height: 20),
            OtherSection(),
          ],
          null => [Text(l10n.errorLoading)],
        },
      ),
    );
  }
}
