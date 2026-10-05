import 'package:dienstplan/presentation/widgets/screens/settings/components/dialogs/app_dialog.dart';
import 'package:dienstplan/presentation/state/partner/partner_notifier.dart';
import 'package:dienstplan/presentation/state/partner/partner_ui_state.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/color_selection_bottomsheet.dart';
import 'package:dienstplan/core/constants/accent_color_palette.dart';
import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/domain/entities/duty_schedule_config.dart';
import 'package:dienstplan/domain/entities/meta.dart';
import 'package:dienstplan/domain/entities/school_holiday.dart';
import 'package:dienstplan/presentation/widgets/common/cards/selection_card.dart';
import 'package:dienstplan/presentation/widgets/common/glass_bottom_sheet.dart';
import 'package:dienstplan/presentation/widgets/common/glass_screen_scaffold.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/vacation_day_item.dart';
import 'package:dienstplan/presentation/widgets/screens/calendar/duty_list/duty_schedule_list.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/config_selection_bottomsheet.dart';
import 'package:dienstplan/presentation/widgets/screens/settings/components/bottomsheets/duty_group_selection_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, Brightness brightness, {double scale = 1}) =>
    ProviderScope(
      overrides: [partnerProvider.overrideWith(_Partner.new)],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: child,
      ),
    );

