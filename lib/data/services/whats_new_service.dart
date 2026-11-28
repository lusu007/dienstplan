import 'package:dienstplan/data/releases/app_release_notes.dart';
import 'package:dienstplan/domain/models/release_notes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dienstplan/core/constants/prefs_keys.dart';

/// `version+buildNumber` as used for upgrade detection.
String packageFullVersion(PackageInfo packageInfo) {
  return '${packageInfo.version}+${packageInfo.buildNumber}';
}

/// Show meaningful changes across every missed release, excluding build updates.
/// A first install or malformed baseline is recorded without showing UI.
bool shouldShowWhatsNew({
  required String? acknowledged,
  required String current,
}) {
  if (acknowledged == null) {
    return false;
  }
  return releaseHighlights(
    unseenReleaseNotes(
      acknowledged: acknowledged,
      current: current,
      releases: appReleaseNotes,
    ),
  ).isNotEmpty;
}

class WhatsNewService {
  WhatsNewService(this._prefs);

  final SharedPreferences _prefs;

  Future<String?> readAcknowledgedVersion() {
    return Future.value(_prefs.getString(kPrefsKeyWhatsNewAcknowledgedVersion));
  }

  Future<void> writeAcknowledgedVersion(String fullVersion) async {
    final next = parseReleaseVersion(fullVersion);
    if (next == null) return;
    final previous = parseReleaseVersion(await readAcknowledgedVersion());
    if (previous != null && previous.compareTo(next) >= 0) return;
    await _prefs.setString(kPrefsKeyWhatsNewAcknowledgedVersion, fullVersion);
  }
}
