import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/domain/usecases/register_use_case.dart';
import 'package:habit_focus/features/auth/presentation/bloc/register_cubit.dart';
import 'package:habit_focus/features/auth/presentation/bloc/register_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegisterUseCase extends Mock implements RegisterUseCase;

void main() {
  late _MockRegisterUseCase register;

  setUp(() => register = _MockRegisterUseCase());

  void stubRegister(Result<void> result) {
    when(
      () => register(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => result);
  }

  blocTest<RegisterCubit, RegisterState>(
    'emits submitting and success when the account is created',
    setUp: () => stubRegister(const Success<void>(null)),
    build: () => RegisterCubit(register),
    act: (cubit) => cubit.submit(email: 'a@b.pl', password: 'long password'),
    expect: () => const [
      RegisterState(status: RegisterStatus.submitting),
      RegisterState(status: RegisterStatus.success),
    ],
    verify: (_) {
      verify(() => register(email: 'a@b.pl', password: 'long password'))
          .called(1);
    },
  );

  blocTest<RegisterCubit, RegisterState>(
    'emits submitting and failure with the cause when registration fails',
    setUp: () => stubRegister(const Failure<void>(ConflictFailure('taken'))),
    build: () => RegisterCubit(register),
    act: (cubit) => cubit.submit(email: 'a@b.pl', password: 'long password'),
    expect: () => const [
      RegisterState(status: RegisterStatus.submitting),
      RegisterState(
        status: RegisterStatus.failure,
        failure: ConflictFailure('taken'),
      ),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'clears the previous failure when a new attempt starts',
    setUp: () => stubRegister(const Success<void>(null)),
    build: () => RegisterCubit(register),
    seed: () => const RegisterState(
      status: RegisterStatus.failure,
      failure: NetworkFailure('offline'),
    ),
    act: (cubit) => cubit.submit(email: 'a@b.pl', password: 'long password'),
    expect: () => const [
      RegisterState(status: RegisterStatus.submitting),
      RegisterState(status: RegisterStatus.success),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'ignores a second submit while one is running',
    setUp: () => stubRegister(const Success<void>(null)),
    build: () => RegisterCubit(register),
    seed: () => const RegisterState(status: RegisterStatus.submitting),
    act: (cubit) => cubit.submit(email: 'a@b.pl', password: 'long password'),
    expect: () => const <RegisterState>[],
    verify: (_) {
      verifyNever(
        () => register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    },
  );
}
