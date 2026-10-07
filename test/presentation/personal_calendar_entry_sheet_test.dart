import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/components/personal_calendar_entry_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets(
    'overnight wheel selection proposes next day and manual date stays',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await initializeDateFormatting('de');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('de'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: PersonalCalendarEntrySheet(
                day: DateTime(2026, 12, 31),
                existingSchedule: null,
                dutyGroupNameForNew: 'Privat',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('16:00 - 17:00'));
      await tester.pumpAndSettle();
      tester
          .widget<ListWheelScrollView>(find.byType(ListWheelScrollView).first)
          .onSelectedItemChanged!(22);
      await tester.pumpAndSettle();
      expect(find.textContaining('Folgetag'), findsOneWidget);
      await tester.tap(find.textContaining('Folgetag'));
      await tester.pumpAndSettle();
      tester
          .widget<CalendarDatePicker>(find.byType(CalendarDatePicker))
          .onDateChanged(DateTime(2027, 1, 3));
      await tester.pumpAndSettle();
      expect(find.text('3. Jan. 2027'), findsOneWidget);
      await tester.tap(find.text('22:00 - 17:00'));
      await tester.pumpAndSettle();
      tester
          .widget<ListWheelScrollView>(find.byType(ListWheelScrollView).first)
          .onSelectedItemChanged!(8);
      await tester.pumpAndSettle();
      expect(find.text('3. Jan. 2027'), findsOneWidget);
      expect(find.text('Endtag automatisch bestimmen'), findsOneWidget);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'all-day entry display in $brightness preserves time toggle behavior',
      (tester) async {
        tester.view.physicalSize = const Size(600, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        // Isolate the time-toggle behavior from the test-only Ahem font's
        // unusually wide glyphs. Phone-width layout is checked on the device.
        await initializeDateFormatting('de');
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(brightness: brightness),
              locale: const Locale('de'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: PersonalCalendarEntrySheet(
                  day: DateTime(2026, 10, 2),
                  existingSchedule: null,
                  dutyGroupNameForNew: 'Privat',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (brightness == Brightness.light) {
          // A pale field must remain identifiable before it receives focus.
          final decoration = tester
              .widget<TextField>(find.byType(TextField).first)
              .decoration!;
          final scheme = ThemeData(brightness: brightness).colorScheme;
          final fill = Color.alphaBlend(decoration.fillColor!, scheme.surface);
          final outline = decoration.enabledBorder!.borderSide.color;
          final visibleOutline = Color.alphaBlend(outline, fill);
          final a = visibleOutline.computeLuminance(),
              b = fill.computeLuminance();
          expect(
            ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05),
            greaterThanOrEqualTo(3),
          );
        }
        expect(
          find.text('16:00 - 17:00'),
          brightness == Brightness.light ? findsNothing : findsOneWidget,
        );
        await tester.ensureVisible(find.byType(Switch));
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(find.text('16:00 - 17:00'), findsOneWidget);
        expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(
          find.text('16:00 - 17:00'),
          brightness == Brightness.light ? findsNothing : findsOneWidget,
        );
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(find.text('16:00 - 17:00'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
