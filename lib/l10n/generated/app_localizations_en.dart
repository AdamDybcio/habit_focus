// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Habit Focus';

  @override
  String get homeTagline => 'Build habits. Stay focused.';

  @override
  String get homeLogout => 'Log out';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in to continue';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get validationEmailRequired => 'Enter your email';

  @override
  String get validationEmailInvalid => 'Enter a valid email address';

  @override
  String get validationPasswordRequired => 'Enter your password';

  @override
  String get loginErrorInvalidCredentials => 'Incorrect email or password';

  @override
  String get loginErrorNetwork =>
      'Cannot reach the server. Check your connection and try again.';

  @override
  String get loginErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Start building habits that last';

  @override
  String get registerSubmit => 'Create account';

  @override
  String get registerHaveAccount => 'I already have an account';

  @override
  String get validationPasswordTooShort => 'Use at least 10 characters';

  @override
  String get validationPasswordTooLong => 'Use at most 128 characters';

  @override
  String get registerErrorEmailTaken => 'This email is already registered';

  @override
  String get registerErrorRejected =>
      'Check your email and password and try again';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Wait a moment and try again.';
}
