import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dienstplan/core/constants/prefs_keys.dart';

/// `version+buildNumber` as used for upgrade detection.
String packageFullVersion(PackageInfo packageInfo) {
  return '${packageInfo.version}+${packageInfo.buildNumber}';
}

/// Whether the what's-new dialog should open. [acknowledged] is null on first
/// install (caller must persist baseline without showing UI).
bool shouldShowWhatsNew({
  required String? acknowledged,
  required String current,
}) {
  if (acknowledged == null) {
    return false;
  }
  return acknowledged != current;
}

class WhatsNewService {
  WhatsNewService(this._prefs);

  final SharedPreferences _prefs;

  Future<String?> readAcknowledgedVersion() {
    return Future.value(_prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion));
  }

  Future<void> writeAcknowledgedVersion(String fullVersion) async {
    await _prefs.setString(kPrefsKeyWhatsNewAcknowledgedVersion, fullVersion);
  }
}
