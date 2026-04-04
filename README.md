# Dienstplan — police duty schedule app

[![Flutter](https://img.shields.io/badge/Flutter-stable-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-AGPL--3.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-orange.svg)](https://github.com/lusu007/dienstplan)

![Vorstellungsgrafik](static/Vorstellungsgrafik.png)

Cross-platform Flutter app for police officers to view and manage duty schedules. Offline-first, clean architecture (domain / data / presentation), Riverpod for state and DI.

## Features

- Calendar with month navigation, duty groups, and multiple schedule configs (e.g. Bereitschaftspolizei, ESD)
- Generated rotations from JSON configs in `assets/schedules/`
- Partner schedule, custom accent colors, school/public holidays (state selection; holiday data via [Mehr-Schulferien.de](https://www.mehr-schulferien.de/))
- German and English; data stays on device; optional Sentry (can be disabled)

## Run from source

```bash
git clone https://github.com/lusu007/dienstplan.git
cd dienstplan
flutter pub get
flutter run
```

Release APK example: `flutter build apk --release`. Prebuilt APKs: [GitHub Releases](https://github.com/lusu007/dienstplan/releases).

## Development

- **SDK:** Dart `>=3.10.0 <4.0.0` (see [pubspec.yaml](pubspec.yaml)); Flutter stable recommended.
- **Codegen:** `dart run build_runner build --delete-conflicting-outputs` after changing Freezed / Riverpod / routes.
- **Structure:** `lib/core` (DI, init, cache), `lib/domain`, `lib/data`, `lib/presentation`. Providers live in `lib/core/di/riverpod_providers.dart` (generated `.g.dart` alongside).
- **Details:** workflow, standards, and deeper architecture notes are in [CONTRIBUTING.md](CONTRIBUTING.md).

## Contributing

Fork, branch, test (`flutter test`), open a PR. See [CONTRIBUTING.md](CONTRIBUTING.md). Questions: [GitHub Discussions](https://github.com/lusu007/dienstplan/discussions).

## License

[AGPL-3.0](LICENSE). Using or distributing modified versions requires complying with AGPL terms (including source availability where applicable).

## Acknowledgments

School/public holiday data via [Mehr-Schulferien.de](https://www.mehr-schulferien.de/) ([GitHub](https://github.com/mehr-schulferien-de/www.mehr-schulferien.de)). Third-party licenses are listed in the in-app About screen.

## Support

[Bugs and features](https://github.com/lusu007/dienstplan/issues)
