import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static const String _logDirName = 'logs';
  static Directory? _logDir;
  static File? _currentLogFile;
  static const int _maxLogFiles = 5;

  static Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _logDir = Directory(path.join(appDir.path, _logDirName));
      if (!await _logDir!.exists()) {
        await _logDir!.create(recursive: true);
      }
      await _rotateLogs();
      _currentLogFile = await _createNewLogFile();
      i('Logger initialized in directory: ${_logDir!.path}');
    } catch (e) {
      print('Failed to initialize logger: $e');
    }
  }

  static Future<void> _rotateLogs() async {
    try {
      if (_logDir == null) return;

      final files = await _logDir!.list().toList();
      files.sort((a, b) => b.path.compareTo(a.path));

      for (var i = _maxLogFiles; i < files.length; i++) {
        await files[i].delete();
      }
    } catch (e) {
      print('Failed to rotate log files: $e');
    }
  }

  static Future<File> _createNewLogFile() async {
    if (_logDir == null) {
      throw Exception('Logger not initialized');
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final logFile = File(path.join(_logDir!.path, 'app-$timestamp.log'));
    await logFile.create();
    return logFile;
  }

  static Future<void> _writeLog(String level, String message,
      [Object? error, StackTrace? stackTrace]) async {
    try {
      if (_currentLogFile == null) {
        await initialize();
      }

      final timestamp = DateTime.now().toIso8601String();
      final logMessage = '[$level] TIME: $timestamp $message';

      if (error != null) {
        print('$logMessage ERROR: $error');
        if (stackTrace != null) {
          print(stackTrace);
        }
      } else {
        print(logMessage);
      }

      await _currentLogFile!
          .writeAsString('$logMessage\n', mode: FileMode.append);
    } catch (e) {
      print('Failed to write log: $e');
    }
  }

  static Future<void> d(String message) async => _writeLog('D', message);
  static Future<void> i(String message) async => _writeLog('I', message);
  static Future<void> w(String message) async => _writeLog('W', message);
  static Future<void> e(String message,
          [Object? error, StackTrace? stackTrace]) async =>
      _writeLog('E', message, error, stackTrace);
}
