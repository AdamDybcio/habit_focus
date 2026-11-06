import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/network/dio_token_refresher.dart';

import '../../helpers/fake_http_adapter.dart';

void main() {
  late FakeHttpAdapter adapter;
  late DioTokenRefresher refresher;

  setUp(() {
    adapter = FakeHttpAdapter(
      (_) async => jsonResponse({
        'accessToken': 'new-access',
        'refreshToken': 'new-refresh',
      }),
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    refresher = DioTokenRefresher(dio);
  });

  test('posts the refresh token to /auth/refresh', () async {
    await refresher.refresh('old-refresh');

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/auth/refresh');
    expect(request.data, {'refreshToken': 'old-refresh'});
  });

  test('does not send an Authorization header', () async {
    await refresher.refresh('old-refresh');

    expect(
      adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
  });

  test('returns the new token pair', () async {
    final tokens = await refresher.refresh('old-refresh');

    expect(
      tokens,
      const AuthTokens(accessToken: 'new-access', refreshToken: 'new-refresh'),
    );
  });

  test('throws DioException when the backend rejects the token', () async {
    adapter.handler = (_) async => jsonResponse({}, status: 401);

    await expectLater(
      refresher.refresh('old-refresh'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status code',
          401,
        ),
      ),
    );
  });

  test('throws FormatException for a malformed body', () async {
    adapter.handler = (_) async => jsonResponse({'accessToken': 'a'});

    await expectLater(refresher.refresh('old-refresh'), throwsFormatException);
  });
}
