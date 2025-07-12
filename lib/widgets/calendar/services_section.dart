import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dienstplan/l10n/app_localizations.dart';

class ServicesSection extends StatelessWidget {
  final DateTime? selectedDay;

  const ServicesSection({
    super.key,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                    DateFormat('dd.MM.yyyy').format(selectedDay!))
                : l10n.noServicesForDay,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha((0.9 * 255).toInt()),
                ),
          ),
        ],
      ),
    );
  }
}
