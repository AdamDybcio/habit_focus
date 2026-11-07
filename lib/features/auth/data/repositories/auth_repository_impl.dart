import 'dart:async';

import 'package:dio/dio.dart';
import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/auth/token_storage.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/core/error/local_storage_exception.dart';
import 'package:habit_focus/core/network/dio_failure_mapper.dart';
import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:habit_focus/features/auth/domain/repositories/auth_repository.dart';

/// [AuthRepository] backed by the REST API and secure token storage.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository.
  const new(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) {
    return _authenticate(() => _remote.login(email: email, password: password));
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => _remote.register(email: email, password: password),
    );
  }

  @override
  Future<bool> hasSession() async {
    try {
      return await _tokenStorage.read() != null;
    } on LocalStorageException {
      return false;
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final tokens = await _readTokensOrNull();
      await _tokenStorage.clear();
      if (tokens != null) {
        unawaited(_revokeOnServer(tokens.refreshToken));
      }
      return const Success<void>(null);
    } on LocalStorageException catch (e) {
      return Failure<void>(StorageFailure(e.message));
    }
  }

  Future<Result<void>> _authenticate(
    Future<AuthTokens> Function() request,
  ) async {
    try {
      final tokens = await request();
      await _tokenStorage.write(tokens);
      return const Success<void>(null);
    } on DioException catch (e) {
      return Failure<void>(mapDioException(e));
    } on FormatException {
      return const Failure<void>(
        ValidationFailure('Unexpected response from the server'),
      );
    } on LocalStorageException catch (e) {
      return Failure<void>(StorageFailure(e.message));
    }
  }

  Future<AuthTokens?> _readTokensOrNull() async {
    try {
      return await _tokenStorage.read();
    } on LocalStorageException {
      // Unreadable tokens cannot be revoked, but they must still be cleared.
      return null;
    }
  }

  Future<void> _revokeOnServer(String refreshToken) async {
    try {
      await _remote.logout(refreshToken);
    } on DioException {
      // Best effort: the session is already gone on this device.
    }
  }
}
