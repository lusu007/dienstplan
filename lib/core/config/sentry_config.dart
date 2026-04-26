import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/config/contact_feedback_copy.dart';
import 'package:dienstplan/core/routing/root_navigator.dart';
import 'package:dienstplan/core/telemetry/sentry_telemetry.dart';
import 'package:dienstplan/data/services/sentry_service.dart';

class SentryConfig {
  static const String _dsn =
      'https://26cd4b7f0d4f1cf36308a96994e7a23a@o4509656380801024.ingest.de.sentry.io/4509656382701648';

  static String get dsn => _dsn;

  static SentryFlutterOptions? _registeredFlutterOptions;

  /// Same instance passed to [SentryFlutter.init]; safe for runtime sampling updates.
  static void syncRuntimeOptions(SentryService sentryService) {
    final SentryFlutterOptions? options = _registeredFlutterOptions;
    if (options != null) {
      applyRuntimeDynamicOptions(options, sentryService);
    }
  }

  /// Sampling, replay, and Sentry logs — safe to re-apply when the user toggles privacy settings.
  static void applyRuntimeDynamicOptions(
    SentryFlutterOptions options,
    SentryService sentryService,
  ) {
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
    // ignore: experimental_member_use
    options.profilesSampleRate = profilesSampleRate;
    options.replay.sessionSampleRate = replaySessionSampleRate;
    options.replay.onErrorSampleRate = replayOnErrorSampleRate;
    options.enableLogs = sentryService.isEnabled;
    options.enableAutoSessionTracking = sentryService.isEnabled;
  }

  static void configureOptions(
    SentryFlutterOptions options,
    SentryService sentryService,
    PackageInfo packageInfo,
  ) {
    _registeredFlutterOptions = options;
    options.dsn = dsn;
    options.navigatorKey = rootNavigatorKey;
    options.environment = kReleaseMode ? 'production' : 'development';
    options.release =
        '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}';
    options.dist = packageInfo.buildNumber;
    options.sendDefaultPii = false;
    options.attachScreenshot = true;
    options.beforeCaptureScreenshot = (_, _, _) => false;
    options.enableUserInteractionTracing = false;
    applyRuntimeDynamicOptions(options, sentryService);
    _configureFeedbackUi(options);
    options.beforeSend = (SentryEvent event, Hint hint) {
      if (!SentryService.uploadsAllowed) {
        return null;
      }
      return event;
    };
    options.beforeSendTransaction = (SentryTransaction transaction, Hint hint) {
      if (!SentryService.uploadsAllowed) {
        return null;
      }
      return transaction;
    };
    options.beforeSendFeedback = (SentryEvent event, Hint hint) {
      if (!SentryService.uploadsAllowed) {
        return null;
      }
      return event;
    };
    options.beforeBreadcrumb = SentryTelemetry.beforeBreadcrumb;
    options.beforeSendLog = (SentryLog log) {
      return SentryTelemetry.beforeSendLog(log);
    };
  }

  static void _configureFeedbackUi(SentryFlutterOptions options) {
    options.feedback.title = ContactFeedbackCopy.title;
    options.feedback.formTitle = ContactFeedbackCopy.title;
    options.feedback.showBranding = false;
    options.feedback.isNameRequired = false;
    options.feedback.showName = true;
    options.feedback.isEmailRequired = false;
    options.feedback.showEmail = true;
    options.feedback.useSentryUser = true;
    options.feedback.showCaptureScreenshot = true;
    options.feedback.messageLabel = ContactFeedbackCopy.messageLabel;
    options.feedback.messagePlaceholder =
        ContactFeedbackCopy.messagePlaceholder;
    options.feedback.isRequiredLabel = ContactFeedbackCopy.requiredLabel;
    options.feedback.successMessageText = ContactFeedbackCopy.successMessage;
    options.feedback.nameLabel = ContactFeedbackCopy.nameLabel;
    options.feedback.namePlaceholder = ContactFeedbackCopy.namePlaceholder;
    options.feedback.emailLabel = ContactFeedbackCopy.emailLabel;
    options.feedback.emailPlaceholder = ContactFeedbackCopy.emailPlaceholder;
    options.feedback.submitButtonLabel = ContactFeedbackCopy.submitButton;
    options.feedback.cancelButtonLabel = ContactFeedbackCopy.cancelButton;
    options.feedback.validationErrorLabel = ContactFeedbackCopy.validationError;
    options.feedback.captureScreenshotButtonLabel =
        ContactFeedbackCopy.captureScreenshotButton;
    options.feedback.removeScreenshotButtonLabel =
        ContactFeedbackCopy.removeScreenshotButton;
    options.feedback.takeScreenshotButtonLabel =
        ContactFeedbackCopy.captureScreenshotButton;
  }
}
