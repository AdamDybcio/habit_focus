import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/features/auth/presentation/validators/auth_validators.dart';
import 'package:habit_focus/features/auth/presentation/validators/login_failure_message.dart';
import 'package:habit_focus/features/auth/presentation/validators/register_failure_message.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations pl;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    pl = await AppLocalizations.delegate.load(const Locale('pl'));
  });

  group('AuthValidators.email', () {
    test('accepts a normal address, ignoring surrounding spaces', () {
      expect(AuthValidators.email(en, 'user@example.com'), isNull);
      expect(AuthValidators.email(en, '  user@example.com '), isNull);
    });

    test('requires a value', () {
      expect(AuthValidators.email(en, null), en.validationEmailRequired);
      expect(AuthValidators.email(en, '   '), en.validationEmailRequired);
    });

    test('rejects malformed addresses', () {
      for (final value in ['user', 'user@', '@example.com', 'a b@c.pl']) {
        expect(
          AuthValidators.email(en, value),
          en.validationEmailInvalid,
          reason: value,
        );
      }
    });

    test('messages are localized', () {
      expect(AuthValidators.email(pl, ''), pl.validationEmailRequired);
      expect(pl.validationEmailRequired, isNot(en.validationEmailRequired));
    });
  });

  group('AuthValidators.password', () {
    test('requires a value', () {
      expect(AuthValidators.password(en, null), en.validationPasswordRequired);
      expect(AuthValidators.password(en, ''), en.validationPasswordRequired);
    });

    test('accepts any non-empty value, including spaces', () {
      expect(AuthValidators.password(en, ' '), isNull);
      expect(AuthValidators.password(en, 'secret'), isNull);
    });
  });

  group('AuthValidators.newPassword', () {
    test('requires a value', () {
      expect(
        AuthValidators.newPassword(en, null),
        en.validationPasswordRequired,
      );
      expect(AuthValidators.newPassword(en, ''), en.validationPasswordRequired);
    });

    test('rejects passwords shorter than the backend minimum', () {
      expect(
        AuthValidators.newPassword(en, 'a' * 9),
        en.validationPasswordTooShort,
      );
    });

    test('rejects passwords longer than the backend maximum', () {
      expect(
        AuthValidators.newPassword(en, 'a' * 129),
        en.validationPasswordTooLong,
      );
    });

    test('accepts the limits themselves', () {
      expect(AuthValidators.newPassword(en, 'a' * 10), isNull);
      expect(AuthValidators.newPassword(en, 'a' * 128), isNull);
    });
  });

  group('registerFailureMessage', () {
    test('explains a taken email', () {
      expect(
        registerFailureMessage(en, const ConflictFailure('x')),
        en.registerErrorEmailTaken,
      );
    });

    test('explains rejected input', () {
      expect(
        registerFailureMessage(en, const ValidationFailure('x')),
        en.registerErrorRejected,
      );
    });

    test('explains rate limiting', () {
      expect(
        registerFailureMessage(en, const TooManyRequestsFailure('x')),
        en.errorTooManyRequests,
      );
    });

    test('explains network problems and falls back to a generic message', () {
      expect(
        registerFailureMessage(en, const NetworkFailure('x')),
        en.loginErrorNetwork,
      );
      expect(
        registerFailureMessage(en, const UnknownFailure('x')),
        en.loginErrorUnknown,
      );
    });
  });

  group('loginFailureMessage', () {
    test('explains rate limiting', () {
      expect(
        loginFailureMessage(en, const TooManyRequestsFailure('x')),
        en.errorTooManyRequests,
      );
    });

    test('explains wrong credentials', () {
      expect(
        loginFailureMessage(en, const UnauthorizedFailure('x')),
        en.loginErrorInvalidCredentials,
      );
    });

    test('explains network problems', () {
      expect(
        loginFailureMessage(en, const NetworkFailure('x')),
        en.loginErrorNetwork,
      );
    });

    test('falls back to a generic message', () {
      expect(
        loginFailureMessage(en, const UnknownFailure('x')),
        en.loginErrorUnknown,
      );
      expect(
        loginFailureMessage(en, const StorageFailure('x')),
        en.loginErrorUnknown,
      );
    });
  });
}
