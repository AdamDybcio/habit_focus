import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/auth/token_storage.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/core/error/local_storage_exception.dart';
import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:habit_focus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource;

class _MockStorage extends Mock implements TokenStorage;

const _tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');

DioException _dioError({int? status, DioExceptionType? type}) {
  final options = RequestOptions(path: '/auth/login');
  return DioException(
    requestOptions: options,
    type: type ?? DioExceptionType.badResponse,
    response: status == null
        ? null
        : Response<Object?>(requestOptions: options, statusCode: status),
  );
}

Matcher _failureOf<T extends AppFailure>() {
  return isA<Failure<void>>().having((f) => f.error, 'error', isA<T>());
}

void main() {
  late _MockRemote remote;
  late _MockStorage storage;
  late AuthRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_tokens));

  setUp(() {
    remote = _MockRemote();
    storage = _MockStorage();
    repository = AuthRepositoryImpl(remote, storage);
  });

  void stubLogin(Future<AuthTokens> Function() answer) {
    when(
      () => remote.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => answer());
  }

  group('login', () {
    test('stores the tokens and succeeds', () async {
      stubLogin(() async => _tokens);
      when(() => storage.write(any())).thenAnswer((_) async {});

      final result = await repository.login(email: 'a@b.pl', password: 'x');

      expect(result.isSuccess, isTrue);
      verify(() => storage.write(_tokens)).called(1);
    });

    test('wrong credentials give UnauthorizedFailure, store nothing', () async {
      stubLogin(() async => throw _dioError(status: 401));

      final result = await repository.login(email: 'a@b.pl', password: 'x');

      expect(result, _failureOf<UnauthorizedFailure>());
      verifyNever(() => storage.write(any()));
    });

    test('no connection gives NetworkFailure', () async {
      stubLogin(
        () async => throw _dioError(type: DioExceptionType.connectionError),
      );

      final result = await repository.login(email: 'a@b.pl', password: 'x');

      expect(result, _failureOf<NetworkFailure>());
    });

    test('malformed response gives ValidationFailure', () async {
      stubLogin(() async => throw const FormatException('bad'));

      final result = await repository.login(email: 'a@b.pl', password: 'x');

      expect(result, _failureOf<ValidationFailure>());
      verifyNever(() => storage.write(any()));
    });

    test('storage error gives StorageFailure', () async {
      stubLogin(() async => _tokens);
      when(() => storage.write(any()))
          .thenThrow(const LocalStorageException('keystore'));

      final result = await repository.login(email: 'a@b.pl', password: 'x');

      expect(result, _failureOf<StorageFailure>());
    });
  });

  group('hasSession', () {
    test('is true when tokens are stored', () async {
      when(() => storage.read()).thenAnswer((_) async => _tokens);

      expect(await repository.hasSession(), isTrue);
    });

    test('is false when nothing is stored', () async {
      when(() => storage.read()).thenAnswer((_) async => null);

      expect(await repository.hasSession(), isFalse);
    });

    test('is false when storage cannot be read', () async {
      when(() => storage.read())
          .thenThrow(const LocalStorageException('keystore'));

      expect(await repository.hasSession(), isFalse);
    });
  });

  group('register', () {
    void stubRegister(Future<AuthTokens> Function() answer) {
      when(
        () => remote.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => answer());
    }

    test('stores the tokens and succeeds', () async {
      stubRegister(() async => _tokens);
      when(() => storage.write(any())).thenAnswer((_) async {});

      final result = await repository.register(email: 'a@b.pl', password: 'x');

      expect(result.isSuccess, isTrue);
      verify(() => storage.write(_tokens)).called(1);
    });

    test('taken email gives ConflictFailure, stores nothing', () async {
      stubRegister(() async => throw _dioError(status: 409));

      final result = await repository.register(email: 'a@b.pl', password: 'x');

      expect(result, _failureOf<ConflictFailure>());
      verifyNever(() => storage.write(any()));
    });

    test('rejected input gives ValidationFailure', () async {
      stubRegister(() async => throw _dioError(status: 422));

      final result = await repository.register(email: 'a@b.pl', password: 'x');

      expect(result, _failureOf<ValidationFailure>());
    });

    test('rate limit gives TooManyRequestsFailure', () async {
      stubRegister(() async => throw _dioError(status: 429));

      final result = await repository.register(email: 'a@b.pl', password: 'x');

      expect(result, _failureOf<TooManyRequestsFailure>());
    });

    test('storage error gives StorageFailure', () async {
      stubRegister(() async => _tokens);
      when(() => storage.write(any()))
          .thenThrow(const LocalStorageException('keystore'));

      final result = await repository.register(email: 'a@b.pl', password: 'x');

      expect(result, _failureOf<StorageFailure>());
    });
  });

  group('logout', () {
    setUp(() {
      when(() => storage.read()).thenAnswer((_) async => _tokens);
      when(() => storage.clear()).thenAnswer((_) async {});
      when(() => remote.logout(any())).thenAnswer((_) async {});
    });

    test('clears the stored tokens', () async {
      final result = await repository.logout();

      expect(result.isSuccess, isTrue);
      verify(() => storage.clear()).called(1);
    });

    test('revokes the refresh token on the server', () async {
      await repository.logout();
      await pumpEventQueue();

      verify(() => remote.logout('r')).called(1);
    });

    test('still succeeds when the server cannot be reached', () async {
      when(() => remote.logout(any())).thenAnswer(
        (_) async => throw _dioError(type: DioExceptionType.connectionError),
      );

      final result = await repository.logout();
      await pumpEventQueue();

      expect(result.isSuccess, isTrue);
      verify(() => storage.clear()).called(1);
    });

    test('does not call the server when there is no session', () async {
      when(() => storage.read()).thenAnswer((_) async => null);

      final result = await repository.logout();
      await pumpEventQueue();

      expect(result.isSuccess, isTrue);
      verifyNever(() => remote.logout(any()));
    });

    test('clears the tokens even when they cannot be read', () async {
      when(() => storage.read())
          .thenThrow(const LocalStorageException('keystore'));

      final result = await repository.logout();
      await pumpEventQueue();

      expect(result.isSuccess, isTrue);
      verify(() => storage.clear()).called(1);
      verifyNever(() => remote.logout(any()));
    });

    test('reports a storage failure when clearing fails', () async {
      when(() => storage.clear())
          .thenThrow(const LocalStorageException('keystore'));

      final result = await repository.logout();

      expect(result, _failureOf<StorageFailure>());
      verifyNever(() => remote.logout(any()));
    });
  });
}
