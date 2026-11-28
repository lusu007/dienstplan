import 'package:dienstplan/data/releases/app_release_notes.dart';
import 'package:dienstplan/domain/models/release_notes.dart';
import 'package:dienstplan/domain/models/release_history_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('entire documented 0.4 series is one concise range retaining distinct changes', () {
    final history = groupReleaseHistory(
      current: '0.20.0',
      releases: appReleaseNotes,
    );
    final old = history
        .where((g) => g.latestVersion.startsWith('0.4.'))
        .toList();
    expect(old, hasLength(1));
    expect(old.single.oldestVersion, '0.4.0');
    expect(old.single.latestVersion, '0.4.41');
    expect(old.single.changes.map((c) => c.id), ['maintenance', 'ios']);
  });
  test('other adjacent maintenance patches group but features and important fixes remain separate', () {
    final history = groupReleaseHistory(
      current: '0.20.0',
      releases: appReleaseNotes,
    );
    final tooling = history.singleWhere((g) => g.latestVersion == '0.10.5');
    expect(tooling.oldestVersion, '0.10.1');
    final release = history.singleWhere((g) => g.latestVersion == '0.17.3');
    expect(release.oldestVersion, '0.17.2');
    expect(
      history.singleWhere((g) => g.latestVersion == '0.19.2').oldestVersion,
      '0.19.2',
    );
    expect(
      history.singleWhere((g) => g.latestVersion == '0.19.0').oldestVersion,
      '0.19.0',
    );
  });
  test('range excludes not-installed future patches and preserves distinct descriptions sharing an ID', () {
    final history = groupReleaseHistory(
      current: '0.4.2+17',
      releases: const [
        AppReleaseNotes(
          version: '0.4.3',
          changes: [
            ReleaseChange(
              id: 'future',
              title: 'Future',
              description: '',
              importance: ReleaseImportance.maintenance,
            ),
          ],
        ),
        AppReleaseNotes(
          version: '0.4.2',
          changes: [
            ReleaseChange(
              id: 'build',
              title: 'Build',
              description: 'Android',
              importance: ReleaseImportance.maintenance,
            ),
          ],
        ),
        AppReleaseNotes(
          version: '0.4.1',
          changes: [
            ReleaseChange(
              id: 'build',
              title: 'Build',
              description: 'iOS',
              importance: ReleaseImportance.maintenance,
            ),
          ],
        ),
        AppReleaseNotes(
          version: '0.4.0',
          changes: [
            ReleaseChange(
              id: 'build',
              title: 'Build',
              description: 'iOS',
              importance: ReleaseImportance.maintenance,
            ),
          ],
        ),
      ],
    );
    expect(history, hasLength(1));
    expect(history.single.latestVersion, '0.4.2');
    expect(history.single.oldestVersion, '0.4.0');
    expect(history.single.changes.map((c) => c.description), [
      'Android',
      'iOS',
    ]);
  });
  test('does not invent a contiguous range over missing patches or a minor boundary', () {
    final history = groupReleaseHistory(
      current: '0.5.0',
      releases: const [
        AppReleaseNotes(
          version: '0.5.0',
          changes: [
            ReleaseChange(
              id: 'a',
              title: '',
              description: '',
              importance: ReleaseImportance.maintenance,
            ),
          ],
        ),
        AppReleaseNotes(
          version: '0.4.2',
          changes: [
            ReleaseChange(
              id: 'a',
              title: '',
              description: '',
              importance: ReleaseImportance.maintenance,
            ),
          ],
        ),
        AppReleaseNotes(
          version: '0.4.0',
          changes: [
            ReleaseChange(
              id: 'a',
              title: '',
              description: '',
              importance: ReleaseImportance.maintenance,
            ),
          ],
        ),
      ],
    );
    expect(history.map((g) => g.latestVersion), ['0.5.0', '0.4.2', '0.4.0']);
  });
}
