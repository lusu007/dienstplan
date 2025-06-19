import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dienstplan/models/duty_schedule_config.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/services/schedule_config_service.dart';
import 'package:dienstplan/utils/logger.dart';
import 'calendar_screen.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:dienstplan/widgets/forms/step_indicator.dart';
import 'package:dienstplan/widgets/forms/selection_card.dart';
import 'package:dienstplan/widgets/forms/action_button.dart';
import 'package:dienstplan/widgets/forms/language_selector_button.dart';
import 'package:dienstplan/constants/app_colors.dart';
import 'package:dienstplan/utils/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);

      // First set the default config and generate schedules
      await _configService.setDefaultConfig(_selectedConfig!);
      await scheduleProvider.setActiveConfig(_selectedConfig!,
          generateSchedules: true);

      // Then save the preferred duty group from setup (can be null for "no preferred")
      scheduleProvider.preferredDutyGroup = _selectedDutyGroup;

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CalendarScreen()),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.welcome,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.welcomeMessage,
          style: const TextStyle(fontSize: 18),
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
        const Spacer(),
        ActionButton(
          text: l10n.continueButton,
          onPressed: _selectedConfig == null ? null : _nextStep,
          mainColor: AppColors.primary,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStep2Content() {
    final l10n = AppLocalizations.of(context);

    if (_selectedConfig == null) return const SizedBox.shrink();

    final dutyGroups = _selectedConfig!.dutyGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.selectDutyGroup,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.selectDutyGroupMessage,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 32),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dutyGroups.length +
                1, // +1 for "no preferred duty group" option
            itemBuilder: (context, index) {
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
        ),
        const SizedBox(height: 16),
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
                loadingText: l10n.generatingSchedules,
                mainColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getConfigIcon(DutyScheduleConfig config) {
    if (config.meta.name.toLowerCase().contains('bepo')) {
      return Icons.shield;
    } else {
      return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();

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
