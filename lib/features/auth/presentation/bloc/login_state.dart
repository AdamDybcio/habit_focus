import 'package:equatable/equatable.dart';
import 'package:habit_focus/core/error/app_failure.dart';

/// Progress of a login attempt.
enum LoginStatus {
  /// Nothing has been submitted yet.
  idle,

  /// A request is in flight.
  submitting,

  /// The login succeeded.
  success,

  /// The login failed; see [LoginState.failure].
  failure,
}

/// State of the login form.
class LoginState extends Equatable {
  /// Creates a state.
  const new({this.status = LoginStatus.idle, this.failure});

  /// Where the login attempt currently is.
  final LoginStatus status;

  /// Why the last attempt failed. Set only when [status] is
  /// [LoginStatus.failure].
  final AppFailure? failure;

  /// Whether a request is in flight.
  bool get isSubmitting => status == LoginStatus.submitting;

  @override
  List<Object?> get props => [status, failure];
}
