import 'package:habit_focus/app/router/app_routes.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_state.dart';

/// Screens only a signed-out user needs, signed-in users are sent home.
const Set<String> _signedOutLocations = {
  AppRoutes.loginPath,
  AppRoutes.registerPath,
  AppRoutes.splashPath,
};

/// Screens a signed-out user may open.
const Set<String> _publicLocations = {
  AppRoutes.loginPath,
  AppRoutes.registerPath,
};

/// Decides where the user must be, given the [session] and the current
/// [location]. Returns `null` when the user may stay where they are.
String? sessionRedirect(SessionState session, String location) {
  return switch (session) {
    SessionUnknown() =>
      location == AppRoutes.splashPath ? null : AppRoutes.splashPath,
    SessionAuthenticated() =>
      _signedOutLocations.contains(location) ? AppRoutes.homePath : null,
    SessionUnauthenticated() =>
      _publicLocations.contains(location) ? null : AppRoutes.loginPath,
  };
}
