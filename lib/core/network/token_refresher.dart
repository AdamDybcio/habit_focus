import 'package:habit_focus/core/auth/auth_tokens.dart';

/// Exchanges a refresh token for a new token pair.
///
/// Implementations throw `DioException` on HTTP or network errors and
/// `FormatException` when the response is malformed.
abstract interface class TokenRefresher {
  /// Calls the backend with [refreshToken] and returns the new pair.
  Future<AuthTokens> refresh(String refreshToken);
}
