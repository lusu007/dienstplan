import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/utils/app_info.dart';

class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CalendarAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        AppInfo.appName,
        style: TextStyle(color: Colors.white),
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
