import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';

/// Turns a login [failure] into a message the user can act on.
String loginFailureMessage(AppLocalizations l10n, AppFailure failure) {
  return switch (failure) {
    UnauthorizedFailure() => l10n.loginErrorInvalidCredentials,
    TooManyRequestsFailure() => l10n.errorTooManyRequests,
    NetworkFailure() => l10n.loginErrorNetwork,
    _ => l10n.loginErrorUnknown,
  };
}
