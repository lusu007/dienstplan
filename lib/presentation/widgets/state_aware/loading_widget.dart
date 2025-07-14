import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingChild;
  final String? loadingText;

  const LoadingWidget({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingChild,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingChild ?? _buildDefaultLoadingWidget(context);
    }
    return child;
  }

  Widget _buildDefaultLoadingWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (loadingText != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingText!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlayWidget extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingChild;
  final Color? overlayColor;

  const LoadingOverlayWidget({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingChild,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withValues(alpha: 0.3),
            child: loadingChild ??
                const Center(
                  child: CircularProgressIndicator(),
                ),
          ),
      ],
    );
  }
}
