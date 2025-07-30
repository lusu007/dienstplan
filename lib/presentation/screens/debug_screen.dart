import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/core/utils/app_info.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/presentation/controllers/schedule_controller.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/data/services/language_service.dart';
import 'package:get_it/get_it.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  PackageInfo? _packageInfo;
  ScheduleController? _scheduleController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final scheduleController =
          await GetIt.instance.getAsync<ScheduleController>();

      setState(() {
        _packageInfo = packageInfo;
        _scheduleController = scheduleController;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.e('DebugScreen: Error loading data', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Info'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('App Information', [
                    _buildInfoRow('App Name', _packageInfo?.appName ?? 'N/A'),
                    _buildInfoRow(
                        'Package Name', _packageInfo?.packageName ?? 'N/A'),
                    _buildInfoRow('Version', _packageInfo?.version ?? 'N/A'),
                    _buildInfoRow(
                        'Build Number', _packageInfo?.buildNumber ?? 'N/A'),
                    _buildInfoRow('Full Version',
                        '${_packageInfo?.version ?? 'N/A'}+${_packageInfo?.buildNumber ?? 'N/A'}'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('App-Specific Info', [
                    _buildInfoRow('Active Schedule', _getActiveSchedule()),
                    _buildInfoRow(
                        'Loaded Schedules', _getLoadedSchedulesCount()),
                    _buildInfoRow(
                        'Preferred Duty Group', _getPreferredDutyGroup()),
                    _buildInfoRow('Calendar Format', _getCalendarFormat(l10n)),
                    _buildInfoRow('Language', _getCurrentLanguage()),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Database & Storage', [
                    _buildInfoRow(
                        'Schedule Configs', _getScheduleConfigsCount()),
                    _buildInfoRow('Cache Status', _getCacheStatus()),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Technical Details', [
                    _buildInfoRow('Flutter Version', _getFlutterVersion()),
                    _buildInfoRow('Dart Version', _getDartVersion()),
                    _buildInfoRow('Platform', _getPlatform()),
                    _buildInfoRow('Build Type', _getBuildType()),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Development Info', [
                    _buildInfoRow('Contact Email', AppInfo.contactEmail),
                    _buildInfoRow('Privacy Policy', AppInfo.privacyPolicyUrl),
                    _buildInfoRow('Copyright', AppInfo.appLegalese),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('Services Status', [
                    _buildInfoRow('Sentry Enabled', _getSentryStatus()),
                    _buildInfoRow('Database Status', _getDatabaseStatus()),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSentryStatus() {
    try {
      final sentryService = GetIt.instance<SentryService>();
      return sentryService.isEnabled ? 'Enabled' : 'Disabled';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getDatabaseStatus() {
    try {
      return 'Available';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _getFlutterVersion() {
    return '3.32.7'; // This could be made dynamic
  }

  String _getDartVersion() {
    return '3.2.3'; // This could be made dynamic
  }

  String _getPlatform() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else {
      return 'Unknown';
    }
  }

  String _getActiveSchedule() {
    try {
      return _scheduleController?.activeConfig?.name ?? 'None';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _getLoadedSchedulesCount() {
    try {
      return '${_scheduleController?.schedules.length ?? 0} schedules';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _getPreferredDutyGroup() {
    try {
      return _scheduleController?.preferredDutyGroup ?? 'None';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _getCalendarFormat(AppLocalizations l10n) {
    try {
      if (_scheduleController == null) return 'Unknown';

      switch (_scheduleController!.calendarFormat) {
        case CalendarFormat.month:
          return l10n.calendarFormatMonth;
        case CalendarFormat.twoWeeks:
          return l10n.calendarFormatTwoWeeks;
        case CalendarFormat.week:
          return l10n.calendarFormatWeek;
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _getCurrentLanguage() {
    try {
      final languageService = GetIt.instance<LanguageService>();
      return languageService.currentLocale.languageCode == 'de'
          ? 'German'
          : 'English';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _getScheduleConfigsCount() {
    try {
      return '${_scheduleController?.configs.length ?? 0} configs';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _getCacheStatus() {
    try {
      return _scheduleController?.schedules.isNotEmpty == true
          ? 'Has cached data'
          : 'No cached data';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _getBuildType() {
    if (kDebugMode) {
      return 'Debug';
    } else if (kProfileMode) {
      return 'Profile';
    } else {
      return 'Release';
    }
  }
}
