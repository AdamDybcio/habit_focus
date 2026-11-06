import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/auth/session_events.dart';
import 'package:habit_focus/core/config/app_config.dart';
import 'package:habit_focus/core/network/auth_interceptor.dart';
import 'package:habit_focus/core/network/dio_factory.dart';

import '../../helpers/fake_token_refresher.dart';
import '../../helpers/in_memory_token_storage.dart';

Dio _apiDio(AppConfig config) {
  return createApiDio(
    config: config,
    tokenStorage: InMemoryTokenStorage(),
    tokenRefresher: FakeTokenRefresher((_) async => throw UnimplementedError()),
    sessionEvents: SessionEvents(),
  );
}

void main() {
  final dev = AppConfig.parse(
    flavor: 'dev',
    apiBaseUrl: 'http://10.0.2.2:8000/api',
  );
  final prod = AppConfig.parse(
    flavor: 'prod',
    apiBaseUrl: 'https://api.example.com/api/',
  );

  group('createBaseDio', () {
    test('uses the configured base url without a trailing slash', () {
      expect(createBaseDio(dev).options.baseUrl, 'http://10.0.2.2:8000/api');
      expect(
        createBaseDio(prod).options.baseUrl,
        'https://api.example.com/api',
      );
    });

    test('sets timeouts and accepts JSON', () {
      final options = createBaseDio(dev).options;

      expect(options.connectTimeout, isNotNull);
      expect(options.receiveTimeout, isNotNull);
      expect(options.headers['Accept'], Headers.jsonContentType);
    });

    test('has no interceptors that could loop the token refresh', () {
      final interceptors = createBaseDio(dev).interceptors
          .whereType<AuthInterceptor>();

      expect(interceptors, isEmpty);
    });
  });

  group('createApiDio', () {
    test('installs the auth interceptor', () {
      final dio = _apiDio(dev);

      expect(dio.interceptors.whereType<AuthInterceptor>(), hasLength(1));
    });

    test('logs requests outside production, without bodies or headers', () {
      final logs = _apiDio(dev).interceptors.whereType<LogInterceptor>();

      expect(logs, hasLength(1));
      expect(logs.single.requestBody, isFalse);
      expect(logs.single.responseBody, isFalse);
      expect(logs.single.requestHeader, isFalse);
      expect(logs.single.responseHeader, isFalse);
    });

    test('does not log in production', () {
      final logs = _apiDio(prod).interceptors.whereType<LogInterceptor>();

      expect(logs, isEmpty);
    });
  });
}
