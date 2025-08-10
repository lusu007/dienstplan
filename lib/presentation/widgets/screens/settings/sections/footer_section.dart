import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class SettingsFooter extends StatefulWidget {
  const SettingsFooter({super.key});

  @override
  State<SettingsFooter> createState() => _SettingsFooterState();
}

class _SettingsFooterState extends State<SettingsFooter> {
  int _footerTapCount = 0;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: _handleFooterTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppInfo.appLegalese,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          FutureBuilder<String>(
            future: AppInfo.fullVersion,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              }
              return Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            l10n.weLoveOss,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _handleFooterTap() {
    final DateTime now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds > 3) {
      _footerTapCount = 0;
    }
    _footerTapCount++;
    _lastTapTime = now;
    if (_footerTapCount >= 7) {
      _footerTapCount = 0;
      if (mounted) context.router.push(const DebugRoute());
    }
  }
}
