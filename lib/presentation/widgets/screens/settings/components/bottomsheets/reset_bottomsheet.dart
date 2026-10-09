import 'package:dienstplan/presentation/widgets/common/app_glass_sheet.dart';

import 'dart:async';

import 'package:dienstplan/presentation/widgets/common/app_snack_bar.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/cache/settings_cache.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/state/config/config_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_ui_state.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/schedule_data/schedule_data_notifier.dart';
import 'package:dienstplan/core/errors/failure_presenter.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';

class ResetBottomsheet {
  static void show(BuildContext context) {
    showAppGlassBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: glassBarrierAlpha),
      builder: (_) => _ResetConfirmation(
        onComplete: () {
          if (context.mounted) context.router.replaceAll([const SetupRoute()]);
        },
      ),
    );
  }
}

class _ResetConfirmation extends ConsumerStatefulWidget {
  const _ResetConfirmation({required this.onComplete});
  final VoidCallback onComplete;
  @override
  ConsumerState<_ResetConfirmation> createState() => _ResetConfirmationState();
}

class _ResetConfirmationState extends ConsumerState<_ResetConfirmation> {
  bool _busy = false;
  String? _error;
  Future<void> _reset() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    ProviderSubscription<AsyncValue<SettingsUiState>>? settingsSubscription;
    try {
      // Capture provider futures before the asynchronous operation begins.
      final repositoryFuture = container.read(
        personalCalendarRepositoryProvider.future,
      );
      final configFuture = container.read(scheduleConfigServiceProvider.future);
      final (repository, configService) = await (
        repositoryFuture,
        configFuture,
      ).wait;
      final deleted = await repository.deleteAll();
      if (deleted.isFailure) {
        if (mounted) {
          setState(
            () => _error = const FailurePresenter().present(
              deleted.failure,
              l10n,
            ),
          );
        }
        return;
      }
      settingsSubscription = container.listen(settingsProvider, (_, _) {});
      await container.read(settingsProvider.future);
      final settings = container.read(settingsProvider.notifier);
      await configService.resetSetup();
      await settings.reset();
      final settingsState = container.read(settingsProvider);
      if (settingsState.hasError || settingsState.value?.error != null) {
        if (mounted) setState(() => _error = l10n.resetDataError);
        return;
      }
      container.read(scheduleDataProvider.notifier).invalidateCache();
      SettingsCache.clearCache();
      container.invalidate(getSettingsUseCaseProvider);
      container.invalidate(scheduleDataProvider);
      container.invalidate(scheduleCoordinatorProvider);
      container.invalidate(configProvider);
      container.invalidate(partnerProvider);
      container.invalidate(schoolHolidaysProvider);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(AppSnackBar(content: Text(l10n.resetDataSuccess)));
      widget.onComplete();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.resetDataError);
    } finally {
      settingsSubscription?.close();
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_busy,
      child: GlassBottomSheet(
        title: l10n.resetData,
        shrinkToContent: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(glassSpacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.warning_rounded, color: scheme.error, size: 48),
                const SizedBox(height: glassSpacingLg),
                Text(l10n.resetDataConfirmation, textAlign: TextAlign.center),
                if (_error != null) ...[
                  const SizedBox(height: glassSpacingLg),
                  Semantics(
                    liveRegion: true,
                    child: Text(_error!, style: TextStyle(color: scheme.error)),
                  ),
                ],
                const SizedBox(height: glassSpacingLg),
                AppGlassButton(
                  role: AppGlassButtonRole.destructive,
                  fullWidth: true,
                  isLoading: _busy,
                  onPressed: _busy ? null : _reset,
                  child: Text(l10n.reset),
                ),
                const SizedBox(height: glassSpacingSm),
                AppGlassButton(
                  role: AppGlassButtonRole.quiet,
                  fullWidth: true,
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
