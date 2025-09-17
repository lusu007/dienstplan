import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class DutyScheduleHeader extends StatelessWidget {
  final DateTime? selectedDay;

  const DutyScheduleHeader({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            l10n.services,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            selectedDay != null
                ? l10n.servicesOnDate(
                    DateFormat('dd.MM.yyyy').format(selectedDay!),
                  )
                : l10n.noServicesForDay,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
