import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/network/auth_tokens_parser.dart';

void main() {
  group('parseAuthTokens', () {
    test('parses a valid response', () {
      final tokens = parseAuthTokens({'accessToken': 'a', 'refreshToken': 'r'});

      expect(tokens, const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    });

    test('ignores unknown fields', () {
      final tokens = parseAuthTokens({
        'accessToken': 'a',
        'refreshToken': 'r',
        'expiresIn': 900,
      });

      expect(tokens.accessToken, 'a');
    });

    test('rejects a body that is not an object', () {
      expect(() => parseAuthTokens(null), throwsFormatException);
      expect(() => parseAuthTokens('text'), throwsFormatException);
      expect(() => parseAuthTokens(<Object?>[]), throwsFormatException);
    });

    test('rejects missing tokens', () {
      expect(
        () => parseAuthTokens({'accessToken': 'a'}),
        throwsFormatException,
      );
      expect(
        () => parseAuthTokens({'refreshToken': 'r'}),
        throwsFormatException,
      );
    });

    test('rejects empty or non-string tokens', () {
      expect(
        () => parseAuthTokens({'accessToken': '', 'refreshToken': 'r'}),
        throwsFormatException,
      );
      expect(
        () => parseAuthTokens({'accessToken': 'a', 'refreshToken': 5}),
        throwsFormatException,
      );
    });

    test('error message never contains the token values', () {
      try {
        parseAuthTokens({'accessToken': 'secret-value', 'refreshToken': 1});
        fail('expected a FormatException');
      } on FormatException catch (e) {
        expect(e.message, isNot(contains('secret-value')));
      }
    });
  });
}
