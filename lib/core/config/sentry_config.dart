import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:flutter/foundation.dart';

class SentryConfig {
  static const String _dsn =
      'https://26cd4b7f0d4f1cf36308a96994e7a23a@o4509656380801024.ingest.de.sentry.io/4509656382701648';

  static String get dsn => _dsn;

  static void configureOptions(
      SentryFlutterOptions options, SentryService sentryService) {
    // Default: everything off
    double tracesSampleRate = 0.0;
    double profilesSampleRate = 0.0;
    double replaySessionSampleRate = 0.0;
    double replayOnErrorSampleRate = 0.0;

    if (sentryService.isEnabled) {
      if (kReleaseMode) {
        tracesSampleRate = 0.1;
        profilesSampleRate = 0.0;
        if (sentryService.isReplayEnabled) {
          replaySessionSampleRate = 0.1;
          replayOnErrorSampleRate = 1.0;
        }
      } else {
        tracesSampleRate = 1.0;
        profilesSampleRate = 1.0;
        if (sentryService.isReplayEnabled) {
          replaySessionSampleRate = 1.0;
          replayOnErrorSampleRate = 1.0;
        }
      }
    }

    options.tracesSampleRate = tracesSampleRate;
    options.profilesSampleRate = profilesSampleRate;
    options.replay.sessionSampleRate = replaySessionSampleRate;
    options.replay.onErrorSampleRate = replayOnErrorSampleRate;

    // Enable Sentry logs only when analytics and error reporting is enabled
    options.enableLogs = sentryService.isEnabled;
  }
}
