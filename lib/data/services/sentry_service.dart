import 'package:shared_preferences/shared_preferences.dart';
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

      // Apply initial configuration
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
      _isEnabled = enabled;
      await _prefs.setBool(_sentryEnabledKey, enabled);

      // If disabling, also disable replay
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

  Future<void> captureException(dynamic exception, dynamic stackTrace) async {
    try {
      if (!_isEnabled) {
        AppLogger.d('Sentry disabled, skipping exception capture');
        return;
      }

      // Note: Actual Sentry capture would be implemented here
      // For now, just log the exception
      AppLogger.e(
        'Sentry would capture exception: $exception',
        exception,
        stackTrace,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error capturing exception in Sentry', e, stackTrace);
    }
  }

  Future<void> captureMessage(String message) async {
    try {
      if (!_isEnabled) {
        AppLogger.d('Sentry disabled, skipping message capture');
        return;
      }

      // Note: Actual Sentry capture would be implemented here
      // For now, just log the message
      AppLogger.i('Sentry would capture message: $message');
    } catch (e, stackTrace) {
      AppLogger.e('Error capturing message in Sentry', e, stackTrace);
    }
  }

  Future<void> _applyConfiguration() async {
    try {
      // Note: Actual SDK init is idempotent in AppInitializer.initializeSentry.
      // This method only logs current configuration and not re-init the SDK.
      AppLogger.i(
        'Sentry configuration updated - enabled: $_isEnabled, replay: $_isReplayEnabled',
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error applying Sentry configuration', e, stackTrace);
    }
  }
}
