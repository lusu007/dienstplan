import 'package:dienstplan/domain/models/release_notes.dart';

/// A display-only range; individual release versions remain the read-state unit.
class ReleaseHistoryGroup {
  const ReleaseHistoryGroup(this.releases);

  final List<AppReleaseNotes> releases;

  String get latestVersion => releases.first.version;
  String get oldestVersion => releases.last.version;
  bool get isRange => releases.length > 1;

  List<ReleaseChange> get changes {
    final seen = <(String, String, String, ReleaseImportance)>{};
    return releases
        .expand((release) => release.changes)
        .where(
          (change) => seen.add((
            change.id,
            change.title,
            change.description,
            change.importance,
          )),
        )
        .toList();
  }
}

/// Collapse adjacent maintenance patches without swallowing features, fixes,
/// version gaps, minor boundaries, or releases newer than the installed app.
List<ReleaseHistoryGroup> groupReleaseHistory({
  required String current,
  required Iterable<AppReleaseNotes> releases,
}) {
  final groups = <ReleaseHistoryGroup>[];
  var pending = <AppReleaseNotes>[];
  bool maintenance(AppReleaseNotes release) =>
      release.changes.isNotEmpty &&
      release.changes.every(
        (change) => change.importance == ReleaseImportance.maintenance,
      );
  for (final release in releaseHistory(current: current, releases: releases)) {
    var joins = false;
    if (pending.isNotEmpty &&
        maintenance(pending.last) &&
        maintenance(release)) {
      final newer = parseReleaseVersion(pending.last.version)!;
      final older = parseReleaseVersion(release.version)!;
      joins =
          newer.major == older.major &&
          newer.minor == older.minor &&
          newer.patch == older.patch + 1 &&
          newer.preRelease.isEmpty &&
          older.preRelease.isEmpty;
    }
    if (!joins && pending.isNotEmpty) {
      groups.add(ReleaseHistoryGroup(List.unmodifiable(pending)));
      pending = [];
    }
    pending.add(release);
  }
  if (pending.isNotEmpty) {
    groups.add(ReleaseHistoryGroup(List.unmodifiable(pending)));
  }
  return groups;
}
