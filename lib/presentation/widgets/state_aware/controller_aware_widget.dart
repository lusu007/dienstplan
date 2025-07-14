import 'package:flutter/material.dart';
import 'package:dienstplan/presentation/widgets/state_aware/loading_widget.dart';
import 'package:dienstplan/presentation/widgets/state_aware/error_widget.dart';

class ControllerAwareWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final Widget child;
  final Widget? loadingChild;
  final String? loadingText;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showErrorSnackBar;
  final Duration errorSnackBarDuration;

  const ControllerAwareWidget({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.child,
    this.loadingChild,
    this.loadingText,
    this.onRetry,
    this.retryText,
    this.showErrorSnackBar = false,
    this.errorSnackBarDuration = const Duration(seconds: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with loading and error handling
        LoadingWidget(
          isLoading: isLoading,
          loadingChild: loadingChild,
          loadingText: loadingText,
          child: ErrorDisplayWidget(
            errorMessage: errorMessage,
            onRetry: onRetry,
            retryText: retryText,
            child: child,
          ),
        ),

        // Error snackbar if enabled
        if (showErrorSnackBar)
          ErrorSnackBarWidget(
            errorMessage: errorMessage,
            onRetry: onRetry,
            duration: errorSnackBarDuration,
          ),
      ],
    );
  }
}

class ScheduleControllerAwareWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final Widget child;
  final VoidCallback? onRetry;
  final bool showErrorSnackBar;

  const ScheduleControllerAwareWidget({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.child,
    this.onRetry,
    this.showErrorSnackBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return ControllerAwareWidget(
      isLoading: isLoading,
      errorMessage: errorMessage,
      loadingText: 'Loading schedules...',
      onRetry: onRetry,
      retryText: 'Retry',
      showErrorSnackBar: showErrorSnackBar,
      child: child,
    );
  }
}

class SettingsControllerAwareWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final Widget child;
  final VoidCallback? onRetry;
  final bool showErrorSnackBar;

  const SettingsControllerAwareWidget({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.child,
    this.onRetry,
    this.showErrorSnackBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return ControllerAwareWidget(
      isLoading: isLoading,
      errorMessage: errorMessage,
      loadingText: 'Loading settings...',
      onRetry: onRetry,
      retryText: 'Retry',
      showErrorSnackBar: showErrorSnackBar,
      child: child,
    );
  }
}
