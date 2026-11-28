import 'package:dienstplan/core/constants/prefs_keys.dart';
import 'package:dienstplan/data/services/whats_new_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('packageFullVersion', () {
    test('concatenates version and build number', () {
      final PackageInfo info = PackageInfo(
        appName: 't',
        packageName: 't',
        version: '0.15.2',
        buildNumber: '99',
      );
      expect(packageFullVersion(info), '0.15.2+99');
    });
  });

  group('shouldShowWhatsNew', () {
    test('returns false when acknowledged is null', () {
      expect(
        shouldShowWhatsNew(acknowledged: null, current: '0.15.2+1'),
        false,
      );
    });

    test('returns false when versions match', () {
      expect(
        shouldShowWhatsNew(acknowledged: '0.15.2+1', current: '0.15.2+1'),
        false,
      );
    });

    test('returns true when version changed', () {
      expect(
        shouldShowWhatsNew(acknowledged: '0.15.1+10', current: '0.15.2+1'),
        true,
      );
    });
  });

  group('upgrade boundaries', () {
    test('does not reopen for a build-only update', () {
      expect(
        shouldShowWhatsNew(acknowledged: '0.19.0+17', current: '0.19.0+18'),
        false,
      );
    });
    test('does not reopen after a downgrade', () {
      expect(
        shouldShowWhatsNew(acknowledged: '0.19.2+17', current: '0.18.0+18'),
        false,
      );
    });
    test('invalid legacy preference establishes a baseline', () {
      expect(
        shouldShowWhatsNew(acknowledged: 'broken', current: '0.19.2+18'),
        false,
      );
    });
  });

  group('WhatsNewService', () {
    test(
      'acknowledgement never moves backwards on downgrade or rebuild',
      () async {
        SharedPreferences.setMockInitialValues({
          kPrefsKeyWhatsNewAcknowledgedVersion: '0.19.2+10',
        });
        final prefs = await SharedPreferences.getInstance();
        final service = WhatsNewService(prefs);
        await service.writeAcknowledgedVersion('0.18.0+20');
        await service.writeAcknowledgedVersion('0.19.2+30');
        await service.writeAcknowledgedVersion('broken');
        expect(await service.readAcknowledgedVersion(), '0.19.2+10');
        await service.writeAcknowledgedVersion('0.20.0+40');
        expect(await service.readAcknowledgedVersion(), '0.20.0+40');
      },
    );
    test('corrupted old acknowledgement can be replaced safely', () async {
      SharedPreferences.setMockInitialValues({
        kPrefsKeyWhatsNewAcknowledgedVersion: 'broken',
      });
      final service = WhatsNewService(await SharedPreferences.getInstance());
      await service.writeAcknowledgedVersion('0.20.0+40');
      expect(await service.readAcknowledgedVersion(), '0.20.0+40');
    });
    test('read returns null then write persists', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final WhatsNewService service = WhatsNewService(prefs);
      expect(await service.readAcknowledgedVersion(), null);
      await service.writeAcknowledgedVersion('0.15.2+3');
      expect(prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion), '0.15.2+3');
      expect(await service.readAcknowledgedVersion(), '0.15.2+3');
    });
  });
}
