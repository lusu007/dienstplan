import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/presentation/widgets/common/step_indicator.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/action_button.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/setup_back_button.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/language_selector_button.dart';
import 'package:dienstplan/presentation/widgets/common/primary_app_bar.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/app_info.dart';
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
          mainColor: AppColors.primary,
        );
      case 2:
        return Row(
          children: [
            SetupBackButton(
              onPressed: state.currentStep > 1 ? _previousStep : null,
              mainColor: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: l10n.continueButton,
                onPressed:
                    state.isSetupCompleted || state.selectedConfig == null
                        ? null
                        : _nextStepWithScroll,
                mainColor: AppColors.primary,
              ),
            ),
          ],
        );
      case 3:
        return Row(
          children: [
            SetupBackButton(
              onPressed: state.currentStep > 1 ? _previousStep : null,
              mainColor: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: state.selectedDutyGroup != null
                    ? l10n.continueButton
                    : l10n.skipPartnerSetup,
                onPressed: state.isSetupCompleted ? null : _nextStepWithScroll,
                mainColor: AppColors.primary,
              ),
            ),
          ],
        );
      case 4:
        return Row(
          children: [
            SetupBackButton(
              onPressed: state.currentStep > 1 ? _previousStep : null,
              mainColor: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: state.selectedPartnerConfig != null
                    ? l10n.continueButton
                    : l10n.skipPartnerSetup,
                onPressed: state.isSetupCompleted ? null : _nextStepWithScroll,
                isLoading: state.isGeneratingSchedules,
                mainColor: AppColors.primary,
              ),
            ),
          ],
        );
      case 5:
        return Row(
          children: [
            SetupBackButton(
              onPressed: state.currentStep > 1 ? _previousStep : null,
              mainColor: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: l10n.continueButton,
                onPressed: state.isSetupCompleted ||
                        state.selectedPartnerDutyGroup == null
                    ? null
                    : _nextStepWithScroll,
                isLoading: state.isGeneratingSchedules,
                mainColor: AppColors.primary,
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
          configs: state.configs,
          selectedConfig: state.selectedConfig,
          onConfigChanged: (config) =>
              ref.read(setupProvider.notifier).setConfig(config),
          isLoading: state.isLoading,
          loadingError: state.error != null ? Exception(state.error!) : null,
          loadingErrorStackTrace: state.errorStackTrace,
          onRetry: () => ref.read(setupProvider.notifier).retryLoading(),
          scrollController: _scrollController,
          selectedPoliceAuthorities: state.selectedPoliceAuthorities,
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
          configs: state.configs,
          selectedPartnerConfig: state.selectedPartnerConfig,
          onPartnerConfigChanged: (config) =>
              ref.read(setupProvider.notifier).setPartnerConfig(config),
          isLoading: state.isLoading,
          loadingError: state.error != null ? Exception(state.error!) : null,
          loadingErrorStackTrace: state.errorStackTrace,
          onRetry: () => ref.read(setupProvider.notifier).retryLoading(),
          scrollController: _scrollController,
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

    return setupAsync.when(
      loading: () => const Scaffold(
        appBar: PrimaryAppBar(titleText: AppInfo.appName),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: const PrimaryAppBar(titleText: AppInfo.appName),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Setup Error: ${e.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(setupProvider.notifier).retryLoading(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (setupState) {
        // Navigate to calendar screen if setup is completed
        if (setupState.isSetupCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.router.replace(const CalendarRoute());
          });
          // Keep showing the current setup step until navigation completes
        }

        return languageAsync.when(
          loading: () => const Scaffold(
            appBar: PrimaryAppBar(titleText: AppInfo.appName),
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) => const Scaffold(
            appBar: PrimaryAppBar(titleText: AppInfo.appName),
            body: Center(child: CircularProgressIndicator()),
          ),
          data: (languageService) => ListenableBuilder(
            listenable: languageService,
            builder: (context, child) {
              return Scaffold(
                appBar: PrimaryAppBar(
                  titleText: AppInfo.appName,
                  actions: [
                    LanguageSelectorButton(
                      languageService: languageService,
                      disabled: setupState.isGeneratingSchedules,
                      onLanguageChanged: null,
                    ),
                  ],
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        StepIndicator(
                          currentStep: setupState.currentStep,
                          totalSteps:
                              setupState.selectedPartnerConfig != null ? 5 : 4,
                          activeColor: AppColors.primary,
                          halfSteps: setupState.selectedPartnerConfig != null
                              ? [3, 4]
                              : null,
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: _buildCurrentStepContent(setupState),
                        ),
                        const SizedBox(height: 24),
                        _buildStepButtons(setupState),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
