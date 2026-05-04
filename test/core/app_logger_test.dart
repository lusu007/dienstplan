import 'dart:async';

import 'package:dienstplan/core/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLogger', () {
    test(
      'diagnostic logs do not initialize local log storage by default',
      () async {
        final List<String> printed = <String>[];

        await runZoned(
          () async {
            await AppLogger.d('Diagnostic cache hit (configName=test)');
            await AppLogger.i('Diagnostic cache warmed (configName=test)');
          },
          zoneSpecification: ZoneSpecification(
            print: (_, _, _, String line) {
              printed.add(line);
            },
          ),
        );

        expect(
          printed,
          isNot(contains(contains('Failed to initialize logger'))),
        );
      },
    );
  });
}
