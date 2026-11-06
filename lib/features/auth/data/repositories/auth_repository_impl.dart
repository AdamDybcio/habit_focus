import 'package:dio/dio.dart';
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
  }) async {
    try {
      final tokens = await _remote.login(email: email, password: password);
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
      await _tokenStorage.clear();
      return const Success<void>(null);
    } on LocalStorageException catch (e) {
      return Failure<void>(StorageFailure(e.message));
    }
  }
}
