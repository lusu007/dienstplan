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

  Future<void> _saveDefaultConfig() async {
    if (_selectedConfig == null) return;

    try {
      setState(() {
        _isGeneratingSchedules = true;
      });

      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);
      await _configService.setDefaultConfig(_selectedConfig!);
      await scheduleProvider.setActiveConfig(_selectedConfig!,
          generateSchedules: true);

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
    final l10n = AppLocalizations.of(context);
    final languageService = context.watch<LanguageService>();
    const mainColor = Color(0xFF005B8C);
    const disabledBlue = Color(0xFF1578AD); // Helleres Blau für disabled
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dienstplan'),
        backgroundColor: mainColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isGeneratingSchedules
                  ? null
                  : () {
                      const locales = LanguageService.supportedLocales;
                      final currentIndex =
                          locales.indexOf(languageService.currentLocale);
                      final nextIndex = (currentIndex + 1) % locales.length;
                      languageService
                          .setLanguage(locales[nextIndex].languageCode);
                    },
              child: Text(
                languageService.currentLocale.languageCode == 'de'
                    ? l10n.german
                    : l10n.english,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
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
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ..._configs.map((config) {
                      IconData icon;
                      if (config.meta.name.toLowerCase().contains('bepo')) {
                        icon = Icons.shield;
                      } else {
                        icon = Icons.directions_car;
                      }
                      final bool isSelected = _selectedConfig == config;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? mainColor.withAlpha(20)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected ? mainColor : Colors.grey.shade300,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: mainColor.withAlpha(46),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          minVerticalPadding: 20,
                          leading: Icon(icon, color: mainColor, size: 40),
                          title: Text(
                            config.meta.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            config.meta.description,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black87),
                          ),
                          trailing: SizedBox(
                            width: 32,
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: mainColor,
                              size: 28,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          selectedTileColor: Colors.transparent,
                          onTap: _isGeneratingSchedules
                              ? null
                              : () {
                                  setState(() {
                                    _selectedConfig = config;
                                  });
                                },
                        ),
                      );
                    }),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: SizedBox(
                        height: 56,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: disabledBlue,
                                  disabledForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  minimumSize: const Size.fromHeight(56),
                                  textStyle: const TextStyle(fontSize: 20),
                                ),
                                onPressed: _selectedConfig == null ||
                                        _isGeneratingSchedules
                                    ? null
                                    : _saveDefaultConfig,
                                child: _isGeneratingSchedules
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(l10n.generatingSchedules),
                                        ],
                                      )
                                    : Text(l10n.continueButton),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
