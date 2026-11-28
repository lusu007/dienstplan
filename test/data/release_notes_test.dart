import 'package:dienstplan/domain/models/release_notes.dart';
import 'package:flutter_test/flutter_test.dart';

const changes = [
  AppReleaseNotes(
    version: '0.18.0',
    changes: [
      ReleaseChange(
        id: 'own',
        title: 'Eigene Dienste',
        description: 'Über Mitternacht',
        importance: ReleaseImportance.feature,
      ),
    ],
  ),
  AppReleaseNotes(
    version: '0.19.0',
    changes: [
      ReleaseChange(
        id: 'paging',
        title: 'Tageswechsel',
        description: 'Wischen',
        importance: ReleaseImportance.feature,
      ),
    ],
  ),
  AppReleaseNotes(
    version: '0.19.1',
    changes: [
      ReleaseChange(
        id: 'deps',
        title: 'Wartung',
        description: 'Bibliotheken',
        importance: ReleaseImportance.maintenance,
      ),
    ],
  ),
  AppReleaseNotes(
    version: '0.19.2',
    changes: [
      ReleaseChange(
        id: 'fix',
        title: 'Fehler behoben',
        description: 'Kalender',
        importance: ReleaseImportance.fix,
      ),
    ],
  ),
  AppReleaseNotes(
    version: '0.20.0',
    changes: [
      ReleaseChange(
        id: 'future',
        title: 'Zukunft',
        description: 'Noch nicht installiert',
        importance: ReleaseImportance.feature,
      ),
    ],
  ),
];

void main() {
  test('skipped releases include earlier features and maintenance in newest-first history', () {
    final unseen = unseenReleaseNotes(
      acknowledged: '0.17.0+15',
      current: '0.19.2+16',
      releases: changes,
    );
    expect(unseen.map((r) => r.version), [
      '0.19.2',
      '0.19.1',
      '0.19.0',
      '0.18.0',
    ]);
    expect(releaseHighlights(unseen).map((c) => c.id), [
      'paging',
      'own',
      'fix',
    ]);
  });
  test('maintenance alone has no highlights but remains in history', () {
    final unseen = unseenReleaseNotes(
      acknowledged: '0.19.0',
      current: '0.19.1',
      releases: changes,
    );
    expect(unseen.map((r) => r.version), ['0.19.1']);
    expect(releaseHighlights(unseen), isEmpty);
  });
  test('future releases are excluded and versions compare numerically', () {
    final history = releaseHistory(
      current: '0.19.2',
      releases: [
        ...changes,
        const AppReleaseNotes(version: '0.9.0', changes: []),
        const AppReleaseNotes(version: '0.10.0', changes: []),
      ],
    );
    expect(history.map((r) => r.version), [
      '0.19.2',
      '0.19.1',
      '0.19.0',
      '0.18.0',
      '0.10.0',
      '0.9.0',
    ]);
  });
  test('first install malformed versions build changes and downgrade have no unseen changes', () {
    for (final pair in [
      (null, '0.19.2'),
      ('broken', '0.19.2'),
      ('0.18.0', 'broken'),
      ('0.18.0', '0.19.2+?'),
      ('0.19.2+1', '0.19.2+2'),
      ('0.20.0', '0.19.2'),
    ]) {
      expect(
        unseenReleaseNotes(
          acknowledged: pair.$1,
          current: pair.$2,
          releases: changes,
        ),
        isEmpty,
      );
    }
  });
  test('prerelease does not include stable future release', () {
    expect(
      releaseHistory(
        current: '0.20.0-beta.1+3',
        releases: changes,
      ).map((r) => r.version),
      ['0.19.2', '0.19.1', '0.19.0', '0.18.0'],
    );
  });
  test(
    'five distinct highlights prioritize features across all missed releases',
    () {
      final releases = [
        const AppReleaseNotes(
          version: '0.18.0',
          changes: [
            ReleaseChange(
              id: 'feature',
              title: 'Feature',
              description: '',
              importance: ReleaseImportance.feature,
            ),
            ReleaseChange(
              id: 'duplicate',
              title: 'Older',
              description: '',
              importance: ReleaseImportance.fix,
            ),
          ],
        ),
        AppReleaseNotes(
          version: '0.19.0',
          changes: [
            const ReleaseChange(
              id: 'duplicate',
              title: 'Newer',
              description: '',
              importance: ReleaseImportance.fix,
            ),
            for (var i = 1; i <= 6; i++)
              ReleaseChange(
                id: 'fix$i',
                title: 'Fix $i',
                description: '',
                importance: ReleaseImportance.fix,
              ),
          ],
        ),
      ];
      final highlights = releaseHighlights(releases);
      expect(highlights.map((c) => c.id), [
        'feature',
        'duplicate',
        'fix1',
        'fix2',
        'fix3',
      ]);
      expect(highlights[1].title, 'Newer');
    },
  );
}
