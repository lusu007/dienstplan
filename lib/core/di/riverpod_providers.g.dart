// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riverpod_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(databaseService)
final databaseServiceProvider = DatabaseServiceProvider._();

final class DatabaseServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<DatabaseService>,
          DatabaseService,
          FutureOr<DatabaseService>
        >
    with $FutureModifier<DatabaseService>, $FutureProvider<DatabaseService> {
  DatabaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseServiceHash();

  @$internal
  @override
  $FutureProviderElement<DatabaseService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DatabaseService> create(Ref ref) {
    return databaseService(ref);
  }
}

String _$databaseServiceHash() => r'4b70714b1829eff89e609997d21e60bf44d5fd20';

@ProviderFor(schedulesDao)
final schedulesDaoProvider = SchedulesDaoProvider._();

final class SchedulesDaoProvider
    extends
        $FunctionalProvider<
          AsyncValue<SchedulesDao>,
          SchedulesDao,
          FutureOr<SchedulesDao>
        >
    with $FutureModifier<SchedulesDao>, $FutureProvider<SchedulesDao> {
  SchedulesDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schedulesDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schedulesDaoHash();

  @$internal
  @override
  $FutureProviderElement<SchedulesDao> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SchedulesDao> create(Ref ref) {
    return schedulesDao(ref);
  }
}

String _$schedulesDaoHash() => r'04807b9767fa099dedfe88aed356c028d7ed74b8';

@ProviderFor(settingsDao)
final settingsDaoProvider = SettingsDaoProvider._();

final class SettingsDaoProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsDao>,
          SettingsDao,
          FutureOr<SettingsDao>
        >
    with $FutureModifier<SettingsDao>, $FutureProvider<SettingsDao> {
  SettingsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsDaoHash();

  @$internal
  @override
  $FutureProviderElement<SettingsDao> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsDao> create(Ref ref) {
    return settingsDao(ref);
  }
}

String _$settingsDaoHash() => r'5c5a5dd3827b1d704fd1098298ef22cd6c39ad85';

@ProviderFor(dutyTypesDao)
final dutyTypesDaoProvider = DutyTypesDaoProvider._();

final class DutyTypesDaoProvider
    extends
        $FunctionalProvider<
          AsyncValue<DutyTypesDao>,
          DutyTypesDao,
          FutureOr<DutyTypesDao>
        >
    with $FutureModifier<DutyTypesDao>, $FutureProvider<DutyTypesDao> {
  DutyTypesDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dutyTypesDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dutyTypesDaoHash();

  @$internal
  @override
  $FutureProviderElement<DutyTypesDao> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DutyTypesDao> create(Ref ref) {
    return dutyTypesDao(ref);
  }
}

String _$dutyTypesDaoHash() => r'246b1106d6cfb10bb0c000d7a8064d41308254a8';

@ProviderFor(maintenanceDao)
final maintenanceDaoProvider = MaintenanceDaoProvider._();

final class MaintenanceDaoProvider
    extends
        $FunctionalProvider<
          AsyncValue<MaintenanceDao>,
          MaintenanceDao,
          FutureOr<MaintenanceDao>
        >
    with $FutureModifier<MaintenanceDao>, $FutureProvider<MaintenanceDao> {
  MaintenanceDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'maintenanceDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$maintenanceDaoHash();

  @$internal
  @override
  $FutureProviderElement<MaintenanceDao> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MaintenanceDao> create(Ref ref) {
    return maintenanceDao(ref);
  }
}

String _$maintenanceDaoHash() => r'c7b50b2f513c05906fdf19e0b8cd9e1019c017d7';

@ProviderFor(schedulesAdminDao)
final schedulesAdminDaoProvider = SchedulesAdminDaoProvider._();

final class SchedulesAdminDaoProvider
    extends
        $FunctionalProvider<
          AsyncValue<SchedulesAdminDao>,
          SchedulesAdminDao,
          FutureOr<SchedulesAdminDao>
        >
    with
        $FutureModifier<SchedulesAdminDao>,
        $FutureProvider<SchedulesAdminDao> {
  SchedulesAdminDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schedulesAdminDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schedulesAdminDaoHash();

  @$internal
  @override
  $FutureProviderElement<SchedulesAdminDao> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SchedulesAdminDao> create(Ref ref) {
    return schedulesAdminDao(ref);
  }
}

