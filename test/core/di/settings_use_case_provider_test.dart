import 'dart:async';

import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/domain/entities/settings.dart';
import 'package:dienstplan/domain/failures/result.dart';
import 'package:dienstplan/domain/repositories/settings_repository.dart';
import 'package:dienstplan/domain/use_cases/save_settings_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SettingsRepository implements SettingsRepository {
  @override
  Future<Result<Settings?>> getSettings() async => Result.success(null);

  @override
  Future<Result<void>> saveSettings(Settings settings) async =>
      Result.success(null);

  @override
  Future<Result<void>> clearSettings() async => Result.success(null);
}

void main() {
  test(
    'save settings provider initializes after asynchronous storage loads',
    () async {
      final ready = Completer<SettingsRepository>();
      final container = ProviderContainer.test(
        overrides: [
          settingsRepositoryProvider.overrideWith((ref) => ready.future),
        ],
      );
      final loading = container.read(saveSettingsUseCaseProvider.future);
      await container.pump();
      ready.complete(_SettingsRepository());
      expect(await loading, isA<SaveSettingsUseCase>());
    },
  );
}
