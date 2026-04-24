import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/core/errors/failure_presenter.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/generic_bottomsheet.dart';

class ResetBottomsheet {
  static const FailurePresenter _failurePresenter = FailurePresenter();

  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    GenericBottomsheet.show<void>(
      context: context,
      title: l10n.resetData,
      shrinkToContent: true,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Text(
                l10n.resetDataConfirmation,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                    final personalCalendarRepository = await container.read(
                      personalCalendarRepositoryProvider.future,
                    );
                    final configService = await container.read(
                      scheduleConfigServiceProvider.future,
                    );
                    final deletePersonalEntriesResult =
                        await personalCalendarRepository.deleteAll();
                    if (deletePersonalEntriesResult.isFailure) {
                      if (context.mounted) {
                        final String message = _failurePresenter.present(
                          deletePersonalEntriesResult.failure,
                          l10n,
                        );
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      }
                      return;
                    }

                    await configService.resetSetup();
                    await container.read(settingsProvider.notifier).reset();
                    await container
                        .read(scheduleDataProvider.notifier)
                        .refreshPersonalCalendarEntries();

                    // Invalidate school holidays provider to clear cached data
                    container.invalidate(schoolHolidaysProvider);

                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.resetDataSuccess)),
                      );
                      context.router.replaceAll([const SetupRoute()]);
                    }
                  },
                  child: Text(l10n.reset),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
