import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/auth/secure_token_storage.dart';
import 'package:habit_focus/core/error/local_storage_exception.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage;

void main() {
  late _MockSecureStorage backend;
  late SecureTokenStorage storage;

  const tokens = AuthTokens(accessToken: 'a', refreshToken: 'r');

  setUp(() {
    backend = _MockSecureStorage();
    storage = SecureTokenStorage(backend);
  });

  group('read', () {
    test('returns the stored pair', () async {
      when(() => backend.read(key: 'access_token'))
          .thenAnswer((_) async => 'a');
      when(() => backend.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'r');

      expect(await storage.read(), tokens);
    });

    test('returns null when a token is missing', () async {
      when(() => backend.read(key: 'access_token'))
          .thenAnswer((_) async => 'a');
      when(() => backend.read(key: 'refresh_token'))
          .thenAnswer((_) async => null);

      expect(await storage.read(), isNull);
    });

    test('wraps platform errors without leaking details', () async {
      when(() => backend.read(key: any(named: 'key')))
          .thenThrow(PlatformException(code: 'keystore', message: 'secret'));

      await expectLater(
        storage.read(),
        throwsA(
          isA<LocalStorageException>().having(
            (e) => e.message,
            'message',
            isNot(contains('secret')),
          ),
        ),
      );
    });
  });

  group('write', () {
    test('stores both tokens under separate keys', () async {
      when(
        () => backend.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await storage.write(tokens);

      verify(() => backend.write(key: 'access_token', value: 'a')).called(1);
      verify(() => backend.write(key: 'refresh_token', value: 'r')).called(1);
    });

    test('wraps platform errors', () async {
      when(
        () => backend.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(PlatformException(code: 'keystore'));

      await expectLater(
        storage.write(tokens),
        throwsA(isA<LocalStorageException>()),
      );
    });
  });

  group('clear', () {
    test('deletes both tokens', () async {
      when(() => backend.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await storage.clear();

      verify(() => backend.delete(key: 'access_token')).called(1);
      verify(() => backend.delete(key: 'refresh_token')).called(1);
    });

    test('wraps platform errors', () async {
      when(() => backend.delete(key: any(named: 'key')))
          .thenThrow(PlatformException(code: 'keystore'));

      await expectLater(storage.clear(), throwsA(isA<LocalStorageException>()));
    });
  });
}
