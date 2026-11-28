import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Design-system delegates for German widgets, alongside the app's own strings.
/// gen-l10n still emits delegates for the deprecated SDK design libraries.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
