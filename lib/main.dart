import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:dienstplan/core/initialization/app_initializer.dart';
import 'package:dienstplan/data/services/sentry_service.dart';
import 'package:dienstplan/presentation/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  await AppInitializer.initialize();

  // Get sentry service for initialization
  final sentryService = await GetIt.instance.getAsync<SentryService>();

  await AppInitializer.initializeSentry(sentryService);

  runApp(SentryWidget(
    child: const ProviderScope(child: MyApp()),
  ));
}