String _$schedulesAdminDaoHash() => r'364472462048526c0a0336d7e8bc21265d9c1276';

@ProviderFor(scheduleConfigsDao)
final scheduleConfigsDaoProvider = ScheduleConfigsDaoProvider._();

final class ScheduleConfigsDaoProvider
    extends
        $FunctionalProvider<
          AsyncValue<ScheduleConfigsDao>,
          ScheduleConfigsDao,
          FutureOr<ScheduleConfigsDao>
        >
    with
        $FutureModifier<ScheduleConfigsDao>,
        $FutureProvider<ScheduleConfigsDao> {
  ScheduleConfigsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleConfigsDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleConfigsDaoHash();

  @$internal
  @override
  $FutureProviderElement<ScheduleConfigsDao> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ScheduleConfigsDao> create(Ref ref) {
    return scheduleConfigsDao(ref);
  }
}

String _$scheduleConfigsDaoHash() =>
    r'ecac450006a3623baa28efbf479217677fef2517';

@ProviderFor(personalCalendarEntriesDao)
final personalCalendarEntriesDaoProvider =
    PersonalCalendarEntriesDaoProvider._();

final class PersonalCalendarEntriesDaoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PersonalCalendarEntriesDao>,
          PersonalCalendarEntriesDao,
          FutureOr<PersonalCalendarEntriesDao>
        >
    with
        $FutureModifier<PersonalCalendarEntriesDao>,
        $FutureProvider<PersonalCalendarEntriesDao> {
  PersonalCalendarEntriesDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalCalendarEntriesDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalCalendarEntriesDaoHash();

  @$internal
  @override
  $FutureProviderElement<PersonalCalendarEntriesDao> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PersonalCalendarEntriesDao> create(Ref ref) {
    return personalCalendarEntriesDao(ref);
  }
}

String _$personalCalendarEntriesDaoHash() =>
    r'0a2f0ff6c65cd96c91820abb6bfe10290a378ca1';

@ProviderFor(scheduleConfigService)
final scheduleConfigServiceProvider = ScheduleConfigServiceProvider._();

final class ScheduleConfigServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<ScheduleConfigService>,
          ScheduleConfigService,
          FutureOr<ScheduleConfigService>
        >
    with
        $FutureModifier<ScheduleConfigService>,
        $FutureProvider<ScheduleConfigService> {
  ScheduleConfigServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleConfigServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleConfigServiceHash();

  @$internal
  @override
  $FutureProviderElement<ScheduleConfigService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ScheduleConfigService> create(Ref ref) {
    return scheduleConfigService(ref);
  }
}

String _$scheduleConfigServiceHash() =>
    r'336862459ddd8fee5a46b83428c634b5d7a269f4';

@ProviderFor(languageService)
final languageServiceProvider = LanguageServiceProvider._();

final class LanguageServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<LanguageService>,
          LanguageService,
          FutureOr<LanguageService>
        >
    with $FutureModifier<LanguageService>, $FutureProvider<LanguageService> {
  LanguageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languageServiceHash();

  @$internal
  @override
  $FutureProviderElement<LanguageService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LanguageService> create(Ref ref) {
    return languageService(ref);
  }
}

String _$languageServiceHash() => r'7a5e6d1f64f2dcbbed73ac955594882881122816';

@ProviderFor(currentLocale)
final currentLocaleProvider = CurrentLocaleProvider._();

final class CurrentLocaleProvider
    extends $FunctionalProvider<AsyncValue<Locale>, Locale, Stream<Locale>>
    with $FutureModifier<Locale>, $StreamProvider<Locale> {
  CurrentLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentLocaleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentLocaleHash();

  @$internal
  @override
  $StreamProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Locale> create(Ref ref) {
    return currentLocale(ref);
  }
}

String _$currentLocaleHash() => r'd0a4fd9ce7251dd9223ed358e73c9430989c43eb';

