// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Habit Focus';

  @override
  String get homeTagline => 'Buduj nawyki. Utrzymaj skupienie.';

  @override
  String get homeLogout => 'Wyloguj';

  @override
  String get loginTitle => 'Witaj ponownie';

  @override
  String get loginSubtitle => 'Zaloguj się, aby kontynuować';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Hasło';

  @override
  String get loginShowPassword => 'Pokaż hasło';

  @override
  String get loginHidePassword => 'Ukryj hasło';

  @override
  String get loginSubmit => 'Zaloguj się';

  @override
  String get validationEmailRequired => 'Podaj adres e-mail';

  @override
  String get validationEmailInvalid => 'Podaj poprawny adres e-mail';

  @override
  String get validationPasswordRequired => 'Podaj hasło';

  @override
  String get loginErrorInvalidCredentials => 'Nieprawidłowy e-mail lub hasło';

  @override
  String get loginErrorNetwork =>
      'Brak połączenia z serwerem. Sprawdź internet i spróbuj ponownie.';

  @override
  String get loginErrorUnknown => 'Coś poszło nie tak. Spróbuj ponownie.';
}
