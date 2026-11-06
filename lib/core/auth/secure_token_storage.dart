import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/auth/token_storage.dart';
import 'package:habit_focus/core/error/local_storage_exception.dart';

/// [TokenStorage] backed by the iOS Keychain and Android Keystore.
///
/// Tokens must never be kept in plain files (`path_provider`), in
/// `shared_preferences` or in the database.
class SecureTokenStorage implements TokenStorage {
  /// Creates storage on top of [_storage].
  const new(this._storage);

  final FlutterSecureStorage _storage;

  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  @override
  Future<AuthTokens?> read() async {
    try {
      final access = await _storage.read(key: _accessKey);
      final refresh = await _storage.read(key: _refreshKey);
      if (access == null || refresh == null) {
        return null;
      }
      return AuthTokens(accessToken: access, refreshToken: refresh);
    } on PlatformException catch (e) {
      throw LocalStorageException('Cannot read tokens (${e.code})');
    }
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    try {
      await _storage.write(key: _accessKey, value: tokens.accessToken);
      await _storage.write(key: _refreshKey, value: tokens.refreshToken);
    } on PlatformException catch (e) {
      throw LocalStorageException('Cannot write tokens (${e.code})');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } on PlatformException catch (e) {
      throw LocalStorageException('Cannot clear tokens (${e.code})');
    }
  }
}
