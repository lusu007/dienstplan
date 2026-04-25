import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    GenericBottomsheet.show<void>(
      context: context,
      title: l10n.resetData,
      shrinkToContent: true,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            glassSpacingLg,
            glassSpacingXl - 4,
            glassSpacingLg,
            glassSpacingXl - 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: colorScheme.onErrorContainer,
                  size: 32,
                ),
              ),
              const SizedBox(height: glassSpacingLg),
              Text(
                l10n.resetDataConfirmation,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: glassSpacingXl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(glassSurfaceRadiusSm),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: glassSpacingMd,
                      vertical: glassSpacingMd,
                    ),
                    textStyle: Theme.of(context).textTheme.labelLarge,
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
