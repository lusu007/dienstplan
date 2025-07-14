import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? child;
  final String? retryText;
  final IconData? errorIcon;

  const ErrorDisplayWidget({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.child,
    this.retryText,
    this.errorIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return child ?? const SizedBox.shrink();
    }

    return _buildErrorWidget(context);
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorIcon ?? Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorSnackBarWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Duration duration;

  const ErrorSnackBarWidget({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.duration = const Duration(seconds: 4),
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErrorSnackBar(context);
    });

    return const SizedBox.shrink();
  }

  void _showErrorSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(errorMessage!),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: duration,
      action: onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry!,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
