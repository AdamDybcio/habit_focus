import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/network/auth_interceptor.dart';
import 'package:habit_focus/features/auth/data/datasources/auth_remote_data_source.dart';

import '../../../helpers/fake_http_adapter.dart';

void main() {
  late FakeHttpAdapter adapter;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    adapter = FakeHttpAdapter(
      (_) async =>
          jsonResponse({'accessToken': 'access', 'refreshToken': 'refresh'}),
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dataSource = AuthRemoteDataSource(dio);
  });

  group('login', () {
    test('posts the credentials to /auth/login', () async {
      await dataSource.login(email: 'a@b.pl', password: 'secret');

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/auth/login');
      expect(request.data, {'email': 'a@b.pl', 'password': 'secret'});
    });

    test('marks the request as public', () async {
      await dataSource.login(email: 'a@b.pl', password: 'secret');

      expect(
        adapter.requests.single.extra[AuthInterceptor.skipAuthKey],
        isTrue,
      );
    });

    test('returns the issued tokens', () async {
      final tokens = await dataSource.login(email: 'a@b.pl', password: 'x');

      expect(
        tokens,
        const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
      );
    });

    test('throws DioException for wrong credentials', () async {
      adapter.handler = (_) async => jsonResponse({}, status: 401);

      await expectLater(
        dataSource.login(email: 'a@b.pl', password: 'x'),
        throwsA(isA<DioException>()),
      );
    });

    test('throws FormatException for a malformed body', () async {
      adapter.handler = (_) async => jsonResponse({'unexpected': true});

      await expectLater(
        dataSource.login(email: 'a@b.pl', password: 'x'),
        throwsFormatException,
      );
    });
  });
  group('register', () {
    test('posts the credentials to /auth/register', () async {
      final tokens = await dataSource.register(
        email: 'a@b.pl',
        password: 'long enough password',
      );

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/auth/register');
      expect(request.data, {
        'email': 'a@b.pl',
        'password': 'long enough password',
      });
      expect(request.extra[AuthInterceptor.skipAuthKey], isTrue);
      expect(
        tokens,
        const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
      );
    });

    test('throws DioException when the email is taken', () async {
      adapter.handler = (_) async => jsonResponse({}, status: 409);

      await expectLater(
        dataSource.register(email: 'a@b.pl', password: 'long enough password'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('logout', () {
    test('posts the refresh token to /auth/logout', () async {
      adapter.handler = (_) async => ResponseBody.fromString('', 204);

      await dataSource.logout('refresh-token');

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/auth/logout');
      expect(request.data, {'refreshToken': 'refresh-token'});
      expect(request.extra[AuthInterceptor.skipAuthKey], isTrue);
    });

    test('throws DioException when the server is unreachable', () async {
      adapter.handler = (options) async => throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );

      await expectLater(
        dataSource.logout('refresh-token'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
