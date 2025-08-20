import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/schedule_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/app_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/privacy_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/other_section.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/schedule_section_skeleton.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/app_section_skeleton.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/privacy_section_skeleton.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/sections/other_section_skeleton.dart';
import 'package:dienstplan/presentation/widgets/common/safe_area_wrapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/core/errors/failure_presenter.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final scheduleAsync = ref.watch(scheduleNotifierProvider);
    return scheduleAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.settings)),
        body: SafeAreaWrapper(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                const ScheduleSectionSkeleton(),
                const SizedBox(height: 16),
                const AppSectionSkeleton(),
                const SizedBox(height: 16),
                const PrivacySectionSkeleton(),
                const SizedBox(height: 16),
                const OtherSectionSkeleton(),
              ],
            ),
          ),
        ),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: Text(l10n.settings)),
        body: SafeAreaWrapper(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Builder(builder: (context) {
                  const presenter = FailurePresenter();
                  return FutureBuilder(
                    future: ref.read(languageServiceProvider.future),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final l10nResolved = AppLocalizations.of(context);
                      final Failure failure = e is Failure
                          ? e
                          : const UnknownFailure(technicalMessage: 'unknown');
                      final String message =
                          presenter.present(failure, l10nResolved);
                      return Text(message, textAlign: TextAlign.center);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      data: (state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
        ),
        body: SafeAreaWrapper(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                ScheduleSection(state: state),
                const SizedBox(height: 16),
                const AppSection(),
                const SizedBox(height: 16),
                const PrivacySection(),
                const SizedBox(height: 16),
                const OtherSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
