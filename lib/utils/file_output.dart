import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

class CustomFileOutput extends LogOutput {
  final String directory;
  final int maxFileSize;
  final int maxFiles;
  final String filePrefix;
  final String fileExtension;
  final LogPrinter printer;
  File? _currentFile;
  int _currentFileSize = 0;
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  bool _hasError = false;

  CustomFileOutput({
    required this.directory,
    this.maxFileSize = 1 * 1024 * 1024, // 1 MB default
    this.maxFiles = 5,
    this.filePrefix = 'app',
    this.fileExtension = 'log',
    LogPrinter? printer,
  }) : printer = printer ?? SimplePrinter(printTime: true, colors: false);

  @override
  void output(OutputEvent event) async {
    if (_hasError) return;

    try {
      if (_currentFile == null || _currentFileSize >= maxFileSize) {
        await _rotateFile();
      }

      if (_currentFile == null) {
        print('Failed to create log file in directory: $directory');
        _hasError = true;
        return;
      }

      final logMessage = event.lines.join('\n') + '\n';
      await _currentFile!.writeAsString(logMessage, mode: FileMode.append);
      _currentFileSize += logMessage.length;
    } catch (e) {
      _hasError = true;
      print('Failed to write to log file: $e');
    }
  }

  Future<void> _rotateFile() async {
    try {
      final dir = Directory(directory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Delete oldest file if we've reached maxFiles
      final files = await dir
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();
      files
          .sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

      if (files.length >= maxFiles) {
        await files.first.delete();
      }

      // Create new file with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = '$filePrefix-$timestamp.$fileExtension';
      _currentFile = File(p.join(directory, fileName));
      await _currentFile!.create(recursive: true);
      _currentFileSize = 0;
    } catch (e) {
      _hasError = true;
      print('Failed to rotate log file: $e');
    }
  }

  Future<void> cleanupOldLogs(Duration retention) async {
    try {
      final now = DateTime.now();
      final dir = Directory(directory);
      if (!await dir.exists()) return;

      for (final file in dir.listSync()) {
        if (file is File) {
          final stat = await file.stat();
          if (now.difference(stat.modified) > retention) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Failed to cleanup old logs: $e');
    }
  }
}
