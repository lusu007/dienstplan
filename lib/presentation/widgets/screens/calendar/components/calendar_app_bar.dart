import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CalendarAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBar(
      title: Text(
        l10n.dutySchedule,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => context.router.push(const SettingsRoute()),
        ),
      ],
    );
  }
}
