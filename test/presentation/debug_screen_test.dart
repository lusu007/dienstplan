import '../support/app_test_builder.dart';

import 'package:dienstplan/core/l10n/app_localizations_delegates.dart';

import 'dart:io';

import 'package:dienstplan/core/l10n/app_localizations.dart';
import 'package:dienstplan/presentation/screens/debug_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  testWidgets('debug screen sends sentry test event', (tester) async {
    bool sent = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          builder: appTestBuilder(),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DebugScreen(
            loadPackageInfo: () async => PackageInfo(
              appName: 'Dienstplan',
              packageName: 'io.scelus.dienstplan.dev',
              version: '1.2.3',
              buildNumber: '45',
            ),
            loadScheduleFiles: () async => <File>[],
            sendTestSentry: () async {
              sent = true;
              return SentryId.fromId('00000000000000000000000000000001');
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('debug_send_sentry_test')),
    );
    await tester.tap(find.byKey(const ValueKey('debug_send_sentry_test')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(sent, isTrue);
    expect(find.textContaining('Sentry test event sent'), findsOneWidget);
  });
}
