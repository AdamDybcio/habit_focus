import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:habit_focus/core/auth/secure_token_storage.dart';
import 'package:habit_focus/core/auth/session_events.dart';
import 'package:habit_focus/core/auth/token_storage.dart';
import 'package:habit_focus/core/config/app_config.dart';
import 'package:habit_focus/core/network/dio_factory.dart';
import 'package:habit_focus/core/network/dio_token_refresher.dart';
import 'package:habit_focus/core/network/token_refresher.dart';
import 'package:habit_focus/features/auth/di.dart';

/// Global service locator.
///
/// Resolve dependencies only in composition roots (app bootstrap, feature
/// `di.dart` files), never inside domain or widget code.
final GetIt getIt = GetIt.instance;

/// Registers app-wide dependencies. Call once, before `runApp`.
void configureDependencies(AppConfig config) {
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerLazySingleton<SessionEvents>(
      SessionEvents.new,
      dispose: (events) => events.dispose(),
    )
    ..registerLazySingleton<TokenStorage>(
      () => const SecureTokenStorage(FlutterSecureStorage()),
    )
    ..registerLazySingleton<TokenRefresher>(
      () => DioTokenRefresher(createBaseDio(getIt<AppConfig>())),
    )
    ..registerLazySingleton<Dio>(
      () => createApiDio(
        config: getIt<AppConfig>(),
        tokenStorage: getIt<TokenStorage>(),
        tokenRefresher: getIt<TokenRefresher>(),
        sessionEvents: getIt<SessionEvents>(),
      ),
    );
  registerAuthDependencies(getIt);
}

/// Removes every registration. Intended for tests.
Future<void> resetDependencies() => getIt.reset();
