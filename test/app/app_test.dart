import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/app/app.dart';
import 'package:habit_focus/app/router/app_router.dart';
import 'package:habit_focus/core/auth/session_events.dart';
import 'package:habit_focus/core/config/app_config.dart';
import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/domain/usecases/check_session_use_case.dart';
import 'package:habit_focus/features/auth/domain/usecases/logout_use_case.dart';
import 'package:habit_focus/features/auth/presentation/bloc/session_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockCheckSessionUseCase extends Mock implements CheckSessionUseCase;

class MockLogoutUseCase extends Mock implements LogoutUseCase;

void main() {
  late MockCheckSessionUseCase checkSessionUseCase;
  late MockLogoutUseCase logoutUseCase;
  late SessionEvents sessionEvents;
  late SessionCubit session;

  setUp(() {
    checkSessionUseCase = MockCheckSessionUseCase();
    logoutUseCase = MockLogoutUseCase();
    sessionEvents = SessionEvents();

    when(() => checkSessionUseCase()).thenAnswer((_) async => true);
    when(() => logoutUseCase())
        .thenAnswer((_) async => const Success<void>(null));

    session = SessionCubit(checkSessionUseCase, logoutUseCase, sessionEvents);
  });

  tearDown(() async {
    await session.close();
  });

  testWidgets('App shows the localized home page', (tester) async {
    final config = AppConfig.parse(
      flavor: 'prod',
      apiBaseUrl: 'https://api.example.com/api',
    );

    await session.start();

    await tester.pumpWidget(App(router: createRouter(config, session)));

    await tester.pumpAndSettle();

    expect(find.text('Habit Focus'), findsOneWidget);
    expect(find.text('Build habits. Stay focused.'), findsOneWidget);
  });
}
