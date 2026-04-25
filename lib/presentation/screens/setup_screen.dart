import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/presentation/widgets/common/glass_container.dart';
import 'package:dienstplan/presentation/widgets/common/step_indicator.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/action_button.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/language_selector_button.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/setup_back_button.dart';
import 'package:dienstplan/core/routing/app_router.dart';
// Step components
import 'package:dienstplan/presentation/widgets/screens/setup/steps/theme_step_component.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/steps/config_selection_step_component.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/steps/duty_group_step_component.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/steps/partner_config_step_component.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/steps/partner_duty_group_step_component.dart';
// State management
import 'package:dienstplan/presentation/state/setup/setup_notifier.dart';
import 'package:dienstplan/presentation/state/setup/setup_ui_state.dart';

@RoutePage()
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        try {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          try {
            _scrollController.jumpTo(0);
          } catch (e2) {
            AppLogger.d('Scroll to top failed: $e2');
          }
        }
      }
    });
  }

  void _nextStepWithScroll() {
    _scrollToTop();
    ref.read(setupProvider.notifier).nextStep();
  }

  void _previousStep() {
    ref.read(setupProvider.notifier).previousStep();
    _scrollToTop();
  }

  Widget _buildStepButtons(SetupUiState state) {
    final l10n = AppLocalizations.of(context);

    switch (state.currentStep) {
      case 1:
        return ActionButton(
          text: l10n.continueButton,
          onPressed: state.isSetupCompleted ? null : _nextStepWithScroll,
        );
      case 2:
        return Row(
          children: [
            SetupBackButton(
              onPressed: state.currentStep > 1 ? _previousStep : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: l10n.continueButton,
                onPressed:
                    state.isSetupCompleted || state.selectedConfig == null
                    ? null
                    : _nextStepWithScroll,
              ),
            ),
          ],
        );
      case 3:
        return Row(
          children: [
            SetupBackButton(
              onPressed: state.currentStep > 1 ? _previousStep : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: state.selectedDutyGroup != null
                    ? l10n.continueButton
                    : l10n.skipPartnerSetup,
                onPressed: state.isSetupCompleted ? null : _nextStepWithScroll,
              ),
            ),
          ],
        );
      case 4:
        return Row(
          children: [
            SetupBackButton(
              onPressed: state.currentStep > 1 ? _previousStep : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: state.selectedPartnerConfig != null
                    ? l10n.continueButton
                    : l10n.skipPartnerSetup,
                onPressed: state.isSetupCompleted ? null : _nextStepWithScroll,
                isLoading: state.isGeneratingSchedules,
              ),
            ),
          ],
        );
      case 5:
        return Row(
          children: [
            SetupBackButton(
              onPressed: state.currentStep > 1 ? _previousStep : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: l10n.continueButton,
                onPressed:
                    state.isSetupCompleted ||
                        state.selectedPartnerDutyGroup == null
                    ? null
                    : _nextStepWithScroll,
                isLoading: state.isGeneratingSchedules,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCurrentStepContent(SetupUiState state) {
    switch (state.currentStep) {
      case 1:
        return ThemeStepComponent(
          selectedTheme: state.selectedTheme,
          onThemeChanged: (theme) =>
              ref.read(setupProvider.notifier).setTheme(theme),
          scrollController: _scrollController,
        );
      case 2:
        return ConfigSelectionStepComponent(
          state: state,
          onConfigChanged: (config) =>
              ref.read(setupProvider.notifier).setConfig(config),
          loadingError: state.error != null ? Exception(state.error!) : null,
          loadingErrorStackTrace: state.errorStackTrace,
          onRetry: () => ref.read(setupProvider.notifier).retryLoading(),
          scrollController: _scrollController,
          onPoliceAuthorityToggled: (authority) => ref
              .read(setupProvider.notifier)
              .togglePoliceAuthorityFilter(authority),
          onClearAllFilters: () =>
              ref.read(setupProvider.notifier).clearAllFilters(),
        );
      case 3:
        return DutyGroupStepComponent(
          selectedConfig: state.selectedConfig,
          selectedDutyGroup: state.selectedDutyGroup,
          onDutyGroupChanged: (dutyGroup) =>
              ref.read(setupProvider.notifier).setDutyGroup(dutyGroup),
          scrollController: _scrollController,
        );
      case 4:
        return PartnerConfigStepComponent(
          state: state,
          onPartnerConfigChanged: (config) =>
              ref.read(setupProvider.notifier).setPartnerConfig(config),
          loadingError: state.error != null ? Exception(state.error!) : null,
          loadingErrorStackTrace: state.errorStackTrace,
          onRetry: () => ref.read(setupProvider.notifier).retryLoading(),
          scrollController: _scrollController,
          onPoliceAuthorityToggled: (authority) => ref
              .read(setupProvider.notifier)
              .togglePoliceAuthorityFilter(authority),
          onClearAllFilters: () =>
              ref.read(setupProvider.notifier).clearAllFilters(),
        );
      case 5:
        return PartnerDutyGroupStepComponent(
          selectedPartnerConfig: state.selectedPartnerConfig,
          selectedPartnerDutyGroup: state.selectedPartnerDutyGroup,
          onPartnerDutyGroupChanged: (dutyGroup) =>
              ref.read(setupProvider.notifier).setPartnerDutyGroup(dutyGroup),
          scrollController: _scrollController,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupAsync = ref.watch(setupProvider);
    final languageAsync = ref.watch(languageServiceProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        body: CalendarBackdrop(
          child: setupAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => _buildErrorState(context, e),
            data: (setupState) {
              if (setupState.isSetupCompleted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.router.replace(const CalendarRoute());
                });
              }

              return languageAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _buildLanguageErrorState(context),
                data: (languageService) => SafeArea(
                  bottom: false,
                  child: ListenableBuilder(
                    listenable: languageService,
                    builder: (context, child) {
                      return _buildSetupLayout(
                        context: context,
                        state: setupState,
                        languageService: languageService,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSetupLayout({
    required BuildContext context,
    required SetupUiState state,
    required LanguageService languageService,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        glassSpacingXl - 4,
        glassSpacingXs,
        glassSpacingXl - 4,
        glassSpacingXl - 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(state: state, languageService: languageService),
          const SizedBox(height: glassSpacingMd),
          StepIndicator(
            currentStep: state.currentStep,
            totalSteps: state.selectedPartnerConfig != null ? 5 : 4,
            activeColor: scheme.primary,
            inactiveColor: scheme.outlineVariant.withValues(alpha: 0.7),
            halfSteps: state.selectedPartnerConfig != null ? [3, 4] : null,
          ),
          const SizedBox(height: glassSpacingXl - 4),
          Expanded(child: _buildCurrentStepContent(state)),
          const SizedBox(height: glassSpacingLg),
          _buildStepButtons(state),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + glassSpacingXs,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required SetupUiState state,
    required LanguageService languageService,
  }) {
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    final TextStyle? titleStyle = Theme.of(context).textTheme.titleLarge;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppInfo.appName,
          style: (titleStyle ?? const TextStyle()).copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            height: 1.0,
          ),
        ),
        const Spacer(),
        LanguageSelectorButton(
          languageService: languageService,
          disabled: state.isGeneratingSchedules,
          onLanguageChanged: null,
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    AppLogger.e('SetupScreen: Setup load failed', error);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(glassSpacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: glassSpacingLg),
            Text(
              l10n.setupFailedTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: glassSpacingLg),
            ActionButton(
              text: l10n.tryAgain,
              onPressed: () => ref.read(setupProvider.notifier).retryLoading(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageErrorState(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(glassSpacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: glassSpacingLg),
            Text(
              l10n.languageLoadFailed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: glassSpacingLg),
            ActionButton(
              text: l10n.tryAgain,
              onPressed: () => ref.invalidate(languageServiceProvider),
            ),
          ],
        ),
      ),
    );
  }
}
