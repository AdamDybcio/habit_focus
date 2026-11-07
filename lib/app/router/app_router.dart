import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_focus/app/di/service_locator.dart';
import 'package:habit_focus/app/router/app_routes.dart';
import 'package:habit_focus/app/router/session_redirect.dart';
import 'package:habit_focus/app/router/stream_refresh_listenable.dart';
import 'package:habit_focus/core/config/app_config.dart';
import 'package:habit_focus/features/auth/presentation/bloc/login_cubit.dart';
import 'package:habit_focus/features/auth/presentation/bloc/register_cubit.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_cubit.dart';
import 'package:habit_focus/features/auth/presentation/pages/login_page.dart';
import 'package:habit_focus/features/auth/presentation/pages/register_page.dart';
import 'package:habit_focus/features/auth/presentation/pages/splash_page.dart';
import 'package:habit_focus/features/home/presentation/pages/home_page.dart';

/// Builds the router of the app for the given [config].
///
/// Navigation follows the [session]: signed-out users are sent to the login
/// screen, signed-in users to the home screen.
GoRouter createRouter(AppConfig config, SessionCubit session) {
  return GoRouter(
    initialLocation: AppRoutes.homePath,
    debugLogDiagnostics: config.loggingEnabled,
    refreshListenable: StreamRefreshListenable(session.stream),
    redirect: (context, state) =>
        sessionRedirect(session.state, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => BlocProvider<LoginCubit>(
          create: (_) => getIt<LoginCubit>(),
          child: LoginPage(
            onLoggedIn: session.loggedIn,
            onCreateAccount: () => context.go(AppRoutes.registerPath),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.registerName,
        builder: (context, state) => BlocProvider<RegisterCubit>(
          create: (_) => getIt<RegisterCubit>(),
          child: RegisterPage(
            onRegistered: session.loggedIn,
            onHaveAccount: () => context.go(AppRoutes.loginPath),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        builder: (context, state) => HomePage(
          flavor: config.flavor,
          onLogout: () => unawaited(session.logout()),
        ),
      ),
    ],
  );
}
