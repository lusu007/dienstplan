import 'package:pub_semver/pub_semver.dart';

enum ReleaseImportance { maintenance, fix, feature }

class ReleaseChange {
  const ReleaseChange({
    required this.id,
    required this.title,
    required this.description,
    required this.importance,
  });
  final String id;
  final String title;
  final String description;
  final ReleaseImportance importance;
}

class AppReleaseNotes {
  const AppReleaseNotes({required this.version, required this.changes});
  final String version;
  final List<ReleaseChange> changes;
}

/// Old preferences include build metadata. A rebuilt release has no new notes.
Version? parseReleaseVersion(String? value) {
  if (value == null) return null;
  try {
    final parsed = Version.parse(value.trim());
    return Version(
      parsed.major,
      parsed.minor,
      parsed.patch,
      pre: parsed.preRelease.isEmpty ? null : parsed.preRelease.join('.'),
    );
  } on FormatException {
    return null;
  }
}

List<AppReleaseNotes> releaseHistory({
  required String current,
  required Iterable<AppReleaseNotes> releases,
}) {
  final installed = parseReleaseVersion(current);
  if (installed == null) return const [];
  final history = releases.where((r) {
    final version = parseReleaseVersion(r.version);
    return version != null && version.compareTo(installed) <= 0;
  }).toList();
  history.sort(
    (a, b) =>
        parseReleaseVersion(b.version)!
            .compareTo(parseReleaseVersion(a.version)!),
  );
  return history;
}

List<AppReleaseNotes> unseenReleaseNotes({
  required String? acknowledged,
  required String current,
  required Iterable<AppReleaseNotes> releases,
}) {
  final previous = parseReleaseVersion(acknowledged);
  if (previous == null) return const [];
  return releaseHistory(current: current, releases: releases)
      .where((r) => parseReleaseVersion(r.version)!.compareTo(previous) > 0)
      .toList();
}

/// Keep features from older skipped releases ahead of newer small fixes.
List<ReleaseChange> releaseHighlights(Iterable<AppReleaseNotes> releases) {
  final ordered = releases.toList()
    ..sort(
      (a, b) =>
          parseReleaseVersion(b.version)!
              .compareTo(parseReleaseVersion(a.version)!),
    );
  final seen = <String>{};
  final changes = ordered
      .expand((r) => r.changes)
      .where(
        (c) => c.importance != ReleaseImportance.maintenance && seen.add(c.id),
      )
      .indexed
      .toList();
  changes.sort((a, b) {
    final priority = b.$2.importance.index.compareTo(a.$2.importance.index);
    return priority == 0 ? a.$1.compareTo(b.$1) : priority;
  });
  return changes.take(5).map((c) => c.$2).toList();
}