@ProviderFor(themeMode)
final themeModeProvider = ThemeModeProvider._();

final class ThemeModeProvider
    extends
        $FunctionalProvider<
          AsyncValue<ThemeMode>,
          ThemeMode,
          FutureOr<ThemeMode>
        >
    with $FutureModifier<ThemeMode>, $FutureProvider<ThemeMode> {
  ThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeHash();

  @$internal
  @override
  $FutureProviderElement<ThemeMode> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ThemeMode> create(Ref ref) {
    return themeMode(ref);
  }
}

String _$themeModeHash() => r'85bb753abb97a06bf73f382f6af611d6a89d2b48';

@ProviderFor(appTheme)
final appThemeProvider = AppThemeProvider._();

final class AppThemeProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  AppThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return appTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$appThemeHash() => r'454b3d0b42eea01c9b9904767ed1fa1cb1f72736';

@ProviderFor(appDarkTheme)
final appDarkThemeProvider = AppDarkThemeProvider._();

final class AppDarkThemeProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  AppDarkThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDarkThemeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDarkThemeHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return appDarkTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$appDarkThemeHash() => r'33cb551912c40fc143ef06166fe3bd3e0526bbb0';

@ProviderFor(sentryService)
final sentryServiceProvider = SentryServiceProvider._();

final class SentryServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SentryService>,
          SentryService,
          FutureOr<SentryService>
        >
    with $FutureModifier<SentryService>, $FutureProvider<SentryService> {
  SentryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sentryServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sentryServiceHash();

  @$internal
  @override
  $FutureProviderElement<SentryService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SentryService> create(Ref ref) {
    return sentryService(ref);
  }
}

String _$sentryServiceHash() => r'19d9cf5817b25b1b47269423b011ebaf31667ecf';

@ProviderFor(sentryState)
final sentryStateProvider = SentryStateProvider._();

final class SentryStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SentryState>,
          SentryState,
          FutureOr<SentryState>
        >
    with $FutureModifier<SentryState>, $FutureProvider<SentryState> {
  SentryStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sentryStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sentryStateHash();

  @$internal
  @override
  $FutureProviderElement<SentryState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SentryState> create(Ref ref) {
    return sentryState(ref);
  }
}

String _$sentryStateHash() => r'8ccc406f1ec2372f7761c9ab5db407e93d2eefa8';

@ProviderFor(shareService)
final shareServiceProvider = ShareServiceProvider._();

final class ShareServiceProvider
    extends $FunctionalProvider<ShareService, ShareService, ShareService>
    with $Provider<ShareService> {
  ShareServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareServiceHash();

  @$internal
  @override
  $ProviderElement<ShareService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareService create(Ref ref) {
    return shareService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareService>(value),
    );
  }
}

String _$shareServiceHash() => r'ef854f8cb5e4f22a89f2b3a66f5bbe6980bc56c4';

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'cda5ea9d196dce85bee56839a4a0f035021752e3';

@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider = ScheduleRepositoryProvider._();

final class ScheduleRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ScheduleRepository>,
          ScheduleRepository,
          FutureOr<ScheduleRepository>
        >
    with
        $FutureModifier<ScheduleRepository>,
        $FutureProvider<ScheduleRepository> {
  ScheduleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ScheduleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ScheduleRepository> create(Ref ref) {
    return scheduleRepository(ref);
  }
}

String _$scheduleRepositoryHash() =>
    r'daa4c00231473dfb86689c01206720156e1f4759';

@ProviderFor(personalCalendarRepository)
final personalCalendarRepositoryProvider =
    PersonalCalendarRepositoryProvider._();

final class PersonalCalendarRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PersonalCalendarRepository>,
          PersonalCalendarRepository,
          FutureOr<PersonalCalendarRepository>
        >
    with
        $FutureModifier<PersonalCalendarRepository>,
        $FutureProvider<PersonalCalendarRepository> {
  PersonalCalendarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalCalendarRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalCalendarRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<PersonalCalendarRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PersonalCalendarRepository> create(Ref ref) {
    return personalCalendarRepository(ref);
  }
}

