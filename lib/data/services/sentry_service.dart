import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/config/sentry_config.dart';
import 'package:dienstplan/core/utils/logger.dart';

class SentryState {
  final bool isEnabled;
  final bool isReplayEnabled;

  const SentryState({required this.isEnabled, required this.isReplayEnabled});

  SentryState copyWith({bool? isEnabled, bool? isReplayEnabled}) {
    return SentryState(
      isEnabled: isEnabled ?? this.isEnabled,
      isReplayEnabled: isReplayEnabled ?? this.isReplayEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SentryState &&
        other.isEnabled == isEnabled &&
        other.isReplayEnabled == isReplayEnabled;
  }

  @override
  int get hashCode => isEnabled.hashCode ^ isReplayEnabled.hashCode;
}

class SentryService {
  static const String _sentryEnabledKey = 'sentry_enabled';
  static const String _sentryReplayEnabledKey = 'sentry_replay_enabled';

  static bool _uploadsAllowed = true;

  /// When false, [beforeSend] hooks drop all payloads (events, feedback, logs, transactions).
  static bool get uploadsAllowed => _uploadsAllowed;

  late SharedPreferences _prefs;
  bool _isEnabled = true;
  bool _isReplayEnabled = false;

  bool get isEnabled => _isEnabled;
  bool get isReplayEnabled => _isReplayEnabled;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isEnabled = _prefs.getBool(_sentryEnabledKey) ?? true;
      _isReplayEnabled = _prefs.getBool(_sentryReplayEnabledKey) ?? false;
      _uploadsAllowed = _isEnabled;
      await _applyConfiguration();

      AppLogger.i(
        'SentryService initialized - enabled: $_isEnabled, replay: $_isReplayEnabled',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing SentryService', e, stackTrace);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    try {
      _uploadsAllowed = enabled;
      _isEnabled = enabled;
      await _prefs.setBool(_sentryEnabledKey, enabled);
      if (!enabled) {
        await setReplayEnabled(false);
      }
      await _applyConfiguration();
      AppLogger.i('Sentry enabled set to: $enabled');
    } catch (e, stackTrace) {
      AppLogger.e('Error setting Sentry enabled', e, stackTrace);
    }
  }

  Future<void> setReplayEnabled(bool enabled) async {
    try {
      _isReplayEnabled = enabled;
      await _prefs.setBool(_sentryReplayEnabledKey, enabled);
      await _applyConfiguration();
      AppLogger.i('Sentry replay enabled set to: $enabled');
    } catch (e, stackTrace) {
      AppLogger.e('Error setting Sentry replay enabled', e, stackTrace);
    }
  }

  /// Call once after [SentryFlutter.init] so hub options match persisted prefs.
  Future<void> syncSdkDynamicOptionsAfterInit() async {
    await _applyConfiguration();
  }

  Future<void> captureException(
    Object exception,
    StackTrace? stackTrace,
  ) async {
    try {
      if (!_isEnabled || !Sentry.isEnabled) {
        AppLogger.d('Sentry disabled, skipping exception capture');
        return;
      }
      await Sentry.captureException(exception, stackTrace: stackTrace);
    } catch (e, st) {
      debugPrint('Sentry captureException failed (e=$e, st=$st)');
    }
  }

  Future<void> captureMessage(String message) async {
    try {
      if (!_isEnabled || !Sentry.isEnabled) {
        AppLogger.d('Sentry disabled, skipping message capture');
        return;
      }
      await Sentry.captureMessage(message);
    } catch (e, st) {
      debugPrint('Sentry captureMessage failed (e=$e, st=$st)');
    }
  }

  Future<void> _applyConfiguration() async {
    try {
      if (!Sentry.isEnabled) {
        AppLogger.i(
          'Sentry configuration updated (hub not ready) - enabled: $_isEnabled, replay: $_isReplayEnabled',
        );
        return;
      }
      SentryConfig.syncRuntimeOptions(this);
      AppLogger.i(
        'Sentry configuration updated - enabled: $_isEnabled, replay: $_isReplayEnabled',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error applying Sentry configuration', e, stackTrace);
    }
  }
}
