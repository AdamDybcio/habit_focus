import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/auth/session_events.dart';
import 'package:habit_focus/core/network/auth_interceptor.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fake_token_refresher.dart';
import '../../helpers/in_memory_token_storage.dart';

const _oldTokens = AuthTokens(
  accessToken: 'old-access',
  refreshToken: 'old-refresh',
);
const _newTokens = AuthTokens(
  accessToken: 'new-access',
  refreshToken: 'new-refresh',
);

DioException _refreshError(int? status) {
  final options = RequestOptions(path: '/auth/refresh');
  if (status == null) {
    return DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );
  }
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(requestOptions: options, statusCode: status),
  );
}

Matcher _failsWithStatus(int status) {
  return throwsA(
    isA<DioException>().having(
      (e) => e.response?.statusCode,
      'status code',
      status,
    ),
  );
}

void main() {
  late InMemoryTokenStorage storage;
  late SessionEvents events;
  late FakeTokenRefresher refresher;
  late FakeHttpAdapter adapter;
  late Dio dio;
  late int expiredCount;

  setUp(() {
    storage = InMemoryTokenStorage(_oldTokens);
    events = SessionEvents();
    expiredCount = 0;
    events.expired.listen((_) => expiredCount++);
    refresher = FakeTokenRefresher((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      return _newTokens;
    });
    // The server accepts only the new access token.
    adapter = FakeHttpAdapter((options) async {
      if (options.headers['Authorization'] == 'Bearer new-access') {
        return jsonResponse({'ok': true});
      }
      return jsonResponse({'error': 'unauthorized'}, status: 401);
    });
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(dio, storage, refresher, events));
  });

  tearDown(() => events.dispose());

  group('AuthInterceptor requests', () {
    test('adds the bearer header when a session exists', () async {
      storage.tokens = _newTokens;

      final response = await dio.get<Object?>('/me');

      expect(response.statusCode, 200);
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer new-access',
      );
      expect(refresher.calls, 0);
    });

    test('sends no header without a session', () async {
      storage.tokens = null;

      await expectLater(dio.get<Object?>('/me'), _failsWithStatus(401));

      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(refresher.calls, 0);
    });

    test('skips authentication when skipAuth is set', () async {
      await expectLater(
        dio.get<Object?>(
          '/auth/login',
          options: Options(
            extra: <String, Object?>{AuthInterceptor.skipAuthKey: true},
          ),
        ),
        _failsWithStatus(401),
      );

      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(refresher.calls, 0);
    });
  });

  group('AuthInterceptor token refresh', () {
    test('refreshes on 401 and retries with the new token', () async {
      final response = await dio.get<Object?>('/me');

      expect(response.statusCode, 200);
      expect(response.data, {'ok': true});
      expect(refresher.calls, 1);
      expect(storage.tokens, _newTokens);
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer new-access',
      );
    });

    test('sends the stored refresh token to the refresher', () async {
      String? received;
      refresher.onRefresh = (token) async {
        received = token;
        return _newTokens;
      };

      await dio.get<Object?>('/me');

      expect(received, 'old-refresh');
    });

    test('concurrent 401s trigger exactly one refresh', () async {
      final responses = await Future.wait([
        dio.get<Object?>('/me'),
        dio.get<Object?>('/me'),
        dio.get<Object?>('/me'),
      ]);

      expect(responses.map((r) => r.statusCode), everyElement(200));
      expect(refresher.calls, 1);
      // Three failed attempts plus three retries.
      expect(adapter.requests, hasLength(6));
    });

    test('does not loop when the retried request is still 401', () async {
      adapter.handler = (_) async => jsonResponse({}, status: 401);

      await expectLater(dio.get<Object?>('/me'), _failsWithStatus(401));

      expect(refresher.calls, 1);
      expect(adapter.requests, hasLength(2));
      expect(storage.tokens, _newTokens);
      expect(expiredCount, 0);
    });

    test('rejected refresh token clears the session and notifies', () async {
      refresher.onRefresh = (_) async => throw _refreshError(401);

      await expectLater(dio.get<Object?>('/me'), _failsWithStatus(401));
      await Future<void>.delayed(Duration.zero);

      expect(storage.tokens, isNull);
      expect(expiredCount, 1);
      expect(adapter.requests, hasLength(1));
    });

    test('network error during refresh keeps the session', () async {
      refresher.onRefresh = (_) async => throw _refreshError(null);

      await expectLater(dio.get<Object?>('/me'), _failsWithStatus(401));
      await Future<void>.delayed(Duration.zero);

      expect(storage.tokens, _oldTokens);
      expect(expiredCount, 0);
    });

    test('server error during refresh keeps the session', () async {
      refresher.onRefresh = (_) async => throw _refreshError(500);

      await expectLater(dio.get<Object?>('/me'), _failsWithStatus(401));
      await Future<void>.delayed(Duration.zero);

      expect(storage.tokens, _oldTokens);
      expect(expiredCount, 0);
    });

    test('malformed refresh response keeps the session', () async {
      refresher.onRefresh = (_) async => throw const FormatException('bad');

      await expectLater(dio.get<Object?>('/me'), _failsWithStatus(401));

      expect(storage.tokens, _oldTokens);
      expect(expiredCount, 0);
    });

    test('a new refresh can start after the previous one finished', () async {
      await dio.get<Object?>('/me');
      storage.tokens = _oldTokens;

      await dio.get<Object?>('/me');

      expect(refresher.calls, 2);
    });
  });
}
