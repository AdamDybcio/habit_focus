import 'package:habit_focus/l10n/generated/app_localizations.dart';

/// Form validators for the authentication screens.
///
/// Each returns a localized message, or `null` when the value is valid. The
/// backend validates again: these only give quick feedback.
abstract final class AuthValidators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Validates an email address.
  static String? email(AppLocalizations l10n, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return l10n.validationEmailRequired;
    }
    if (!_email.hasMatch(text)) {
      return l10n.validationEmailInvalid;
    }
    return null;
  }

  /// Validates that a password was entered.
  static String? password(AppLocalizations l10n, String? value) {
    if (value == null || value.isEmpty) {
      return l10n.validationPasswordRequired;
    }
    return null;
  }
}
