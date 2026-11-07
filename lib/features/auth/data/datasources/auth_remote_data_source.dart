import 'package:dio/dio.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/network/api_paths.dart';
import 'package:habit_focus/core/network/auth_interceptor.dart';
import 'package:habit_focus/core/network/auth_tokens_parser.dart';

/// Talks to the authentication endpoints of the backend.
///
/// Methods throw `DioException` on HTTP or network errors and
/// `FormatException` on a malformed response. The repository maps them.
class AuthRemoteDataSource {
  /// Creates the data source on top of the shared [_dio] client.
  const new(this._dio);

  final Dio _dio;

  /// `POST /auth/login`. Returns the issued token pair.
  Future<AuthTokens> login({required String email, required String password}) {
    return _credentials(ApiPaths.login, email: email, password: password);
  }

  /// `POST /auth/register`. Creates the account and returns its first token
  /// pair, so the user is logged in right away.
  Future<AuthTokens> register({
    required String email,
    required String password,
  }) {
    return _credentials(ApiPaths.register, email: email, password: password);
  }

  /// `POST /auth/logout`. Revokes the session of [refreshToken] on the server.
  ///
  /// The endpoint answers `204` also for unknown tokens.
  Future<void> logout(String refreshToken) async {
    await _dio.post<Object?>(
      ApiPaths.logout,
      data: <String, String>{'refreshToken': refreshToken},
      options: _publicOptions(),
    );
  }

  Future<AuthTokens> _credentials(
    String path, {
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Object?>(
      path,
      data: <String, String>{'email': email, 'password': password},
      options: _publicOptions(),
    );
    return parseAuthTokens(response.data);
  }

  /// These endpoints are public: a 401 from them means rejected credentials or
  /// tokens, not an expired session, so it must not trigger a token refresh.
  Options _publicOptions() {
    return Options(extra: <String, Object?>{AuthInterceptor.skipAuthKey: true});
  }
}
