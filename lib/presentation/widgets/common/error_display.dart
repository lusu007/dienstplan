import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/errors/failure_presenter.dart';
import 'package:dienstplan/core/errors/exception_mapper.dart';
import 'package:dienstplan/domain/failures/failure.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

/// A reusable widget for displaying errors using FailurePresenter
/// Provides consistent error handling across all screens
class ErrorDisplay extends ConsumerWidget {
  final Object error;
  final StackTrace? stackTrace;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.stackTrace,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.iconSize = 48,
    this.textAlign = TextAlign.center,
    this.textStyle,
    this.onRetry,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder(
      future: ref.read(languageServiceProvider.future),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        const presenter = FailurePresenter();
        const mapper = ExceptionMapper();

        final Failure failure = error is Failure
            ? error as Failure
            : mapper.mapToFailure(error, stackTrace);

        final String message = presenter.present(failure, l10n);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: iconSize, color: iconColor),
            if (icon != null) const SizedBox(height: 16),
            Text(message, textAlign: textAlign, style: textStyle),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryButtonText ?? l10n.continueButton),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// A simplified error display for SnackBars and similar contexts
class ErrorMessage extends ConsumerWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorMessage({super.key, required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder(
      future: ref.read(languageServiceProvider.future),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(l10n.genericUnknownError);
        }

        const presenter = FailurePresenter();
        const mapper = ExceptionMapper();

        final Failure failure = error is Failure
            ? error as Failure
            : mapper.mapToFailure(error, stackTrace);

        final String message = presenter.present(failure, l10n);
        return Text(message);
      },
    );
  }
}

/// A centered error display for full-screen error states
class CenteredErrorDisplay extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const CenteredErrorDisplay({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ErrorDisplay(
          error: error,
          stackTrace: stackTrace,
          onRetry: onRetry,
        ),
      ),
    );
  }
}
