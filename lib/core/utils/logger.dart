// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/constants/logger_constants.dart';

class AppLogger {
  static const String _logDirName = 'logs';
  static Directory? _logDir;
  static File? _currentLogFile;
  static const int _maxLogFiles = kMaxLogFiles;
  static ProviderContainer? _providerContainer;

  static void setProviderContainer(ProviderContainer container) {
    _providerContainer = container;
  }

  static Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _logDir = Directory(path.join(appDir.path, _logDirName));
      if (!_logDir!.existsSync()) {
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

      // Always print to console for debugging
      if (error != null) {
        print('$logMessage ERROR: $error');
        if (stackTrace != null) {
          print(stackTrace);
        }
      } else {
        print(logMessage);
      }

      // Write to local log file
      await _currentLogFile!
          .writeAsString('$logMessage\n', mode: FileMode.append);

      // Send to Sentry if available, enabled, and SDK initialized
      try {
        // Check if Sentry service is available and enabled via injected container
        final sentryService =
            _providerContainer?.read(sentryServiceProvider).valueOrNull;

        if (sentryService != null &&
            sentryService.isEnabled &&
            Sentry.isEnabled) {
          final sentryLevel = _mapToSentryLevel(level);
          if (error != null) {
            Sentry.logger.error(
              message,
              attributes: {
                'local_level': SentryLogAttribute.string(level),
                'timestamp': SentryLogAttribute.string(timestamp),
              },
            );
          } else {
            switch (sentryLevel) {
              case SentryLogLevel.debug:
                Sentry.logger.debug(
                  message,
                  attributes: {
                    'local_level': SentryLogAttribute.string(level),
                    'timestamp': SentryLogAttribute.string(timestamp),
                  },
                );
                break;
              case SentryLogLevel.info:
                Sentry.logger.info(
                  message,
                  attributes: {
                    'local_level': SentryLogAttribute.string(level),
                    'timestamp': SentryLogAttribute.string(timestamp),
                  },
                );
                break;
              case SentryLogLevel.warn:
                Sentry.logger.warn(
                  message,
                  attributes: {
                    'local_level': SentryLogAttribute.string(level),
                    'timestamp': SentryLogAttribute.string(timestamp),
                  },
                );
                break;
              case SentryLogLevel.error:
                Sentry.logger.error(
                  message,
                  attributes: {
                    'local_level': SentryLogAttribute.string(level),
                    'timestamp': SentryLogAttribute.string(timestamp),
                  },
                );
                break;
              case SentryLogLevel.fatal:
                Sentry.logger.fatal(
                  message,
                  attributes: {
                    'local_level': SentryLogAttribute.string(level),
                    'timestamp': SentryLogAttribute.string(timestamp),
                  },
                );
                break;
              default:
                Sentry.logger.info(
                  message,
                  attributes: {
                    'local_level': SentryLogAttribute.string(level),
                    'timestamp': SentryLogAttribute.string(timestamp),
                  },
                );
            }
          }
        }
      } catch (sentryError) {
        // Don't let Sentry errors break local logging
        print('Failed to send log to Sentry: $sentryError');
      }
    } catch (e) {
      print('Failed to write log: $e');
    }
  }

  static SentryLogLevel _mapToSentryLevel(String level) {
    switch (level) {
      case 'D':
        return SentryLogLevel.debug;
      case 'I':
        return SentryLogLevel.info;
      case 'W':
        return SentryLogLevel.warn;
      case 'E':
        return SentryLogLevel.error;
      default:
        return SentryLogLevel.info;
    }
  }

  static Future<void> d(String message) async => _writeLog('D', message);
  static Future<void> i(String message) async => _writeLog('I', message);
  static Future<void> w(String message) async => _writeLog('W', message);
  static Future<void> e(String message,
          [Object? error, StackTrace? stackTrace]) async =>
      _writeLog('E', message, error, stackTrace);
}
