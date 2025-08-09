import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/data/models/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:table_calendar/table_calendar.dart';
// Use cases are accessed via Riverpod providers
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_notifier.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
// Language service is accessed via Riverpod providers
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dienstplan/core/utils/icon_mapper.dart';
import 'package:dienstplan/presentation/widgets/common/step_indicator.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/action_button.dart';
import 'package:dienstplan/presentation/widgets/screens/setup/language_selector_button.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/app_info.dart';

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
  bool _hasMadeDutyGroupSelection = false;
  int _currentStep = 1;
  bool _isLoading = true;
  bool _isGeneratingSchedules = false;
  late final ScheduleConfigService _configService;
  late final SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }

  Future<void> _initializeServices() async {
    _prefs = await SharedPreferences.getInstance();
    _configService = ScheduleConfigService(_prefs);
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    try {
      AppLogger.i('Loading duty schedule configurations');
      await _configService.initialize();
      final configs = _configService.configs;
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
        });
      }
    }
  }

  void _nextStep() {
    if (_selectedConfig != null) {
      setState(() {
        _currentStep = 2;
        _selectedDutyGroup = null;
        _hasMadeDutyGroupSelection = false;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep = 1;
      _selectedDutyGroup = null;
    });
  }

  Future<void> _saveDefaultConfig() async {
    try {
      AppLogger.i('Starting setup completion process');
      setState(() {
        _isGeneratingSchedules = true;
      });

      // First set the default config and generate schedules
      await _configService.setDefaultConfig(_selectedConfig!);

      // Set the active config using the use case directly
      final setActiveConfigUseCase =
          await ref.read(setActiveConfigUseCaseProvider.future);
      await setActiveConfigUseCase.execute(_selectedConfig!.name);

      final generateSchedulesUseCase =
          await ref.read(generateSchedulesUseCaseProvider.future);

      final now = DateTime.now();
      final startDate =
          now.subtract(const Duration(days: 365 * 2)); // 2 years ago
      final endDate =
          now.add(const Duration(days: 365 * 3)); // 8 years in future

      await generateSchedulesUseCase.execute(
        configName: _selectedConfig!.name,
        startDate: startDate,
        endDate: endDate,
      );

      // Create initial settings to mark setup as completed
      final saveSettingsUseCase =
          await ref.read(saveSettingsUseCaseProvider.future);
      final initialSettings = Settings(
        calendarFormat: CalendarFormat.month,
        myDutyGroup: _selectedDutyGroup,
        activeConfigName: _selectedConfig!.name,
      );
      await saveSettingsUseCase.execute(initialSettings);

      // Mark setup as completed
      await _configService.markSetupCompleted();
      AppLogger.i(
          'Setup completed successfully for config: ${_selectedConfig!.name}');

      // Wait a moment to ensure all settings are properly saved
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Invalidate providers so AppInitializerWidget switches to CalendarScreen
      ref.invalidate(settingsNotifierProvider);
      ref.invalidate(scheduleNotifierProvider);

      // Optionally, show a short confirmation
      // and rely on AppInitializerWidget to rebuild automatically
    } catch (e, stackTrace) {
      AppLogger.e('Error saving default config', e, stackTrace);
      if (!mounted) return;
      setState(() {
        _isGeneratingSchedules = false;
      });
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorSavingDefaultConfig),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStep1Content() {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.welcome,
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
                    _selectedConfig = config;
                  });
                },
                mainColor: AppColors.primary,
              );
            }),
          const SizedBox(height: 32),
          ActionButton(
            text: l10n.continueButton,
            onPressed: _selectedConfig == null ? null : _nextStep,
            mainColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
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

    if (_selectedConfig == null) return const SizedBox.shrink();

    final dutyGroups = _selectedConfig!.dutyGroups;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.selectDutyGroup,
            style: const TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectDutyGroupMessage,
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
                  isSelected: _selectedDutyGroup == group.name,
                  onTap: () {
                    setState(() {
                      _selectedDutyGroup = group.name;
                      _hasMadeDutyGroupSelection = true;
                    });
                  },
                  mainColor: AppColors.primary,
                );
              }

              // Last item is "no preferred duty group"
              return SelectionCard(
                title: l10n.noDutyGroup,
                subtitle: l10n.noMyDutyGroupDescription,
                leadingIcon: Icons.clear,
                isSelected:
                    _selectedDutyGroup == null && _hasMadeDutyGroupSelection,
                onTap: () {
                  setState(() {
                    _selectedDutyGroup = null;
                    _hasMadeDutyGroupSelection = true;
                  });
                },
                mainColor: AppColors.primary,
              );
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  text: l10n.back,
                  onPressed: _previousStep,
                  isPrimary: false,
                  mainColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ActionButton(
                  text: l10n.continueButton,
                  onPressed: !_hasMadeDutyGroupSelection
                      ? null
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
          ),
          const SizedBox(height: 16),
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
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text(AppInfo.appName),
          backgroundColor: AppColors.primary,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(
          title: const Text(AppInfo.appName),
          backgroundColor: AppColors.primary,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: _buildStep1Content(),
      ),
      data: (languageService) => ListenableBuilder(
        listenable: languageService,
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppInfo.appName),
              backgroundColor: AppColors.primary,
              elevation: 0,
              automaticallyImplyLeading: false,
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
                      totalSteps: 2,
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _currentStep == 1
                          ? _buildStep1Content()
                          : _buildStep2Content(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
