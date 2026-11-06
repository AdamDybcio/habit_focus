import 'package:dio/dio.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/auth/session_events.dart';
import 'package:habit_focus/core/auth/token_storage.dart';
import 'package:habit_focus/core/error/local_storage_exception.dart';
import 'package:habit_focus/core/network/token_refresher.dart';

/// Attaches the access token and recovers from expired access tokens.
///
/// On `401` it refreshes the token pair **once**, even when many requests fail
/// at the same time (they all wait for the same refresh), then retries the
/// failed request with the new token. When the backend rejects the refresh
/// token, the session is cleared and [SessionEvents.expired] is emitted.
/// A network error during refresh keeps the session: the user is not logged
/// out just because the connection dropped.
class AuthInterceptor extends Interceptor {
  /// Creates the interceptor.
  ///
  /// [_dio] is the client the interceptor is installed on; it retries
  /// requests.
  new(this._dio, this._tokenStorage, this._tokenRefresher, this._sessionEvents);

  /// `RequestOptions.extra` key that skips authentication handling, for
  /// public endpoints such as login.
  static const String skipAuthKey = 'skipAuth';

  static const String _retriedKey = 'authRetried';
  static const String _authorization = 'Authorization';
  static const Set<int> _rejectedStatuses = {400, 401, 403};

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final TokenRefresher _tokenRefresher;
  final SessionEvents _sessionEvents;

  Future<AuthTokens?>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] == true) {
      handler.next(options);
      return;
    }
    try {
      final tokens = await _tokenStorage.read();
      if (tokens != null) {
        options.headers[_authorization] = 'Bearer ${tokens.accessToken}';
      }
      handler.next(options);
    } on LocalStorageException catch (e) {
      handler.reject(DioException(requestOptions: options, error: e), true);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final isRecoverable =
        err.response?.statusCode == 401 &&
        request.extra[skipAuthKey] != true &&
        request.extra[_retriedKey] != true;
    if (!isRecoverable) {
      handler.next(err);
      return;
    }

    final fresh = await _freshTokensFor(request);
    if (fresh == null) {
      handler.next(err);
      return;
    }

    try {
      final response = await _dio.fetch<Object?>(
        request.copyWith(
          headers: <String, dynamic>{
            ...request.headers,
            _authorization: 'Bearer ${fresh.accessToken}',
          },
          extra: <String, dynamic>{...request.extra, _retriedKey: true},
        ),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Returns tokens that are newer than the ones [failed] was sent with, or
  /// `null` when no valid session is available.
  Future<AuthTokens?> _freshTokensFor(RequestOptions failed) async {
    final AuthTokens? stored;
    try {
      stored = await _tokenStorage.read();
    } on LocalStorageException {
      return null;
    }
    if (stored == null) {
      return null;
    }
    final sentWithStored =
        failed.headers[_authorization] == 'Bearer ${stored.accessToken}';
    if (!sentWithStored) {
      // Another request has already refreshed the tokens in the meantime.
      return stored;
    }
    return await _refreshOnce(stored.refreshToken);
  }

  Future<AuthTokens?> _refreshOnce(String refreshToken) {
    return _refreshing ??= _refresh(refreshToken).whenComplete(() {
      _refreshing = null;
    });
  }

  Future<AuthTokens?> _refresh(String refreshToken) async {
    try {
      final tokens = await _tokenRefresher.refresh(refreshToken);
      await _tokenStorage.write(tokens);
      return tokens;
    } on DioException catch (e) {
      if (_rejectedStatuses.contains(e.response?.statusCode)) {
        await _expireSession();
      }
      return null;
    } on FormatException {
      return null;
    } on LocalStorageException {
      return null;
    }
  }

  Future<void> _expireSession() async {
    try {
      await _tokenStorage.clear();
    } on LocalStorageException {
      // Still tell the app: it must show the login screen either way.
    }
    _sessionEvents.notifyExpired();
  }
}