String _$personalCalendarRepositoryHash() =>
    r'163977145aef88a3aae50a7cd9d2b92a5e038ae3';

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsRepository>,
          SettingsRepository,
          FutureOr<SettingsRepository>
        >
    with
        $FutureModifier<SettingsRepository>,
        $FutureProvider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsRepository> create(Ref ref) {
    return settingsRepository(ref);
  }
}

String _$settingsRepositoryHash() =>
    r'3e3bf3608489e6dee17ae04fd8353851d040cff5';

@ProviderFor(configRepository)
final configRepositoryProvider = ConfigRepositoryProvider._();

final class ConfigRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConfigRepository>,
          ConfigRepository,
          FutureOr<ConfigRepository>
        >
    with $FutureModifier<ConfigRepository>, $FutureProvider<ConfigRepository> {
  ConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ConfigRepository> create(Ref ref) {
    return configRepository(ref);
  }
}

String _$configRepositoryHash() => r'7a6c6fcd1939f701b317fae9a4ab766eb5810e21';

@ProviderFor(getSchedulesUseCase)
final getSchedulesUseCaseProvider = GetSchedulesUseCaseProvider._();

final class GetSchedulesUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<GetSchedulesUseCase>,
          GetSchedulesUseCase,
          FutureOr<GetSchedulesUseCase>
        >
    with
        $FutureModifier<GetSchedulesUseCase>,
        $FutureProvider<GetSchedulesUseCase> {
  GetSchedulesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSchedulesUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSchedulesUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetSchedulesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GetSchedulesUseCase> create(Ref ref) {
    return getSchedulesUseCase(ref);
  }
}

String _$getSchedulesUseCaseHash() =>
    r'957e2a94538b8d1d8b0ba399d6049a6c4ca6a9a4';

@ProviderFor(listPersonalCalendarEntriesUseCase)
final listPersonalCalendarEntriesUseCaseProvider =
    ListPersonalCalendarEntriesUseCaseProvider._();

final class ListPersonalCalendarEntriesUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<ListPersonalCalendarEntriesUseCase>,
          ListPersonalCalendarEntriesUseCase,
          FutureOr<ListPersonalCalendarEntriesUseCase>
        >
    with
        $FutureModifier<ListPersonalCalendarEntriesUseCase>,
        $FutureProvider<ListPersonalCalendarEntriesUseCase> {
  ListPersonalCalendarEntriesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listPersonalCalendarEntriesUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$listPersonalCalendarEntriesUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<ListPersonalCalendarEntriesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ListPersonalCalendarEntriesUseCase> create(Ref ref) {
    return listPersonalCalendarEntriesUseCase(ref);
  }
}

String _$listPersonalCalendarEntriesUseCaseHash() =>
    r'1f493e4f2408cab0bde7641c7e1c704dec144b81';

@ProviderFor(savePersonalCalendarEntryUseCase)
final savePersonalCalendarEntryUseCaseProvider =
    SavePersonalCalendarEntryUseCaseProvider._();

final class SavePersonalCalendarEntryUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<SavePersonalCalendarEntryUseCase>,
          SavePersonalCalendarEntryUseCase,
          FutureOr<SavePersonalCalendarEntryUseCase>
        >
    with
        $FutureModifier<SavePersonalCalendarEntryUseCase>,
        $FutureProvider<SavePersonalCalendarEntryUseCase> {
  SavePersonalCalendarEntryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savePersonalCalendarEntryUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savePersonalCalendarEntryUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<SavePersonalCalendarEntryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SavePersonalCalendarEntryUseCase> create(Ref ref) {
    return savePersonalCalendarEntryUseCase(ref);
  }
}

String _$savePersonalCalendarEntryUseCaseHash() =>
    r'483b197a749b7671738af756bc2c38466309814f';

@ProviderFor(deletePersonalCalendarEntryUseCase)
final deletePersonalCalendarEntryUseCaseProvider =
    DeletePersonalCalendarEntryUseCaseProvider._();

final class DeletePersonalCalendarEntryUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeletePersonalCalendarEntryUseCase>,
          DeletePersonalCalendarEntryUseCase,
          FutureOr<DeletePersonalCalendarEntryUseCase>
        >
    with
        $FutureModifier<DeletePersonalCalendarEntryUseCase>,
        $FutureProvider<DeletePersonalCalendarEntryUseCase> {
  DeletePersonalCalendarEntryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deletePersonalCalendarEntryUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$deletePersonalCalendarEntryUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<DeletePersonalCalendarEntryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeletePersonalCalendarEntryUseCase> create(Ref ref) {
    return deletePersonalCalendarEntryUseCase(ref);
  }
}

String _$deletePersonalCalendarEntryUseCaseHash() =>
    r'9fff7ed2f38f74933dad74a6b759165088aa55a7';

@ProviderFor(generateSchedulesUseCase)
final generateSchedulesUseCaseProvider = GenerateSchedulesUseCaseProvider._();

final class GenerateSchedulesUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<GenerateSchedulesUseCase>,
          GenerateSchedulesUseCase,
          FutureOr<GenerateSchedulesUseCase>
        >
    with
        $FutureModifier<GenerateSchedulesUseCase>,
        $FutureProvider<GenerateSchedulesUseCase> {
  GenerateSchedulesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'generateSchedulesUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$generateSchedulesUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GenerateSchedulesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GenerateSchedulesUseCase> create(Ref ref) {
    return generateSchedulesUseCase(ref);
  }
}

String _$generateSchedulesUseCaseHash() =>
    r'f4376c41dd486cc00bb0494422624182c30a4adf';

@ProviderFor(getSettingsUseCase)
final getSettingsUseCaseProvider = GetSettingsUseCaseProvider._();

final class GetSettingsUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<GetSettingsUseCase>,
          GetSettingsUseCase,
          FutureOr<GetSettingsUseCase>
        >
    with
        $FutureModifier<GetSettingsUseCase>,
        $FutureProvider<GetSettingsUseCase> {
  GetSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSettingsUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetSettingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GetSettingsUseCase> create(Ref ref) {
    return getSettingsUseCase(ref);
  }
}

String _$getSettingsUseCaseHash() =>
    r'10f652a22347a13cf24ec272bd25aa0ccbf2ebbd';

@ProviderFor(saveSettingsUseCase)
final saveSettingsUseCaseProvider = SaveSettingsUseCaseProvider._();

final class SaveSettingsUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaveSettingsUseCase>,
          SaveSettingsUseCase,
          FutureOr<SaveSettingsUseCase>
        >
    with
        $FutureModifier<SaveSettingsUseCase>,
        $FutureProvider<SaveSettingsUseCase> {
  SaveSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveSettingsUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<SaveSettingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaveSettingsUseCase> create(Ref ref) {
    return saveSettingsUseCase(ref);
  }
}

String _$saveSettingsUseCaseHash() =>
    r'85dad0abe2b3425265dd712fb1834cbd957fce83';

@ProviderFor(resetSettingsUseCase)
final resetSettingsUseCaseProvider = ResetSettingsUseCaseProvider._();

final class ResetSettingsUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<ResetSettingsUseCase>,
          ResetSettingsUseCase,
          FutureOr<ResetSettingsUseCase>
        >
    with
        $FutureModifier<ResetSettingsUseCase>,
        $FutureProvider<ResetSettingsUseCase> {
  ResetSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetSettingsUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<ResetSettingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ResetSettingsUseCase> create(Ref ref) {
    return resetSettingsUseCase(ref);
  }
}

String _$resetSettingsUseCaseHash() =>
    r'd0b674822db80c3c24f1d2a003cd5d435b9d19c2';

@ProviderFor(getConfigsUseCase)
final getConfigsUseCaseProvider = GetConfigsUseCaseProvider._();

final class GetConfigsUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<GetConfigsUseCase>,
          GetConfigsUseCase,
          FutureOr<GetConfigsUseCase>
        >
    with
        $FutureModifier<GetConfigsUseCase>,
        $FutureProvider<GetConfigsUseCase> {
  GetConfigsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getConfigsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getConfigsUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetConfigsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GetConfigsUseCase> create(Ref ref) {
    return getConfigsUseCase(ref);
  }
}

