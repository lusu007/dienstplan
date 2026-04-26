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

  group('WhatsNewService', () {
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
