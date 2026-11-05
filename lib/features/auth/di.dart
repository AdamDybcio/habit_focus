import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:habit_focus/core/auth/session_events.dart';
import 'package:habit_focus/core/auth/token_storage.dart';
import 'package:habit_focus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:habit_focus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:habit_focus/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_focus/features/auth/domain/usecases/check_session_use_case.dart';
import 'package:habit_focus/features/auth/domain/usecases/login_use_case.dart';
import 'package:habit_focus/features/auth/domain/usecases/logout_use_case.dart';
import 'package:habit_focus/features/auth/presentation/bloc/login_cubit.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_cubit.dart';

/// Registers the authentication feature in [getIt].
///
/// Expects `Dio`, `TokenStorage` and `SessionEvents` to be registered.
void registerAuthDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<Dio>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<TokenStorage>(),
      ),
    )
    ..registerFactory<LoginUseCase>(() => LoginUseCase(getIt<AuthRepository>()))
    ..registerFactory<LogoutUseCase>(
      () => LogoutUseCase(getIt<AuthRepository>()),
    )
    ..registerFactory<CheckSessionUseCase>(
      () => CheckSessionUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<SessionCubit>(
      () => SessionCubit(
        getIt<CheckSessionUseCase>(),
        getIt<LogoutUseCase>(),
        getIt<SessionEvents>(),
      ),
      dispose: (cubit) => cubit.close(),
    )
    ..registerFactory<LoginCubit>(() => LoginCubit(getIt<LoginUseCase>()));
}
