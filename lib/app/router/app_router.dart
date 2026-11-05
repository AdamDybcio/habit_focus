import 'package:go_router/go_router.dart';
import 'package:habit_focus/app/router/app_routes.dart';
import 'package:habit_focus/core/config/app_config.dart';
import 'package:habit_focus/features/home/presentation/pages/home_page.dart';

/// Builds the router of the app for the given [config].
GoRouter createRouter(AppConfig config) {
  return GoRouter(
    initialLocation: AppRoutes.homePath,
    debugLogDiagnostics: config.loggingEnabled,
    routes: [
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        builder: (context, state) => HomePage(flavor: config.flavor),
      ),
    ],
  );
}
