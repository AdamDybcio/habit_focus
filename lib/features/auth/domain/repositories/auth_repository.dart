import 'package:habit_focus/core/result/result.dart';

/// Authentication and session handling.
abstract interface class AuthRepository {
  /// Logs in and stores the issued tokens.
  ///
  /// Fails with `UnauthorizedFailure` for wrong credentials and with
  /// `NetworkFailure` when the server cannot be reached.
  Future<Result<void>> login({required String email, required String password});

  /// Creates an account, logs in and stores the issued tokens.
  ///
  /// Fails with `ConflictFailure` when the email is already registered and
  /// with `ValidationFailure` when the server rejects the input.
  Future<Result<void>> register({
    required String email,
    required String password,
  });

  /// Whether tokens of a previous session are stored on this device.
  Future<bool> hasSession();

  /// Ends the session: removes the stored tokens and asks the server to revoke
  /// the refresh token.
  ///
  /// The server call is best effort. Logging out works offline, the unused
  /// refresh token then simply expires on its own.
  Future<Result<void>> logout();
}
