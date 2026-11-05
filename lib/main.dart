import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:habit_focus/app/app.dart';
import 'package:habit_focus/app/di/service_locator.dart';
import 'package:habit_focus/app/router/app_router.dart';
import 'package:habit_focus/core/config/app_config.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_cubit.dart';

/// Application entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  configureDependencies(config);
  final session = getIt<SessionCubit>();
  unawaited(session.start());
  runApp(App(router: createRouter(config, session)));
}
