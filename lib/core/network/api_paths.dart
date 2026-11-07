/// Paths of the backend API, relative to `API_BASE_URL`.
abstract final class ApiPaths {
  /// `POST` with email and password, answers with a token pair.
  static const String login = '/auth/login';

  /// `POST` with email and password, creates an account and answers with a
  /// token pair.
  static const String register = '/auth/register';

  /// `POST` with a refresh token, answers with a new token pair.
  static const String refresh = '/auth/refresh';

  /// `POST` with a refresh token, ends the session on the server.
  static const String logout = '/auth/logout';
}
