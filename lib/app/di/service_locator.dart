import 'package:get_it/get_it.dart';
import 'package:habit_focus/core/config/app_config.dart';

/// Global service locator.
///
/// Resolve dependencies only in composition roots (app bootstrap, feature
/// `di.dart` files), never inside domain or widget code.
final GetIt getIt = GetIt.instance;

/// Registers app-wide dependencies. Call once, before `runApp`.
void configureDependencies(AppConfig config) {
  getIt.registerSingleton<AppConfig>(config);
}

/// Removes every registration. Intended for tests.
Future<void> resetDependencies() => getIt.reset();
