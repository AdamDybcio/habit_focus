import 'package:habit_focus/core/auth/auth_tokens.dart';

/// Persists the session tokens in secure storage.
///
/// Implementations throw `LocalStorageException` when the platform storage
/// cannot be read or written.
abstract interface class TokenStorage {
  /// Returns the stored tokens, or `null` when there is no session.
  Future<AuthTokens?> read();

  /// Replaces the stored tokens with [tokens].
  Future<void> write(AuthTokens tokens);

  /// Removes the stored tokens (logout or expired session).
  Future<void> clear();
}
