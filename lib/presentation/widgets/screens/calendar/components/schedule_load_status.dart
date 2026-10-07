import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/app_glass_button.dart';
import 'package:flutter/material.dart';

/// Keeps a failed or pending request distinct from a successful empty day.
class ScheduleLoadStatus extends StatelessWidget {
  const ScheduleLoadStatus({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.hasVisibleSchedules,
    required this.onRetry,
    required this.child,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool hasVisibleSchedules;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) {
      if (!isLoading || hasVisibleSchedules) return child;
      return const Center(child: CircularProgressIndicator());
    }
    final l10n = AppLocalizations.of(context);
    final notice = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          AppGlassButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.tryAgain),
            onPressed: isLoading ? null : onRetry,
          ),
        ],
      ),
    );
    if (!hasVisibleSchedules) {
      return Center(child: SingleChildScrollView(child: notice));
    }
    return Column(
      children: [
        notice,
        Expanded(child: child),
      ],
    );
  }
}