class _Partner extends PartnerNotifier {
  @override
  Future<PartnerUiState> build() async => PartnerUiState.initial();
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'dialog actions use the shared action typography in $brightness',
      (tester) async {
        await tester.pumpWidget(
          app(
            Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => AppDialog.show(
                    context: context,
                    title: 'Hinweis',
                    content: const Text('Text'),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
            brightness,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final text = tester
            .renderObject<RenderParagraph>(find.text('Schließen'))
            .text
            .style!;
        expect(text.fontSize, 16);
        expect(text.fontWeight, FontWeight.w700);
      },
    );
    testWidgets(
      'compound selection title has primary hierarchy in $brightness',
      (tester) async {
        await tester.pumpWidget(
          app(
            Scaffold(
              body: SelectionCard(
                title: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Behörde', style: TextStyle(fontSize: 11)),
                    Text('Dienstplan'),
                  ],
                ),
                subtitle: 'Beschreibung',
                isSelected: false,
                onTap: () {},
                useDialogStyle: true,
              ),
            ),
            brightness,
          ),
        );
        final text = tester
            .renderObject<RenderParagraph>(find.text('Dienstplan'))
            .text
            .style!;
        expect(text.fontSize, 17);
        expect(text.fontWeight, FontWeight.w700);
        expect(
          tester
              .renderObject<RenderParagraph>(find.text('Behörde'))
              .text
              .style!
              .fontSize,
          11,
        );
      },
    );
    testWidgets('long page title wraps at large font scale in $brightness', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        app(
          const GlassScreenScaffold(
            title: 'Datenschutzerklärung',
            child: SizedBox(),
          ),
          brightness,
          scale: 1.5,
        ),
      );
      final title = tester.widget<Text>(find.text('Datenschutzerklärung'));
      expect(title.overflow, isNot(TextOverflow.ellipsis));
      expect(tester.takeException(), isNull);
    });
    testWidgets('holiday text grows without overflow in $brightness', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        app(
          Scaffold(
            body: VacationDayItem(
              holiday: SchoolHoliday(
                id: 'test',
                name: 'Herbstferien',
                description: 'Schulfrei im Bundesland',
                startDate: DateTime(2026, 10, 1),
                endDate: DateTime(2026, 10, 15),
                stateCode: 'HB',
                stateName: 'Bremen',
                type: HolidayType.movableHoliday,
              ),
              visualStyle: DutyListVisualStyle.glassCompact,
            ),
          ),
          brightness,
          scale: 1.5,
        ),
      );
      expect(
        tester.widget<Text>(find.text('Herbstferien')).style!.fontSize,
        15,
      );
      expect(tester.takeException(), isNull);
    });
  }
  for (final brightness in Brightness.values) {
    testWidgets(
      'short group and color sheets fit at large text in $brightness',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          app(
            const Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: DutyGroupSelectionBottomsheet(
                  title: 'Dienstgruppen',
                  dutyGroups: ['Gruppe 1'],
                  selectedDutyGroup: 'Gruppe 1',
                  heightPercentage: .5,
                  onDutyGroupSelected: _ignoreGroup,
                ),
              ),
            ),
            brightness,
            scale: 1.5,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (brightness == Brightness.light) {
          expect(
            tester.getSize(find.byType(GlassBottomSheet)).height,
            lessThan(350),
          );
        } else {
          expect(tester.getSize(find.byType(GlassBottomSheet)).height, 308);
        }
        await tester.pumpWidget(
          app(
            Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: ColorSelectionBottomsheet(
                  title: 'Akzentfarbe',
                  colors: AccentColor.values,
                  selectedColorValue: AccentColorDefaults.myAccentColorValue,
                  heightPercentage: .6,
                  onColorSelected: (_) {},
                ),
              ),
            ),
            brightness,
            scale: 1.5,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Blau'), findsOneWidget);
      },
    );
  }
  testWidgets('selected group is retained when tapped again', (tester) async {
    String? result = 'Gruppe 1';
    var changes = 0;
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              child: const Text('Open'),
              onPressed: () => DutyGroupSelectionBottomsheet.show(
                context: context,
                title: 'Gruppen',
                dutyGroups: ['Gruppe 1'],
                selectedDutyGroup: 'Gruppe 1',
                onDutyGroupSelected: (group) {
                  changes++;
                  result = group;
                },
              ),
            ),
          ),
        ),
        Brightness.light,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gruppe 1'));
    await tester.pumpAndSettle();
    expect(result, 'Gruppe 1');
    expect(
      changes,
      0,
      reason: 'Confirming the selected radio row must not persist or reload',
    );
  });
  testWidgets(
    'selected plan toggles off and can be selected again without a clear row',
    (tester) async {
      final plan = DutyScheduleConfig(
        version: '1',
        meta: Meta(
          name: 'Plan',
          description: '',
          startDate: DateTime(2026),
          startWeekDay: 'Mo',
          days: [],
        ),
        dutyTypes: {},
        dutyTypeOrder: [],
        rhythms: {},
        dutyGroups: [],
      );
      DutyScheduleConfig? result = plan;
      var changes = 0;
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                child: const Text('Open'),
                onPressed: () => ConfigSelectionBottomsheet.show(
                  context: context,
                  title: 'Pläne',
                  configs: [plan],
                  selectedConfigName: result?.name,
                  onConfigSelected: (config) async {
                    changes++;
                    result = config;
                  },
                ),
              ),
            ),
          ),
          Brightness.light,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plan'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(changes, 1);
      expect(find.text('Pläne'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Kein Dienstplan ausgewählt'), findsNothing);
      await tester.tap(find.text('Plan'));
      await tester.pumpAndSettle();
      expect(result, plan);
      expect(changes, 2);
    },
  );
  testWidgets('Light sheet handle is visible and shell respects bottom inset', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const Scaffold(
          body: MediaQuery(
            data: MediaQueryData(
              size: Size(800, 600),
              padding: EdgeInsets.only(bottom: 24),
            ),
            child: GlassBottomSheet(
              title: 'Sheet',
              shrinkToContent: true,
              children: [Text('Option')],
            ),
          ),
        ),
        Brightness.light,
      ),
    );
    final handle = tester.widget<Container>(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxWidth == 44 &&
            w.constraints?.maxHeight == 4,
      ),
    );
    expect(
      (handle.decoration! as BoxDecoration).color!.computeLuminance(),
      lessThan(.5),
    );
    final sheetPadding = tester.widget<Padding>(
      find
          .descendant(
            of: find.byType(GlassBottomSheet),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect((sheetPadding.padding as EdgeInsets).bottom, 32);
  });
}

void _ignoreGroup(String? _) {}
