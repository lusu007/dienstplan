import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dienstplan/core/constants/glass_tokens.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/common/glass_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';

class AppLicensePage extends StatefulWidget {
  final String appName;
  final String? appVersion;
  final String? appIconPath;
  final String? appLegalese;

  const AppLicensePage({
    super.key,
    required this.appName,
    this.appVersion,
    this.appIconPath,
    this.appLegalese,
  });

  static void show({
    required BuildContext context,
    required String appName,
    String? appVersion,
    String? appIconPath,
    String? appLegalese,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext pageContext) {
          return AppLicensePage(
            appName: appName,
            appVersion: appVersion,
            appIconPath: appIconPath,
            appLegalese: appLegalese,
          );
        },
      ),
    );
  }

  @override
  State<AppLicensePage> createState() => _AppLicensePageState();
}

class _AppLicensePageState extends State<AppLicensePage> {
  late final Future<Map<String, List<String>>> _licensesFuture =
      _loadLicensesByPackage();

  Future<Map<String, List<String>>> _loadLicensesByPackage() async {
    final Map<String, List<String>> groupedLicenses = <String, List<String>>{};
    await for (final LicenseEntry entry in LicenseRegistry.licenses) {
      final String licenseText = entry.paragraphs
          .map((LicenseParagraph paragraph) => paragraph.text.trim())
          .where((String text) => text.isNotEmpty)
          .join('\n\n');
      if (licenseText.isEmpty) {
        continue;
      }
      for (final String packageName in entry.packages) {
        groupedLicenses.putIfAbsent(packageName, () => <String>[]);
        groupedLicenses[packageName]!.add(licenseText);
      }
    }
    final List<String> sortedKeys = groupedLicenses.keys.toList()..sort();
    final Map<String, List<String>> sortedGroupedLicenses =
        <String, List<String>>{};
    for (final String key in sortedKeys) {
      sortedGroupedLicenses[key] = groupedLicenses[key]!;
    }
    return sortedGroupedLicenses;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GlassScreenScaffold(
      title: l10n.licenses,
      child: FutureBuilder<Map<String, List<String>>>(
        future: _licensesFuture,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<Map<String, List<String>>> snapshot,
            ) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                final Object error = snapshot.error!;
                final StackTrace? stackTrace = snapshot.stackTrace;
                debugPrint(
                  'Failed to load app licenses '
                  '(screen=app_license_page, errorType=${error.runtimeType}, reason=$error)',
                );
                if (stackTrace != null) {
                  debugPrint(
                    'Failed to load app licenses stackTrace: $stackTrace',
                  );
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(glassSpacingXl - 4),
                    child: Text(
                      l10n.licensesLoadError,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              final Map<String, List<String>> licensesByPackage =
                  snapshot.data ?? <String, List<String>>{};
              final List<MapEntry<String, List<String>>> licenseEntries =
                  licensesByPackage.entries.toList(growable: false);
              if (licensesByPackage.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(glassSpacingXl - 4),
                    child: Text(
                      l10n.licensesEmptyState,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  glassSpacingXl - 4,
                  glassSpacingXl - 4,
                  glassSpacingXl - 4,
                  glassSpacingXxl,
                ),
                itemCount: licenseEntries.length + 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return _LicenseAppHeader(
                      appName: widget.appName,
                      appVersion: widget.appVersion,
                      appIconPath: widget.appIconPath,
                      appLegalese: widget.appLegalese,
                    );
                  }
                  if (index == 1) {
                    return const SizedBox(height: glassSpacingLg);
                  }
                  final MapEntry<String, List<String>> entry =
                      licenseEntries[index - 2];
                  return GlassCard(
                    margin: const EdgeInsets.only(bottom: glassSpacingMd - 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(glassSurfaceRadiusMd),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          title: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          children: entry.value
                              .map((String text) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    glassSpacingLg,
                                    0,
                                    glassSpacingLg,
                                    glassSpacingLg,
                                  ),
                                  child: SelectableText(
                                    text,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
      ),
    );
  }
}

class _LicenseAppHeader extends StatelessWidget {
  final String appName;
  final String? appVersion;
  final String? appIconPath;
  final String? appLegalese;

  const _LicenseAppHeader({
    required this.appName,
    this.appVersion,
    this.appIconPath,
    this.appLegalese,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(glassSpacingLg),
      child: Row(
        children: <Widget>[
          if (appIconPath != null)
            Padding(
              padding: const EdgeInsets.only(right: glassSpacingMd),
              child: Image.asset(appIconPath!, width: 44, height: 44),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (appVersion != null && appVersion!.isNotEmpty)
                  Text(
                    appVersion!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (appLegalese != null && appLegalese!.isNotEmpty)
                  Text(
                    appLegalese!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
