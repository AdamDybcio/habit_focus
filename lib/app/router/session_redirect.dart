import 'package:habit_focus/app/router/app_routes.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_state.dart';

/// Decides where the user must be, given the [session] and the current
/// [location]. Returns `null` when the user may stay where they are.
String? sessionRedirect(SessionState session, String location) {
  return switch (session) {
    SessionUnknown() =>
      location == AppRoutes.splashPath ? null : AppRoutes.splashPath,
    SessionAuthenticated() =>
      (location == AppRoutes.loginPath || location == AppRoutes.splashPath)
          ? AppRoutes.homePath
          : null,
    SessionUnauthenticated() =>
      location == AppRoutes.loginPath ? null : AppRoutes.loginPath,
  };
}