String _$getConfigsUseCaseHash() => r'c5cf41e41bbd51d13a93e5c79f7f3e4b032cb918';

@ProviderFor(setActiveConfigUseCase)
final setActiveConfigUseCaseProvider = SetActiveConfigUseCaseProvider._();

final class SetActiveConfigUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<SetActiveConfigUseCase>,
          SetActiveConfigUseCase,
          FutureOr<SetActiveConfigUseCase>
        >
    with
        $FutureModifier<SetActiveConfigUseCase>,
        $FutureProvider<SetActiveConfigUseCase> {
  SetActiveConfigUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setActiveConfigUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setActiveConfigUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<SetActiveConfigUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SetActiveConfigUseCase> create(Ref ref) {
    return setActiveConfigUseCase(ref);
  }
}

String _$setActiveConfigUseCaseHash() =>
    r'd34ae1da55cd543bdf7ae3c8a247dd7e691b8b69';

@ProviderFor(scheduleMergeService)
final scheduleMergeServiceProvider = ScheduleMergeServiceProvider._();

final class ScheduleMergeServiceProvider
    extends
        $FunctionalProvider<
          ScheduleMergeService,
          ScheduleMergeService,
          ScheduleMergeService
        >
    with $Provider<ScheduleMergeService> {
  ScheduleMergeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleMergeServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleMergeServiceHash();

  @$internal
  @override
  $ProviderElement<ScheduleMergeService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ScheduleMergeService create(Ref ref) {
    return scheduleMergeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleMergeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleMergeService>(value),
    );
  }
}

String _$scheduleMergeServiceHash() =>
    r'1329084894b6b3282eaea9f02398d399839f9a3d';

@ProviderFor(dateRangePolicy)
final dateRangePolicyProvider = DateRangePolicyProvider._();

final class DateRangePolicyProvider
    extends
        $FunctionalProvider<DateRangePolicy, DateRangePolicy, DateRangePolicy>
    with $Provider<DateRangePolicy> {
  DateRangePolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dateRangePolicyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dateRangePolicyHash();

  @$internal
  @override
  $ProviderElement<DateRangePolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateRangePolicy create(Ref ref) {
    return dateRangePolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateRangePolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateRangePolicy>(value),
    );
  }
}

String _$dateRangePolicyHash() => r'5a03b97bb502d325b1b306ff3a2c3bf40d17c658';

@ProviderFor(configQueryService)
final configQueryServiceProvider = ConfigQueryServiceProvider._();

final class ConfigQueryServiceProvider
    extends
        $FunctionalProvider<
          ConfigQueryService,
          ConfigQueryService,
          ConfigQueryService
        >
    with $Provider<ConfigQueryService> {
  ConfigQueryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configQueryServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configQueryServiceHash();

  @$internal
  @override
  $ProviderElement<ConfigQueryService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConfigQueryService create(Ref ref) {
    return configQueryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfigQueryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfigQueryService>(value),
    );
  }
}

String _$configQueryServiceHash() =>
    r'3bbd10deb49c014e9eb60d18d5c37e655f267d1b';

@ProviderFor(ensureMonthSchedulesUseCase)
final ensureMonthSchedulesUseCaseProvider =
    EnsureMonthSchedulesUseCaseProvider._();

final class EnsureMonthSchedulesUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<EnsureMonthSchedulesUseCase>,
          EnsureMonthSchedulesUseCase,
          FutureOr<EnsureMonthSchedulesUseCase>
        >
    with
        $FutureModifier<EnsureMonthSchedulesUseCase>,
        $FutureProvider<EnsureMonthSchedulesUseCase> {
  EnsureMonthSchedulesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ensureMonthSchedulesUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ensureMonthSchedulesUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<EnsureMonthSchedulesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EnsureMonthSchedulesUseCase> create(Ref ref) {
    return ensureMonthSchedulesUseCase(ref);
  }
}

String _$ensureMonthSchedulesUseCaseHash() =>
    r'4c80d45631aa17b8e86f3054560ed15a3bf28378';

@ProviderFor(schoolHolidayRemoteDataSource)
final schoolHolidayRemoteDataSourceProvider =
    SchoolHolidayRemoteDataSourceProvider._();

