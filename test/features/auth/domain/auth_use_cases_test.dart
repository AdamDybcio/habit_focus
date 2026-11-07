import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/domain/repositories/auth_repository.dart';
import 'package:habit_focus/features/auth/domain/usecases/check_session_use_case.dart';
import 'package:habit_focus/features/auth/domain/usecases/login_use_case.dart';
import 'package:habit_focus/features/auth/domain/usecases/logout_use_case.dart';
import 'package:habit_focus/features/auth/domain/usecases/register_use_case.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements AuthRepository;

void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  group('LoginUseCase', () {
    test('trims the email and keeps the password as typed', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      final result = await LoginUseCase(repository)(
        email: '  user@example.com ',
        password: ' pass word ',
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => repository.login(
          email: 'user@example.com',
          password: ' pass word ',
        ),
      ).called(1);
    });

    test('passes a failure through unchanged', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Failure<void>(UnauthorizedFailure('nope')),
      );

      final result = await LoginUseCase(repository)(
        email: 'a@b.pl',
        password: 'x',
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('RegisterUseCase', () {
    test('trims the email and keeps the password as typed', () async {
      when(
        () => repository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Success<void>(null));

      final result = await RegisterUseCase(repository)(
        email: '  user@example.com ',
        password: ' long pass word ',
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => repository.register(
          email: 'user@example.com',
          password: ' long pass word ',
        ),
      ).called(1);
    });

    test('passes a failure through unchanged', () async {
      when(
        () => repository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Failure<void>(ConflictFailure('taken')));

      final result = await RegisterUseCase(repository)(
        email: 'a@b.pl',
        password: 'x',
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('LogoutUseCase', () {
    test('delegates to the repository', () async {
      when(() => repository.logout())
          .thenAnswer((_) async => const Success<void>(null));

      final result = await LogoutUseCase(repository)();

      expect(result.isSuccess, isTrue);
      verify(() => repository.logout()).called(1);
    });
  });

  group('CheckSessionUseCase', () {
    test('returns what the repository reports', () async {
      when(() => repository.hasSession()).thenAnswer((_) async => true);

      expect(await CheckSessionUseCase(repository)(), isTrue);
    });
  });
}
