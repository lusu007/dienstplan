import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/routing/app_router.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:table_calendar/table_calendar.dart';
// Use cases are accessed via Riverpod providers
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
// Language service is accessed via Riverpod providers
import 'package:dienstplan/core/constants/animation_constants.dart';
import 'package:dienstplan/core/utils/icon_mapper.dart';
import 'package:dienstplan/presentation/widgets/common/step_indicator.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/action_button.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/setup_back_button.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/language_selector_button.dart';
import 'package:dienstplan/presentation/widgets/common/primary_app_bar.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/presentation/widgets/common/error_display.dart';

@RoutePage()
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  List<DutyScheduleConfig> _configs = [];
  DutyScheduleConfig? _selectedConfig;
  String? _selectedDutyGroup;
  DutyScheduleConfig? _selectedPartnerConfig;
  String? _selectedPartnerDutyGroup;
  ThemePreference _selectedTheme = ThemePreference.system;
  int _currentStep =
      1; // 1: Theme, 2: Config, 3: Duty Group, 4: Partner Config (half), 5: Partner Duty Group (half)
  bool _isLoading = true;
  bool _isGeneratingSchedules = false;
  Object? _loadingError;
  StackTrace? _loadingErrorStackTrace;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigs() async {
    try {
      AppLogger.i('Loading duty schedule configurations');
      final getConfigsUseCase =
          await ref.read(getConfigsUseCaseProvider.future);
      final configs = await getConfigsUseCase.execute();
      AppLogger.i('Loaded ${configs.length} configurations');
      if (mounted) {
        setState(() {
          _configs = configs;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error loading configs', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingError = e;
          _loadingErrorStackTrace = stackTrace;
        });
      }
    }
  }

  void _nextStep() {
    setState(() {
      if (_currentStep == 1) {
        // Theme selected → go to config selection
        _currentStep = 2;
        return;
      }
      if (_currentStep == 2 && _selectedConfig != null) {
        // Config selected → go to duty group selection
        _currentStep = 3;
        // Pre-select current duty group if it exists
        final scheduleState = ref.read(scheduleNotifierProvider).valueOrNull;
        final currentDutyGroup = scheduleState?.preferredDutyGroup;
        _selectedDutyGroup = currentDutyGroup;
        return;
      }
      if (_currentStep == 3) {
        // Duty group selected → go to partner config setup (optional)
        _currentStep = 4;
        _selectedPartnerConfig = null;
        _selectedPartnerDutyGroup = null;
        return;
      }
      if (_currentStep == 4) {
        // Partner config selected → go to partner duty group selection (if config selected)
        if (_selectedPartnerConfig != null) {
          _currentStep = 5;
          _selectedPartnerDutyGroup = null;
        } else {
          // No partner config selected, complete setup directly
          if (!_isGeneratingSchedules) {
            _saveDefaultConfig();
          }
        }
        return;
      }
      if (_currentStep == 5) {
        // Partner duty group selected → complete setup
        if (!_isGeneratingSchedules) {
          _saveDefaultConfig();
        }
        return;
      }
    });
  }

  void _scrollToTop() {
    // Add a small delay to ensure the widget is fully built
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        try {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          // If animation fails, try immediate scroll
          try {
            _scrollController.jumpTo(0);
          } catch (e2) {
            // If both fail, ignore the error
            AppLogger.d('Scroll to top failed: $e2');
          }
        }
      }
    });
  }

  void _nextStepWithScroll() {
    _scrollToTop();
    _nextStep();
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 1) {
        _currentStep -= 1;
        _scrollToTop();
      }
      if (_currentStep < 3) {
        // Reset duty group selection when going back before step 3
        _selectedDutyGroup = null;
      }
      if (_currentStep < 4) {
        _selectedPartnerConfig = null;
        _selectedPartnerDutyGroup = null;
      }
      if (_currentStep < 5) {
        _selectedPartnerDutyGroup = null;
      }
    });
  }

  Future<void> _saveDefaultConfig() async {
    try {
      AppLogger.i('Starting setup completion process');
      setState(() {
        _isGeneratingSchedules = true;
      });

      // First set the default config via repository (if one is selected)
      if (_selectedConfig != null) {
        final configRepository =
            await ref.read(configRepositoryProvider.future);
        await configRepository.setDefaultConfig(_selectedConfig!);

        // Set the active config using the use case directly
        final setActiveConfigUseCase =
            await ref.read(setActiveConfigUseCaseProvider.future);
        await setActiveConfigUseCase.execute(_selectedConfig!.name);
      }

      // Use policy-based approach for initial range instead of hardcoded years
      final dateRangePolicy = ref.read(dateRangePolicyProvider);
      final DateTime now = DateTime.now();
      final initialRange = dateRangePolicy.computeInitialRange(now);

      // For setup, ensure we have schedules for the initial range (if config is selected)
      // Additional months will be generated on-demand as needed
      if (_selectedConfig != null) {
        final generateSchedulesUseCase =
            await ref.read(generateSchedulesUseCaseProvider.future);

        await generateSchedulesUseCase.execute(
          configName: _selectedConfig!.name,
          startDate: initialRange.start,
          endDate: initialRange.end,
        );
      }

      // Create initial settings to mark setup as completed (preserve chosen theme)
      final getSettingsUseCase =
          await ref.read(getSettingsUseCaseProvider.future);
      final existingSettings = await getSettingsUseCase.execute();
      final saveSettingsUseCase =
          await ref.read(saveSettingsUseCaseProvider.future);

      // Get the theme preference that was selected during setup
      final currentThemePreference = _selectedTheme;

      final initialSettings = Settings(
        calendarFormat:
            existingSettings?.calendarFormat ?? CalendarFormat.month,
        myDutyGroup: _selectedDutyGroup,
        activeConfigName: _selectedConfig?.name,
        themePreference: currentThemePreference,
        partnerConfigName: _selectedPartnerConfig?.name,
        partnerDutyGroup: _selectedPartnerDutyGroup,
      );
      await saveSettingsUseCase.execute(initialSettings);

      // Mark setup as completed
      final scheduleConfigService =
          await ref.read(scheduleConfigServiceProvider.future);
      await scheduleConfigService.markSetupCompleted();
      AppLogger.i(
          'Setup completed successfully for config: ${_selectedConfig?.name ?? "none"}');

      // Wait a moment to ensure all settings are properly saved
      await Future.delayed(kUiDelayShort);

      if (!mounted) return;

      // Ensure the theme preference is properly saved before navigation
      final themePreferenceForTransition = _selectedTheme;

      // Update the final settings with the correct theme preference
      final finalSettings = Settings(
        calendarFormat: CalendarFormat.month,
        myDutyGroup: _selectedDutyGroup,
        activeConfigName: _selectedConfig!.name,
        themePreference: themePreferenceForTransition,
        partnerConfigName: _selectedPartnerConfig?.name,
        partnerDutyGroup: _selectedPartnerDutyGroup,
      );
      await saveSettingsUseCase.execute(finalSettings);

      // Ensure the theme preference is properly set in the notifier
      await ref
          .read(settingsNotifierProvider.notifier)
          .setThemePreference(themePreferenceForTransition);

      // Invalidate providers so AppInitializerWidget switches to CalendarScreen
      // Don't invalidate settingsNotifierProvider to prevent theme flashing
      ref.invalidate(scheduleNotifierProvider);

      // Navigate to the main calendar screen.
      // This is necessary when SetupScreen is opened via its own route
      // (e.g., after a reset), where the AppInitializerWidget is not
      // on the navigation stack to handle the switch.
      if (mounted) {
        context.router.replaceAll([const CalendarRoute()]);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error saving default config', e, stackTrace);
      if (!mounted) return;
      setState(() {
        _isGeneratingSchedules = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          content: ErrorMessage(error: e, stackTrace: stackTrace),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildStep1Content() {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.myDutySchedule,
            style: const TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.welcomeMessage,
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            // Show skeleton loading cards
            ...List.generate(3, (index) => _buildSkeletonCard())
          else if (_loadingError != null)
            // Show error display with retry option
            ErrorDisplay(
              error: _loadingError!,
              stackTrace: _loadingErrorStackTrace,
              onRetry: () {
                setState(() {
                  _isLoading = true;
                  _loadingError = null;
                  _loadingErrorStackTrace = null;
                });
                _loadConfigs();
              },
            )
          else
            // Show actual configs
            ..._configs.map((config) {
              final IconData icon = _getConfigIcon(config);
              return SelectionCard(
                title: config.meta.name,
                subtitle: config.meta.description,
                leadingIcon: icon,
                isSelected: _selectedConfig == config,
                onTap: () {
                  setState(() {
                    _selectedConfig = _selectedConfig == config ? null : config;
                  });
                },
                mainColor: AppColors.primary,
              );
            }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildThemeStepContent() {
    final l10n = AppLocalizations.of(context);
    const Color mainColor = AppColors.primary;

    Widget buildThemeCard(IconData icon, String title, ThemePreference pref) {
      final bool isSelected = _selectedTheme == pref;
      return SelectionCard(
        title: title,
        leadingIcon: icon,
        isSelected: isSelected,
        onTap: () async {
          final newTheme =
              _selectedTheme == pref ? ThemePreference.system : pref;
          setState(() {
            _selectedTheme = newTheme;
          });
          // Immediately apply the theme change
          await ref
              .read(settingsNotifierProvider.notifier)
              .setThemePreference(newTheme);
        },
        mainColor: mainColor,
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.welcome,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.themeModeDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          buildThemeCard(Icons.wb_sunny_outlined, l10n.themeModeLight,
              ThemePreference.light),
          buildThemeCard(
              Icons.nightlight_round, l10n.themeModeDark, ThemePreference.dark),
          buildThemeCard(Icons.brightness_auto, l10n.themeModeSystem,
              ThemePreference.system),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Skeleton icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          // Skeleton text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Content() {
    final l10n = AppLocalizations.of(context);
    final scheduleState = ref.watch(scheduleNotifierProvider).valueOrNull;
    final currentDutyGroup = scheduleState?.preferredDutyGroup;
    final hasExistingDutyGroup =
        currentDutyGroup != null && currentDutyGroup.isNotEmpty;

    if (_selectedConfig == null) return const SizedBox.shrink();

    final dutyGroups = _selectedConfig!.dutyGroups;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.myDutyGroup,
            style: const TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasExistingDutyGroup
                ? l10n.myDutyGroupMessage
                : l10n.selectDutyGroupMessage,
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 32),
          ...dutyGroups.map((group) => SelectionCard(
                title: group.name,
                leadingIcon: Icons.group,
                isSelected: _selectedDutyGroup == group.name,
                onTap: () {
                  setState(() {
                    _selectedDutyGroup =
                        _selectedDutyGroup == group.name ? null : group.name;
                  });
                },
                mainColor: AppColors.primary,
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStep4Content() {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.partnerSetupTitle,
            style: const TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.partnerSetupDescription,
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            // Show skeleton loading cards
            ...List.generate(3, (index) => _buildSkeletonCard())
          else if (_loadingError != null)
            // Show error display with retry option
            ErrorDisplay(
              error: _loadingError!,
              stackTrace: _loadingErrorStackTrace,
              onRetry: () {
                setState(() {
                  _isLoading = true;
                  _loadingError = null;
                  _loadingErrorStackTrace = null;
                });
                _loadConfigs();
              },
            )
          else
            // Show actual configs
            ..._configs.map((config) {
              final IconData icon = _getConfigIcon(config);
              return SelectionCard(
                title: config.meta.name,
                subtitle: config.meta.description,
                leadingIcon: icon,
                isSelected: _selectedPartnerConfig == config,
                onTap: () {
                  setState(() {
                    _selectedPartnerConfig =
                        _selectedPartnerConfig == config ? null : config;
                    _selectedPartnerDutyGroup = null;
                  });
                },
                mainColor: AppColors.primary,
              );
            }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStep5Content() {
    final l10n = AppLocalizations.of(context);

    if (_selectedPartnerConfig == null) return const SizedBox.shrink();

    final dutyGroups = _selectedPartnerConfig!.dutyGroups;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.selectPartnerDutyGroup,
            style: const TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectPartnerDutyGroupMessage,
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 32),
          ...List.generate(
            dutyGroups.length + 1, // +1 for "no preferred duty group" option
            (index) {
              // Regular duty groups first
              if (index < dutyGroups.length) {
                final group = dutyGroups[index];
                return SelectionCard(
                  title: group.name,
                  leadingIcon: Icons.group,
                  isSelected: _selectedPartnerDutyGroup == group.name,
                  onTap: () {
                    setState(() {
                      _selectedPartnerDutyGroup =
                          _selectedPartnerDutyGroup == group.name
                              ? null
                              : group.name;
                    });
                  },
                  mainColor: AppColors.primary,
                );
              }

              // Last item is "no preferred duty group"
              return SelectionCard(
                title: l10n.noPartnerGroup,
                subtitle: l10n.noMyDutyGroupDescription,
                leadingIcon: Icons.clear,
                isSelected: _selectedPartnerDutyGroup == null,
                onTap: () {
                  setState(() {
                    // Toggle between null (no partner group) and a special value to indicate deselection
                    if (_selectedPartnerDutyGroup == null) {
                      // If no partner group is selected, deselect it by setting to a special value
                      _selectedPartnerDutyGroup = 'DESELECTED';
                    } else {
                      // If something else is selected, select no partner group
                      _selectedPartnerDutyGroup = null;
                    }
                  });
                },
                mainColor: AppColors.primary,
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  IconData _getConfigIcon(DutyScheduleConfig config) {
    // Use the icon from the JSON configuration if available
    if (config.meta.icon != null) {
      return IconMapper.getIcon(config.meta.icon, defaultIcon: Icons.schedule);
    }

    return Icons.directions_car;
  }

  @override
  Widget build(BuildContext context) {
    final languageAsync = ref.watch(languageServiceProvider);
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
                  disabled: _isGeneratingSchedules,
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
                      currentStep: _currentStep,
                      totalSteps: _selectedPartnerConfig != null ? 5 : 4,
                      activeColor: AppColors.primary,
                      halfSteps: _selectedPartnerConfig != null
                          ? [3, 4]
                          : null, // Only show half steps when partner config is selected
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _currentStep == 1
                          ? _buildThemeStepContent()
                          : (_currentStep == 2
                              ? _buildStep1Content()
                              : (_currentStep == 3
                                  ? _buildStep2Content()
                                  : (_currentStep == 4
                                      ? _buildStep4Content()
                                      : _buildStep5Content()))),
                    ),
                    const SizedBox(height: 24),
                    _buildStepButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepButtons() {
    final l10n = AppLocalizations.of(context);

    switch (_currentStep) {
      case 1:
        return ActionButton(
          text: l10n.continueButton,
          onPressed: _nextStepWithScroll,
          mainColor: AppColors.primary,
        );
      case 2:
        return Row(
          children: [
            SetupBackButton(
              onPressed: _currentStep > 1 ? _previousStep : null,
              mainColor: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: l10n.continueButton,
                onPressed: _selectedConfig == null ? null : _nextStepWithScroll,
                mainColor: AppColors.primary,
              ),
            ),
          ],
        );
      case 3:
        return Row(
          children: [
            SetupBackButton(
              onPressed: _currentStep > 1 ? _previousStep : null,
              mainColor: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: _selectedDutyGroup != null
                    ? l10n.continueButton
                    : l10n.skipPartnerSetup,
                onPressed: _selectedDutyGroup != null
                    ? _nextStepWithScroll
                    : _nextStepWithScroll,
                mainColor: AppColors.primary,
              ),
            ),
          ],
        );
      case 4:
        return Row(
          children: [
            SetupBackButton(
              onPressed: _currentStep > 1 ? _previousStep : null,
              mainColor: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: _selectedPartnerConfig != null
                    ? l10n.continueButton
                    : l10n.skipPartnerSetup,
                onPressed: _selectedPartnerConfig != null
                    ? _nextStepWithScroll
                    : () {
                        if (!_isGeneratingSchedules) {
                          _saveDefaultConfig();
                        }
                      },
                isLoading: _isGeneratingSchedules,
                mainColor: AppColors.primary,
              ),
            ),
          ],
        );
      case 5:
        return Row(
          children: [
            SetupBackButton(
              onPressed: _currentStep > 1 ? _previousStep : null,
              mainColor: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                text: l10n.continueButton,
                onPressed: () {
                  if (!_isGeneratingSchedules) {
                    _saveDefaultConfig();
                  }
                },
                isLoading: _isGeneratingSchedules,
                mainColor: AppColors.primary,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