final class SchoolHolidayRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          SchoolHolidayRemoteDataSource,
          SchoolHolidayRemoteDataSource,
          SchoolHolidayRemoteDataSource
        >
    with $Provider<SchoolHolidayRemoteDataSource> {
  SchoolHolidayRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolHolidayRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolHolidayRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SchoolHolidayRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SchoolHolidayRemoteDataSource create(Ref ref) {
    return schoolHolidayRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SchoolHolidayRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SchoolHolidayRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$schoolHolidayRemoteDataSourceHash() =>
    r'797594b55f01054d0ce9fe0b8d2ab489f762e25c';

@ProviderFor(schoolHolidaysDao)
final schoolHolidaysDaoProvider = SchoolHolidaysDaoProvider._();

final class SchoolHolidaysDaoProvider
    extends
        $FunctionalProvider<
          SchoolHolidaysDao,
          SchoolHolidaysDao,
          SchoolHolidaysDao
        >
    with $Provider<SchoolHolidaysDao> {
  SchoolHolidaysDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolHolidaysDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolHolidaysDaoHash();

  @$internal
  @override
  $ProviderElement<SchoolHolidaysDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SchoolHolidaysDao create(Ref ref) {
    return schoolHolidaysDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SchoolHolidaysDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SchoolHolidaysDao>(value),
    );
  }
}

String _$schoolHolidaysDaoHash() => r'd1a89dc4edd8a297702eb4d347f2ad99a7d976f8';

@ProviderFor(schoolHolidayLocalDataSource)
final schoolHolidayLocalDataSourceProvider =
    SchoolHolidayLocalDataSourceProvider._();

final class SchoolHolidayLocalDataSourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SchoolHolidayLocalDataSource>,
          SchoolHolidayLocalDataSource,
          FutureOr<SchoolHolidayLocalDataSource>
        >
    with
        $FutureModifier<SchoolHolidayLocalDataSource>,
        $FutureProvider<SchoolHolidayLocalDataSource> {
  SchoolHolidayLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolHolidayLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolHolidayLocalDataSourceHash();

  @$internal
  @override
  $FutureProviderElement<SchoolHolidayLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SchoolHolidayLocalDataSource> create(Ref ref) {
    return schoolHolidayLocalDataSource(ref);
  }
}

String _$schoolHolidayLocalDataSourceHash() =>
    r'1161606996f63d69383798240663c5961e3be4d6';

@ProviderFor(schoolHolidayRepository)
final schoolHolidayRepositoryProvider = SchoolHolidayRepositoryProvider._();

final class SchoolHolidayRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SchoolHolidayRepository>,
          SchoolHolidayRepository,
          FutureOr<SchoolHolidayRepository>
        >
    with
        $FutureModifier<SchoolHolidayRepository>,
        $FutureProvider<SchoolHolidayRepository> {
  SchoolHolidayRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schoolHolidayRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schoolHolidayRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SchoolHolidayRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SchoolHolidayRepository> create(Ref ref) {
    return schoolHolidayRepository(ref);
  }
}

String _$schoolHolidayRepositoryHash() =>
    r'6a7e9e57d3f02de496d3f99a46c05a1b29cb503c';

@ProviderFor(getSchoolHolidaysUseCase)
final getSchoolHolidaysUseCaseProvider = GetSchoolHolidaysUseCaseProvider._();

final class GetSchoolHolidaysUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<GetSchoolHolidaysUseCase>,
          GetSchoolHolidaysUseCase,
          FutureOr<GetSchoolHolidaysUseCase>
        >
    with
        $FutureModifier<GetSchoolHolidaysUseCase>,
        $FutureProvider<GetSchoolHolidaysUseCase> {
  GetSchoolHolidaysUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSchoolHolidaysUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSchoolHolidaysUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetSchoolHolidaysUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GetSchoolHolidaysUseCase> create(Ref ref) {
    return getSchoolHolidaysUseCase(ref);
  }
}

String _$getSchoolHolidaysUseCaseHash() =>
    r'fa0e86b5dc883ef81cac9bfd1069071821c88617';
