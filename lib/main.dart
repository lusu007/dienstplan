import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dienstplan/core/initialization/app_initializer.dart';
import 'package:dienstplan/presentation/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienstplan/core/di/riverpod_providers.dart';
import 'package:dienstplan/core/utils/logger.dart';

void main() async {
  final container = await AppInitializer.initialize();
  // Provide container to logger for Sentry lookups without creating new containers
  AppLogger.setProviderContainer(container);
  final sentryService = await container.read(sentryServiceProvider.future);
  await AppInitializer.initializeSentry(sentryService);
  runApp(
    SentryWidget(
      child: UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    ),
  );
}
