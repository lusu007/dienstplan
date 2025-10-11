import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/presentation/widgets/common/safe_area_wrapper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:dart_flutter_version/dart_flutter_version.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;
  List<File> _scheduleFiles = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      await _loadScheduleFiles();

      setState(() {
        _packageInfo = packageInfo;
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
      body: SafeAreaWrapper(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('App Information', [
                      _buildInfoRow('App Name', _packageInfo?.appName ?? 'N/A'),
                      _buildInfoRow(
                        'Package Name',
                        _packageInfo?.packageName ?? 'N/A',
                      ),
                      _buildInfoRow('Version', _packageInfo?.version ?? 'N/A'),
                      _buildInfoRow(
                        'Build Number',
                        _packageInfo?.buildNumber ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Full Version',
                        '${_packageInfo?.version ?? 'N/A'}+${_packageInfo?.buildNumber ?? 'N/A'}',
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('App-Specific Info', [
                      _buildInfoRow('Active Schedule', _getActiveSchedule()),
                      _buildInfoRow(
                        'Loaded Schedules',
                        _getLoadedSchedulesCount(),
                      ),
                      _buildInfoRow(
                        'Preferred Duty Group',
                        _getPreferredDutyGroup(),
                      ),
                      _buildInfoRow(
                        'Calendar Format',
                        _getCalendarFormat(l10n),
                      ),
                      _buildInfoRow('Language', _getCurrentLanguage()),
                      _buildInfoRow('Theme Preference', _getThemePreference()),
                      _buildInfoRow('Partner Config', _getPartnerConfigName()),
                      _buildInfoRow(
                        'Partner Duty Group',
                        _getPartnerDutyGroup(),
                      ),
                      _buildInfoRow('My Accent Color', _getMyAccentColor()),
                      _buildInfoRow(
                        'Partner Accent Color',
                        _getPartnerAccentColor(),
                      ),
                      _buildInfoRow(
                        'Holiday Accent Color',
                        _getHolidayAccentColor(),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Database & Storage', [
                      _buildInfoRow(
                        'Schedule Configs',
                        _getScheduleConfigsCount(),
                      ),
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
                    _buildSection('Services Status', [
                      _buildInfoRow('Sentry Enabled', _getSentryStatus()),
                      _buildInfoRow('Database Status', _getDatabaseStatus()),
                    ]),
                    const SizedBox(height: 24),
                    _buildSchoolHolidaysSection(),
                    const SizedBox(height: 24),
                    _buildScheduleFilesSection(),
                  ],
                ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: value is Widget
                ? value
                : Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getSentryStatus() {
    return 'Not Available';
  }

  String _getDatabaseStatus() {
    try {
      return 'Available';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _getFlutterVersion() {
    try {
      final versionInfo = DartFlutterVersion();
      final flutterVersion = versionInfo.flutterVersion;
      return flutterVersion?.toString() ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getDartVersion() {
    try {
      final versionInfo = DartFlutterVersion();
      final dartVersion = versionInfo.dartVersion;
      return dartVersion?.toString() ?? Platform.version;
    } catch (e) {
      return Platform.version;
    }
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
    final scheduleState = ref.read(scheduleCoordinatorProvider).value;
    return scheduleState?.activeConfigName ?? 'None';
  }

  String _getLoadedSchedulesCount() {
    final scheduleState = ref.read(scheduleCoordinatorProvider).value;
    return '${scheduleState?.schedules.length ?? 0} schedules';
  }

  String _getPreferredDutyGroup() {
    final scheduleState = ref.read(scheduleCoordinatorProvider).value;
    return scheduleState?.preferredDutyGroup ?? 'None';
  }

  String _getCalendarFormat(AppLocalizations l10n) {
    final scheduleState = ref.read(scheduleCoordinatorProvider).value;
    if (scheduleState == null) return 'Unknown';

    switch (scheduleState.calendarFormat) {
      case CalendarFormat.month:
        return 'Month';
      case CalendarFormat.twoWeeks:
        return 'Two Weeks';
      case CalendarFormat.week:
        return 'Week';
      default:
        return 'Unknown';
    }
  }

  String _getCurrentLanguage() {
    try {
      final languageService = ref.read(languageServiceProvider).value;
      return languageService?.currentLocale.languageCode ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getScheduleConfigsCount() {
    final scheduleState = ref.read(scheduleCoordinatorProvider).value;
    return '${scheduleState?.configs.length ?? 0} configs';
  }

  String _getCacheStatus() {
    final scheduleState = ref.read(scheduleCoordinatorProvider).value;
    return scheduleState?.schedules.isNotEmpty == true ? 'Active' : 'Empty';
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatColorAsHex(int colorValue) {
    return '#${colorValue.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  ({int size, DateTime lastModified}) _getFileInfo(File file) {
    final size = file.lengthSync();
    final lastModified = file.lastModifiedSync();
    return (size: size, lastModified: lastModified);
  }

  // Holiday helper methods
  String _getHolidayStatus() {
    final holidayState = ref.read(schoolHolidaysProvider).value;
    return holidayState?.isEnabled == true ? 'Enabled' : 'Disabled';
  }

  String _getHolidayStateCode() {
    final holidayState = ref.read(schoolHolidaysProvider).value;
    return holidayState?.selectedStateCode ?? 'None';
  }

  String _getHolidayStateName() {
    final holidayState = ref.read(schoolHolidaysProvider).value;
    final stateCode = holidayState?.selectedStateCode;
    if (stateCode == null) return 'N/A';

    // Map state codes to full names
    const stateNames = {
      'BW': 'Baden-Württemberg',
      'BY': 'Bavaria',
      'BE': 'Berlin',
      'BB': 'Brandenburg',
      'HB': 'Bremen',
      'HH': 'Hamburg',
      'HE': 'Hesse',
      'MV': 'Mecklenburg-Vorpommern',
      'NI': 'Lower Saxony',
      'NW': 'North Rhine-Westphalia',
      'RP': 'Rhineland-Palatinate',
      'SL': 'Saarland',
      'SN': 'Saxony',
      'ST': 'Saxony-Anhalt',
      'SH': 'Schleswig-Holstein',
      'TH': 'Thuringia',
    };

    return stateNames[stateCode] ?? stateCode;
  }

  String _getTotalHolidaysCount() {
    final holidayState = ref.read(schoolHolidaysProvider).value;
    return '${holidayState?.allHolidays.length ?? 0} holidays';
  }

  String _getHolidayLastRefresh() {
    final holidayState = ref.read(schoolHolidaysProvider).value;
    final lastRefresh = holidayState?.lastRefreshTime;
    if (lastRefresh == null) return 'Never';
    return _formatDate(lastRefresh);
  }

  // Settings helper methods
  String _getThemePreference() {
    final settings = ref.watch(settingsProvider).value;
    if (settings?.themePreference == null) return 'System';

    switch (settings!.themePreference) {
      case ThemePreference.system:
        return 'System';
      case ThemePreference.light:
        return 'Light';
      case ThemePreference.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }

  String _getPartnerConfigName() {
    final settings = ref.watch(settingsProvider).value;
    return settings?.partnerConfigName ?? 'None';
  }

  String _getPartnerDutyGroup() {
    final settings = ref.watch(settingsProvider).value;
    return settings?.partnerDutyGroup ?? 'None';
  }

  Widget _getMyAccentColor() {
    final settings = ref.watch(settingsProvider).value;
    final colorValue = settings?.myAccentColorValue;

    Color color;
    String hexString;

    if (colorValue == null) {
      // Use default my accent color
      color = AccentColorDefaults.myAccentColor;
      hexString =
          'Default (${_formatColorAsHex(AccentColorDefaults.myAccentColorValue)})';
    } else {
      color = Color(colorValue);
      hexString = _formatColorAsHex(colorValue);
    }

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          hexString,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _getPartnerAccentColor() {
    final settings = ref.watch(settingsProvider).value;
    final colorValue = settings?.partnerAccentColorValue;

    Color color;
    String hexString;

    if (colorValue == null) {
      // Use default partner accent color
      color = AccentColorDefaults.partnerAccentColor;
      hexString =
          'Default (${_formatColorAsHex(AccentColorDefaults.partnerAccentColorValue)})';
    } else {
      color = Color(colorValue);
      hexString = _formatColorAsHex(colorValue);
    }

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          hexString,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _getHolidayAccentColor() {
    final settings = ref.watch(settingsProvider).value;
    final colorValue = settings?.holidayAccentColorValue;

    Color color;
    String hexString;

    if (colorValue == null) {
      // Use default holiday accent color
      color = AccentColorDefaults.holidayAccentColor;
      hexString =
          'Default (${_formatColorAsHex(AccentColorDefaults.holidayAccentColorValue)})';
    } else {
      color = Color(colorValue);
      hexString = _formatColorAsHex(colorValue);
    }

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          hexString,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolHolidaysSection() {
    final holidayState = ref.read(schoolHolidaysProvider).value;

    return _buildSection('School Holidays', [
      _buildInfoRow('Feature Status', _getHolidayStatus()),
      _buildInfoRow('Selected State', _getHolidayStateCode()),
      _buildInfoRow('State Name', _getHolidayStateName()),
      _buildInfoRow('Total Holidays', _getTotalHolidaysCount()),
      _buildInfoRow('Last Refresh', _getHolidayLastRefresh()),
      if (holidayState?.allHolidays.isNotEmpty == true) ...[
        const SizedBox(height: 8),
        _buildUpcomingHolidays(),
      ],
    ]);
  }

  Widget _buildUpcomingHolidays() {
    final holidayState = ref.read(schoolHolidaysProvider).value;
    final holidays = holidayState?.allHolidays ?? [];

    if (holidays.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get next 3 holidays from today
    final now = DateTime.now();
    final upcomingHolidays =
        holidays.where((holiday) => holiday.endDate.isAfter(now)).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final displayHolidays = upcomingHolidays.take(3).toList();

    if (displayHolidays.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Holidays:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        ...displayHolidays.map(
          (holiday) => Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              '• ${holiday.name} (${_formatDate(holiday.startDate)} - ${_formatDate(holiday.endDate)})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadScheduleFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final configsDir = Directory('${appDir.path}/configs');

      if (configsDir.existsSync()) {
        _scheduleFiles = await configsDir
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.json'))
            .cast<File>()
            .toList();
      }
    } catch (e) {
      AppLogger.e('DebugScreen: Error loading schedule files', e);
    }
  }

  String _getScheduleFilesCount() {
    return '${_scheduleFiles.length} files';
  }

  Widget _buildScheduleFilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule Files',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Total Files', _getScheduleFilesCount()),
                const SizedBox(height: 12),
                if (_scheduleFiles.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  ..._scheduleFiles.map((file) => _buildScheduleFileItem(file)),
                ] else
                  Text(
                    'No schedule files found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleFileItem(File file) {
    final fileName = file.path.split('/').last;

    try {
      final fileInfo = _getFileInfo(file);
      return ListTile(
        title: Text(
          fileName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          '${_formatFileSize(fileInfo.size)} • ${_formatDate(fileInfo.lastModified)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.visibility),
        onTap: () => _viewScheduleFile(file),
      );
    } catch (e) {
      return ListTile(
        title: Text(
          fileName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Error loading file info',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.visibility),
        onTap: () => _viewScheduleFile(file),
      );
    }
  }

  Future<void> _viewScheduleFile(File file) async {
    try {
      final content = await file.readAsString();
      final fileName = file.path.split('/').last;

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _formatJson(content),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(content),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      AppLogger.e('DebugScreen: Error viewing schedule file', e);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading file: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _formatJson(String jsonString) {
    try {
      final jsonObject = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonObject);
    } catch (e) {
      return jsonString; // Return original if formatting fails
    }
  }

  Future<void> _copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Content copied to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
