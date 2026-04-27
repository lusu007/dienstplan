import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/data/services/sentry_service.dart';

typedef SentryBreadcrumbSink = Future<void> Function(Breadcrumb breadcrumb);

typedef SentryTransactionStarter =
    ISentrySpan Function(String name, String operation);

class SentryTelemetry {
  static const int _maxStringValueLength = 160;

  static SentryBreadcrumbSink _breadcrumbSink = Sentry.addBreadcrumb;
  static SentryTransactionStarter _transactionStarter = _startSentryTransaction;

  static Future<void> recordBreadcrumb({
    required String category,
    required String message,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!SentryService.uploadsAllowed || !Sentry.isEnabled) {
      return;
    }

    final Breadcrumb? breadcrumb = beforeBreadcrumb(
      Breadcrumb(
        category: category,
        message: message,
        data: data,
        level: level,
      ),
      Hint(),
    );
    if (breadcrumb == null) {
      return;
    }

    try {
      await _breadcrumbSink(breadcrumb);
    } catch (error) {
      debugPrint(
        'Failed to record Sentry breadcrumb (category=$category, errorType=${error.runtimeType})',
      );
    }
  }

  static Future<T> traceOperation<T>({
    required String name,
    required String operation,
    Map<String, dynamic>? data,
    required FutureOr<T> Function(ISentrySpan? span) run,
  }) async {
    if (!SentryService.uploadsAllowed || !Sentry.isEnabled) {
      return await run(null);
    }

    final ISentrySpan span = _transactionStarter(name, operation);
    final Map<String, dynamic>? safeData = sanitizeData(data);
    if (safeData != null) {
      for (final entry in safeData.entries) {
        span.setData(entry.key, entry.value);
      }
    }

    try {
      final T result = await run(span);
      await span.finish(status: const SpanStatus.ok());
      return result;
    } catch (error) {
      span.throwable = error;
      await span.finish(status: const SpanStatus.internalError());
      rethrow;
    }
  }

  static Breadcrumb? beforeBreadcrumb(
    Breadcrumb? breadcrumb,
    Hint hint, {
    bool? uploadsAllowed,
  }) {
    if (!(uploadsAllowed ?? SentryService.uploadsAllowed)) {
      return null;
    }
    if (breadcrumb == null) {
      return null;
    }
    breadcrumb.data = sanitizeData(breadcrumb.data);
    return breadcrumb;
  }

  static SentryLog? beforeSendLog(
    SentryLog log, {
    bool? uploadsAllowed,
    bool? isRelease,
  }) {
    if (!(uploadsAllowed ?? SentryService.uploadsAllowed)) {
      return null;
    }

    final bool releaseMode = isRelease ?? kReleaseMode;
    if (releaseMode && log.level == SentryLogLevel.debug) {
      return null;
    }

    if (_containsLikelySensitiveBody(log.body)) {
      return null;
    }

    return log;
  }

  @visibleForTesting
  static Map<String, dynamic>? sanitizeData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return null;
    }

    final Map<String, dynamic> sanitized = <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry in data.entries) {
      if (_isSensitiveKey(entry.key)) {
        continue;
      }

      final dynamic value = entry.value;
      if (value is String) {
        sanitized[entry.key] = _boundString(value);
      } else if (value is num || value is bool) {
        sanitized[entry.key] = value;
      }
    }

    return sanitized.isEmpty ? null : sanitized;
  }

  @visibleForTesting
  static void setTestHooks({
    SentryBreadcrumbSink? breadcrumbSink,
    SentryTransactionStarter? transactionStarter,
  }) {
    _breadcrumbSink = breadcrumbSink ?? Sentry.addBreadcrumb;
    _transactionStarter = transactionStarter ?? _startSentryTransaction;
  }

  static ISentrySpan _startSentryTransaction(String name, String operation) {
    return Sentry.startTransaction(name, operation, bindToScope: true);
  }

  static bool _isSensitiveKey(String key) {
    final String normalized = key.toLowerCase();
    const List<String> sensitiveFragments = <String>[
      'authorization',
      'body',
      'cookie',
      'description',
      'email',
      'message',
      'name',
      'note',
      'password',
      'requestdata',
      'responsedata',
      'secret',
      'settings',
      'summary',
      'text',
      'title',
      'token',
    ];

    return sensitiveFragments.any(normalized.contains);
  }

  static bool _containsLikelySensitiveBody(String body) {
    final String normalized = body.toLowerCase();
    const List<String> sensitiveFragments = <String>[
      '@',
      'authorization',
      'cookie',
      'password',
      'request data',
      'requestdata',
      'response data',
      'responsedata',
      'retrieved settings',
      'save settings',
      'secret',
      'token',
    ];

    return sensitiveFragments.any(normalized.contains);
  }

  static String _boundString(String value) {
    if (value.length <= _maxStringValueLength) {
      return value;
    }
    return value.substring(0, _maxStringValueLength);
  }
}
