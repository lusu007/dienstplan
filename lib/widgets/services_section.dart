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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.services,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            selectedDay != null
                ? l10n.servicesOnDate(
                    DateFormat('dd.MM.yyyy').format(selectedDay!))
                : l10n.noServicesForDay,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
