import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/auth/session_events.dart';
import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/domain/usecases/check_session_use_case.dart';
import 'package:habit_focus/features/auth/domain/usecases/logout_use_case.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_cubit.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockCheckSession extends Mock implements CheckSessionUseCase;

class _MockLogout extends Mock implements LogoutUseCase;

void main() {
  late _MockCheckSession checkSession;
  late _MockLogout logout;
  late SessionEvents events;

  setUp(() {
    checkSession = _MockCheckSession();
    logout = _MockLogout();
    events = SessionEvents();
    when(() => logout()).thenAnswer((_) async => const Success<void>(null));
  });

  tearDown(() => events.dispose());

  SessionCubit build() => SessionCubit(checkSession, logout, events);

  test('starts in the unknown state', () async {
    final cubit = build();

    expect(cubit.state, const SessionUnknown());
    await cubit.close();
  });

  blocTest<SessionCubit, SessionState>(
    'start emits authenticated when a session is stored',
    setUp: () => when(() => checkSession()).thenAnswer((_) async => true),
    build: build,
    act: (cubit) => cubit.start(),
    expect: () => const [SessionAuthenticated()],
  );

  blocTest<SessionCubit, SessionState>(
    'start emits unauthenticated when nothing is stored',
    setUp: () => when(() => checkSession()).thenAnswer((_) async => false),
    build: build,
    act: (cubit) => cubit.start(),
    expect: () => const [SessionUnauthenticated()],
  );

  blocTest<SessionCubit, SessionState>(
    'loggedIn emits authenticated',
    build: build,
    seed: () => const SessionUnauthenticated(),
    act: (cubit) => cubit.loggedIn(),
    expect: () => const [SessionAuthenticated()],
  );

  blocTest<SessionCubit, SessionState>(
    'logout clears the session and emits unauthenticated',
    build: build,
    seed: () => const SessionAuthenticated(),
    act: (cubit) => cubit.logout(),
    expect: () => const [SessionUnauthenticated()],
    verify: (_) => verify(() => logout()).called(1),
  );

  blocTest<SessionCubit, SessionState>(
    'an expired session reported by the network layer logs the user out',
    build: build,
    seed: () => const SessionAuthenticated(),
    act: (_) => events.notifyExpired(),
    wait: const Duration(milliseconds: 10),
    expect: () => const [SessionUnauthenticated()],
  );

  test('stops listening to session events after close', () async {
    final cubit = build();
    await cubit.close();

    expect(events.notifyExpired, returnsNormally);
  });
}
