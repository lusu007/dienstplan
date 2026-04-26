import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/initialization/app_initializer.dart';
import 'package:dienstplan/presentation/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';

void main() async {
  final container = await AppInitializer.initialize();
  final sentryService = await container.read(sentryServiceProvider.future);
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  await AppInitializer.initializeSentry(sentryService, packageInfo);
  runApp(
    SentryWidget(
      child: UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    ),
  );
}
