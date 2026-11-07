import 'package:equatable/equatable.dart';

/// Base type of every typed failure that crosses a layer boundary.
sealed class AppFailure extends Equatable {
  /// Creates a failure with a developer-facing [message].
  const new(this.message);

  /// Developer-facing description. Never show it to users directly.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// A network or server communication problem.
final class NetworkFailure extends AppFailure {
  /// Creates a [NetworkFailure].
  const new(super.message);
}

/// The session is missing, expired or rejected by the server.
final class UnauthorizedFailure extends AppFailure {
  /// Creates an [UnauthorizedFailure].
  const new(super.message);
}

/// The request conflicts with existing data, for example an email address
/// that is already registered.
final class ConflictFailure extends AppFailure {
  /// Creates a [ConflictFailure].
  const new(super.message);
}

/// The server asked the client to slow down (rate limiting).
final class TooManyRequestsFailure extends AppFailure {
  /// Creates a [TooManyRequestsFailure].
  const new(super.message);
}

/// Reading from or writing to local storage failed.
final class StorageFailure extends AppFailure {
  /// Creates a [StorageFailure].
  const new(super.message);
}

/// Input or data did not pass validation.
final class ValidationFailure extends AppFailure {
  /// Creates a [ValidationFailure].
  const new(super.message);
}

/// Anything that does not fit another failure type.
final class UnknownFailure extends AppFailure {
  /// Creates an [UnknownFailure].
  const new(super.message);
}
