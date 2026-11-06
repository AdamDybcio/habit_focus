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
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Object?>(
      ApiPaths.login,
      data: <String, String>{'email': email, 'password': password},
      // Login is public: a 401 here means wrong credentials, not an expired
      // session, so it must not trigger a token refresh.
      options: Options(
        extra: <String, Object?>{AuthInterceptor.skipAuthKey: true},
      ),
    );
    return parseAuthTokens(response.data);
  }
}
