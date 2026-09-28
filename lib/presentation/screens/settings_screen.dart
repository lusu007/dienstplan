import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_category.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/footer_section.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassScreenScaffold(
      title: l10n.settings,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: GlassCardGroup(
                children: [
                  for (final category in SettingsCategory.values)
                    NavigationCard(
                      key: ValueKey('settings_${category.name}'),
                      icon: category.icon,
                      title: category.title(l10n),
                      subtitle: category.subtitle(l10n),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                      ),
                      onTap: () => context.router.push(
                        SettingsCategoryRoute(category: category.name),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                28,
                20,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              child: const Align(
                alignment: Alignment.bottomCenter,
                child: SettingsFooter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
