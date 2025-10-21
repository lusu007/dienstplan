import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class ResetBottomsheet {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => GenericBottomsheet(
        title: l10n.resetData,
        heightPercentage: 0.4, // 40% für einfache Reset-Bestätigung
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Warning text
                Text(
                  l10n.resetDataConfirmation,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Reset button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    onPressed: () async {
                      final container = ProviderScope.containerOf(
                        context,
                        listen: false,
                      );
                      final configService = await container.read(
                        scheduleConfigServiceProvider.future,
                      );

                      await configService.resetSetup();
                      await container.read(settingsProvider.notifier).reset();

                      // Invalidate school holidays provider to clear cached data
                      container.invalidate(schoolHolidaysProvider);

                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            content: Text(
                              l10n.resetDataSuccess,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        context.router.replaceAll([const SetupRoute()]);
                      }
                    },
                    child: Text(l10n.reset),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
