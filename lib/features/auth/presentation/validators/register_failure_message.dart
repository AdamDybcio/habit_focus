import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';

/// Turns a registration [failure] into a message the user can act on.
String registerFailureMessage(AppLocalizations l10n, AppFailure failure) {
  return switch (failure) {
    ConflictFailure() => l10n.registerErrorEmailTaken,
    ValidationFailure() => l10n.registerErrorRejected,
    TooManyRequestsFailure() => l10n.errorTooManyRequests,
    NetworkFailure() => l10n.loginErrorNetwork,
    _ => l10n.loginErrorUnknown,
  };
}
