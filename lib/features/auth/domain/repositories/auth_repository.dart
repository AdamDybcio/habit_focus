import 'package:habit_focus/core/result/result.dart';

/// Authentication and session handling.
abstract interface class AuthRepository {
  /// Logs in and stores the issued tokens.
  ///
  /// Fails with `UnauthorizedFailure` for wrong credentials and with
  /// `NetworkFailure` when the server cannot be reached.
  Future<Result<void>> login({required String email, required String password});

  /// Whether tokens of a previous session are stored on this device.
  Future<bool> hasSession();

  /// Removes the stored tokens.
  Future<Result<void>> logout();
}
