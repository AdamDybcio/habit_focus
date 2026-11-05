import 'package:dio/dio.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/network/api_paths.dart';
import 'package:habit_focus/core/network/auth_tokens_parser.dart';
import 'package:habit_focus/core/network/token_refresher.dart';

/// [TokenRefresher] that calls `POST /auth/refresh`.
///
/// It must use a [Dio] without the auth interceptor. Otherwise a rejected
/// refresh would trigger another refresh and loop.
class DioTokenRefresher implements TokenRefresher {
  /// Creates a refresher that sends requests with [_dio].
  const new(this._dio);

  final Dio _dio;

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final response = await _dio.post<Object?>(
      ApiPaths.refresh,
      data: <String, String>{'refreshToken': refreshToken},
    );
    return parseAuthTokens(response.data);
  }
}
