import 'package:dio/dio.dart';
import 'package:habit_focus/core/auth/session_events.dart';
import 'package:habit_focus/core/auth/token_storage.dart';
import 'package:habit_focus/core/config/app_config.dart';
import 'package:habit_focus/core/network/auth_interceptor.dart';
import 'package:habit_focus/core/network/token_refresher.dart';

/// Creates a plain [Dio] for [config]: base URL, timeouts, JSON, no
/// interceptors. Used for the token refresh call.
Dio createBaseDio(AppConfig config) {
  final baseUrl = config.apiBaseUrl.toString().replaceFirst(RegExp(r'/+$'), '');
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      headers: <String, Object>{'Accept': Headers.jsonContentType},
    ),
  );
}

/// Creates the shared API client with authentication handling.
///
/// Logging is limited to request lines and status codes: never headers or
/// bodies, because they contain tokens and personal data. It is disabled in
/// production builds.
Dio createApiDio({
  required AppConfig config,
  required TokenStorage tokenStorage,
  required TokenRefresher tokenRefresher,
  required SessionEvents sessionEvents,
}) {
  final dio = createBaseDio(config);
  dio.interceptors.add(
    AuthInterceptor(dio, tokenStorage, tokenRefresher, sessionEvents),
  );
  if (config.loggingEnabled) {
    dio.interceptors.add(
      LogInterceptor(requestHeader: false, responseHeader: false),
    );
  }
  return dio;
}
