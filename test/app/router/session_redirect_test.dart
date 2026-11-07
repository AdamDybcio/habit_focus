import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/app/router/app_routes.dart';
import 'package:habit_focus/app/router/session_redirect.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_state.dart';

void main() {
  group('sessionRedirect', () {
    test('unknown session is held on the splash screen', () {
      const state = SessionUnknown();

      expect(sessionRedirect(state, AppRoutes.homePath), AppRoutes.splashPath);
      expect(sessionRedirect(state, AppRoutes.loginPath), AppRoutes.splashPath);
      expect(sessionRedirect(state, AppRoutes.splashPath), isNull);
    });

    test('signed-out user is sent to the login screen', () {
      const state = SessionUnauthenticated();

      expect(sessionRedirect(state, AppRoutes.homePath), AppRoutes.loginPath);
      expect(sessionRedirect(state, AppRoutes.splashPath), AppRoutes.loginPath);
      expect(sessionRedirect(state, AppRoutes.loginPath), isNull);
    });

    test('signed-out user may open the registration screen', () {
      const state = SessionUnauthenticated();

      expect(sessionRedirect(state, AppRoutes.registerPath), isNull);
    });

    test('signed-in user leaves login, registration and splash for home', () {
      const state = SessionAuthenticated();

      expect(sessionRedirect(state, AppRoutes.loginPath), AppRoutes.homePath);
      expect(
        sessionRedirect(state, AppRoutes.registerPath),
        AppRoutes.homePath,
      );
      expect(sessionRedirect(state, AppRoutes.splashPath), AppRoutes.homePath);
      expect(sessionRedirect(state, AppRoutes.homePath), isNull);
    });
  });
}
