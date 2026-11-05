import 'package:habit_focus/core/auth/auth_tokens.dart';

/// Converts a decoded JSON response of login or refresh into [AuthTokens].
///
/// Throws a [FormatException] when the body does not contain two non-empty
/// string fields `accessToken` and `refreshToken`. The message never includes
/// the body, so tokens cannot leak into logs.
AuthTokens parseAuthTokens(Object? json) {
  if (json is! Map<String, dynamic>) {
    throw const FormatException('Token response is not a JSON object');
  }
  final access = json['accessToken'];
  final refresh = json['refreshToken'];
  if (access is! String ||
      access.isEmpty ||
      refresh is! String ||
      refresh.isEmpty) {
    throw const FormatException('Token response is missing tokens');
  }
  return AuthTokens(accessToken: access, refreshToken: refresh);
}
