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
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final responsivePadding = isLandscape ? 12.0 : 16.0;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: responsivePadding, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.services,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: isLandscape ? 18.0 : null,
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
                  fontSize: isLandscape ? 14.0 : null,
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }
}
