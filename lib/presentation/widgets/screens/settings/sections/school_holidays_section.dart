import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/domain/entities/german_state.dart';
import 'package:dienstplan/presentation/state/school_holidays/school_holidays_notifier.dart';
import 'package:dienstplan/presentation/state/settings/settings_notifier.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/settings_section.dart';
import 'package:dienstplan/presentation/widgets/common/cards/navigation_card.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/school_holidays/german_state_dialog.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/dialogs/school_holidays/holiday_color_dialog.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/presentation/extensions/accent_color_extensions.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';

class SchoolHolidaysSection extends ConsumerWidget {
  const SchoolHolidaysSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holidaysState = ref.watch(schoolHolidaysProvider);
    final settingsState = ref.watch(settingsProvider).value;
    final l10n = AppLocalizations.of(context);

    return holidaysState.when(
      loading: () => const SettingsSection(
        title: 'Schulferien',
        cards: [
          NavigationCard(
            icon: Icons.school_outlined,
            title: 'Schulferien anzeigen',
            subtitle: 'Lädt...',
            trailing: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            onTap: null,
          ),
        ],
      ),
      error: (error, stack) => const SettingsSection(
        title: 'Schulferien',
        cards: [
          NavigationCard(
            icon: Icons.school_outlined,
            title: 'Schulferien anzeigen',
            subtitle: 'Fehler beim Laden',
            trailing: Switch(value: false, onChanged: null),
            onTap: null,
          ),
        ],
      ),
      data: (state) {
        final isEnabled = state.isEnabled;
        final selectedState = state.selectedStateCode != null
            ? GermanState.findByCode(state.selectedStateCode!)
            : null;

        return SettingsSection(
          title: 'Schulferien',
          cards: [
            NavigationCard(
              icon: Icons.school_outlined,
              title: 'Schulferien anzeigen',
              subtitle: isEnabled ? 'Aktiviert' : 'Deaktiviert',
              trailing: Switch(
                value: isEnabled,
                onChanged: (value) {
                  ref
                      .read(schoolHolidaysProvider.notifier)
                      .toggleEnabled(value);
                },
              ),
              onTap: null,
            ),
            if (isEnabled) ...[
              NavigationCard(
                icon: Icons.location_on_outlined,
                title: 'Bundesland',
                subtitle: selectedState?.name ?? 'Kein Bundesland ausgewählt',
                onTap: () async {
                  final selected = await showDialog<String>(
                    context: context,
                    builder: (context) => GermanStateDialog(
                      selectedStateCode: state.selectedStateCode,
                    ),
                  );

                  if (selected != null) {
                    await ref
                        .read(schoolHolidaysProvider.notifier)
                        .setSelectedState(selected);
                  }
                },
              ),
              if (state.selectedStateCode != null) ...[
                NavigationCard(
                  icon: Icons.refresh_outlined,
                  title: 'Feriendaten aktualisieren',
                  subtitle: state.lastRefreshTime != null
                      ? 'Zuletzt aktualisiert: ${_formatLastUpdate(state.lastRefreshTime!)}'
                      : 'Noch nicht aktualisiert',
                  onTap: state.isRefreshing
                      ? null
                      : () {
                          ref
                              .read(schoolHolidaysProvider.notifier)
                              .refreshHolidays();
                        },
                  trailing: state.isRefreshing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                NavigationCard(
                  icon: Icons.color_lens_outlined,
                  title: l10n.holidayAccentColor,
                  subtitle: _getHolidayAccentColorName(settingsState, l10n),
                  trailing: _buildHolidayAccentColorChip(
                    context,
                    settingsState?.holidayAccentColorValue,
                  ),
                  onTap: () => HolidayColorDialog.show(context),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  String _getHolidayAccentColorName(
    dynamic settingsState,
    AppLocalizations l10n,
  ) {
    final int value =
        settingsState?.holidayAccentColorValue ??
        AccentColorDefaults.holidayAccentColorValue;
    final AccentColor? match = AccentColor.fromValue(value);
    if (match != null) return match.toLabel(l10n);
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  Widget _buildHolidayAccentColorChip(BuildContext context, int? colorValue) {
    final int value = colorValue ?? AccentColorDefaults.holidayAccentColorValue;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Color(value),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
    );
  }

  String _formatLastUpdate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Gerade eben';
    } else if (difference.inMinutes < 60) {
      return 'Vor ${difference.inMinutes} Minuten';
    } else if (difference.inHours < 24) {
      return 'Vor ${difference.inHours} Stunden';
    } else {
      return 'Vor ${difference.inDays} Tagen';
    }
  }
}
