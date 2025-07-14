import 'package:flutter/material.dart';
import 'package:dienstplan/data/models/duty_schedule_config.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/data/services/schedule_config_service.dart';
import 'package:get_it/get_it.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/utils/icon_mapper.dart';
import 'calendar_screen.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/forms/step_indicator.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/forms/selection_card.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/forms/action_button.dart';
import 'package:dienstplan/presentation/widgets/extra_widgets/forms/language_selector_button.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dienstplan/domain/use_cases/set_active_config_use_case.dart';
import 'package:dienstplan/domain/use_cases/generate_schedules_use_case.dart';
import 'package:dienstplan/main.dart';
import 'package:dienstplan/presentation/controllers/settings_controller.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:table_calendar/table_calendar.dart';

class FirstTimeSetupScreen extends StatefulWidget {
  const FirstTimeSetupScreen({super.key});

  @override
  State<FirstTimeSetupScreen> createState() => _FirstTimeSetupScreenState();
}

class _FirstTimeSetupScreenState extends State<FirstTimeSetupScreen> {
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

  Future<void> _initializeServices() async {
    _prefs = await SharedPreferences.getInstance();
    _configService = ScheduleConfigService(_prefs);
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    try {
      await _configService.initialize();
      final configs = _configService.configs;
      setState(() {
        _configs = configs;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.e('Error loading configs', e, stackTrace);
      setState(() {
        _isLoading = false;
      });
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
    if (_selectedConfig == null) return;

    try {
      setState(() {
        _isGeneratingSchedules = true;
      });

      final scheduleController =
          await GetIt.instance.getAsync<ScheduleController>();

      // First set the default config and generate schedules
      await _configService.setDefaultConfig(_selectedConfig!);

      // Load configs in schedule controller first
      await scheduleController.loadConfigs();

      // Set the active config using the use case directly to avoid type mismatch
      final setActiveConfigUseCase =
          await GetIt.instance.getAsync<SetActiveConfigUseCase>();
      await setActiveConfigUseCase.execute(_selectedConfig!.name);

      // Also set the active config directly in the schedule controller
      // Find the domain entity version of the config
      final domainConfig = scheduleController.configs.firstWhere(
        (config) => config.name == _selectedConfig!.name,
      );
      scheduleController.setActiveConfigDirectly(domainConfig);

      // Generate schedules for 5 years total (2 years back, 3 years forward)
      final generateSchedulesUseCase =
          await GetIt.instance.getAsync<GenerateSchedulesUseCase>();

      final now = DateTime.now();
      final startDate =
          now.subtract(const Duration(days: 365 * 2)); // 2 years ago
      final endDate =
          now.add(const Duration(days: 365 * 3)); // 3 years in future

      await generateSchedulesUseCase.execute(
        configName: _selectedConfig!.name,
        startDate: startDate,
        endDate: endDate,
      );

      // Then save the preferred duty group from setup (can be null for "no preferred")
      scheduleController.preferredDutyGroup = _selectedDutyGroup;

      // Create initial settings to mark setup as completed
      final settingsController =
          await GetIt.instance.getAsync<SettingsController>();
      final initialSettings = Settings(
        focusedDay: DateTime.now(),
        selectedDay: DateTime.now(),
        calendarFormat: CalendarFormat.month,
        preferredDutyGroup: _selectedDutyGroup,
        activeConfigName: _selectedConfig!.name,
      );
      print(
          'DEBUG FirstTimeSetup: Saving settings with activeConfigName: ${_selectedConfig!.name}');
      await settingsController.saveSettings(initialSettings);
      print('DEBUG FirstTimeSetup: Settings saved successfully');

      // Also save the active config directly using the schedule controller's method
      print(
          'DEBUG FirstTimeSetup: Setting active config in schedule controller: ${domainConfig.name}');
      await scheduleController.setActiveConfig(domainConfig);
      print('DEBUG FirstTimeSetup: Active config set in schedule controller');

      // Mark setup as completed
      await _configService.markSetupCompleted();

      if (!mounted) return;

      // Instead of navigation, restart the app to trigger AppInitializer
      // This will cause the app to check setup status again and show CalendarScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false,
      );
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
                title: l10n.noPreferredDutyGroup,
                subtitle: l10n.noPreferredDutyGroupDescription,
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
    final languageService = GetIt.instance<LanguageService>();

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
            onLanguageChanged: null, // Remove callback to prevent double update
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
  }
}
