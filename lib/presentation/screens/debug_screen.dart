import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/utils/logger.dart';
import 'package:dienstplan/core/constants/app_colors.dart';
import 'package:dienstplan/presentation/state/schedule/schedule_coordinator_notifier.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/presentation/widgets/common/safe_area_wrapper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

  String _getDartVersion() {
    return Platform.version;
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

  Future<void> _loadScheduleFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final configsDir = Directory('${appDir.path}/configs');

      if (configsDir.existsSync()) {
        final files = await configsDir.list().toList();
        _scheduleFiles = files
            .where((file) => file is File && file.path.endsWith('.json'))
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
    final fileSize = file.lengthSync();
    final lastModified = file.lastModifiedSync();

    return ListTile(
      title: Text(
        fileName,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        '${(fileSize / 1024).toStringAsFixed(1)} KB • ${lastModified.toString().split(' ')[0]}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.visibility),
      onTap: () => _viewScheduleFile(file),
    );
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
