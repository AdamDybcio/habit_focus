import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/domain/usecases/login_use_case.dart';
import 'package:habit_focus/features/auth/presentation/bloc/login_cubit.dart';
import 'package:habit_focus/features/auth/presentation/bloc/login_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase;

void main() {
  late _MockLoginUseCase login;

  setUp(() => login = _MockLoginUseCase());

  void stubLogin(Result<void> result) {
    when(
      () => login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => result);
  }

  blocTest<LoginCubit, LoginState>(
    'emits submitting and success when the login succeeds',
    setUp: () => stubLogin(const Success<void>(null)),
    build: () => LoginCubit(login),
    act: (cubit) => cubit.submit(email: 'a@b.pl', password: 'x'),
    expect: () => const [
      LoginState(status: LoginStatus.submitting),
      LoginState(status: LoginStatus.success),
    ],
    verify: (_) {
      verify(() => login(email: 'a@b.pl', password: 'x')).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'emits submitting and failure with the cause when the login fails',
    setUp: () =>
        stubLogin(const Failure<void>(UnauthorizedFailure('Unauthorized'))),
    build: () => LoginCubit(login),
    act: (cubit) => cubit.submit(email: 'a@b.pl', password: 'x'),
    expect: () => const [
      LoginState(status: LoginStatus.submitting),
      LoginState(
        status: LoginStatus.failure,
        failure: UnauthorizedFailure('Unauthorized'),
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'clears the previous failure when a new attempt starts',
    setUp: () => stubLogin(const Success<void>(null)),
    build: () => LoginCubit(login),
    seed: () => const LoginState(
      status: LoginStatus.failure,
      failure: NetworkFailure('offline'),
    ),
    act: (cubit) => cubit.submit(email: 'a@b.pl', password: 'x'),
    expect: () => const [
      LoginState(status: LoginStatus.submitting),
      LoginState(status: LoginStatus.success),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'ignores a second submit while one is running',
    setUp: () => stubLogin(const Success<void>(null)),
    build: () => LoginCubit(login),
    seed: () => const LoginState(status: LoginStatus.submitting),
    act: (cubit) => cubit.submit(email: 'a@b.pl', password: 'x'),
    expect: () => const <LoginState>[],
    verify: (_) {
      verifyNever(
        () => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    },
  );
}
