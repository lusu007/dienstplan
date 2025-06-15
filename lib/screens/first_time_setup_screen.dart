import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dienstplan/models/duty_schedule_config.dart';
import 'package:dienstplan/providers/schedule_provider.dart';
import 'package:dienstplan/services/schedule_config_service.dart';
import 'package:dienstplan/utils/logger.dart';
import 'calendar_screen.dart';
import 'package:dienstplan/l10n/app_localizations.dart';
import 'package:dienstplan/services/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeSetupScreen extends StatefulWidget {
  const FirstTimeSetupScreen({super.key});

  @override
  State<FirstTimeSetupScreen> createState() => _FirstTimeSetupScreenState();
}

class _FirstTimeSetupScreenState extends State<FirstTimeSetupScreen> {
  List<DutyScheduleConfig> _configs = [];
  DutyScheduleConfig? _selectedConfig;
  bool _isLoading = true;
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

  Future<void> _saveDefaultConfig() async {
    if (_selectedConfig == null) return;

    try {
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);
      await _configService.setDefaultConfig(_selectedConfig!);
      await scheduleProvider.setActiveConfig(_selectedConfig!);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CalendarScreen()),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error saving default config', e, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving default configuration'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = context.watch<LanguageService>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcome),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownButton<Locale>(
                        value: languageService.currentLocale,
                        icon: const Icon(Icons.language),
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            languageService.setLanguage(newLocale.languageCode);
                          }
                        },
                        items: LanguageService.supportedLocales.map((locale) {
                          return DropdownMenuItem<Locale>(
                            value: locale,
                            child: Text(
                              locale.languageCode == 'de'
                                  ? l10n.german
                                  : l10n.english,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.welcomeMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _configs.length,
                      itemBuilder: (context, index) {
                        final config = _configs[index];
                        return Card(
                          child: RadioListTile<DutyScheduleConfig>(
                            title: Text(config.meta.name),
                            subtitle: Text(config.meta.description),
                            value: config,
                            groupValue: _selectedConfig,
                            onChanged: (value) {
                              setState(() {
                                _selectedConfig = value;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        _selectedConfig == null ? null : _saveDefaultConfig,
                    child: Text(l10n.continueButton),
                  ),
                ],
              ),
            ),
    );
  }
}
