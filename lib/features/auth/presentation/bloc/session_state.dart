import 'package:equatable/equatable.dart';

/// Whether the user currently has a session.
sealed class SessionState extends Equatable {
  /// Creates a session state.
  const new();

  @override
  List<Object?> get props => const [];
}

/// The stored session has not been checked yet (app start).
final class SessionUnknown extends SessionState {
  /// Creates the state.
  const new();
}

/// The user is logged in.
final class SessionAuthenticated extends SessionState {
  /// Creates the state.
  const new();
}

/// The user must log in.
final class SessionUnauthenticated extends SessionState {
  /// Creates the state.
  const new();
}
