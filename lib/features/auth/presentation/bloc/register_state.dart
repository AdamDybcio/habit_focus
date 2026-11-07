import 'package:equatable/equatable.dart';
import 'package:habit_focus/core/error/app_failure.dart';

/// Progress of a registration attempt.
enum RegisterStatus {
  /// Nothing has been submitted yet.
  idle,

  /// A request is in flight.
  submitting,

  /// The account was created and the user is logged in.
  success,

  /// The registration failed; see [RegisterState.failure].
  failure,
}

/// State of the registration form.
class RegisterState extends Equatable {
  /// Creates a state.
  const new({this.status = RegisterStatus.idle, this.failure});

  /// Where the registration attempt currently is.
  final RegisterStatus status;

  /// Why the last attempt failed. Set only when [status] is
  /// [RegisterStatus.failure].
  final AppFailure? failure;

  /// Whether a request is in flight.
  bool get isSubmitting => status == RegisterStatus.submitting;

  @override
  List<Object?> get props => [status, failure];
}
