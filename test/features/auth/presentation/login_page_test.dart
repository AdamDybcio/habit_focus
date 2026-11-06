import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/core/theme/app_theme.dart';
import 'package:habit_focus/features/auth/presentation/bloc/login_cubit.dart';
import 'package:habit_focus/features/auth/presentation/bloc/login_state.dart';
import 'package:habit_focus/features/auth/presentation/pages/login_page.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginCubit extends MockCubit<LoginState> implements LoginCubit;

Widget _buildSubject(
  LoginCubit cubit, {
  VoidCallback? onLoggedIn,
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light(),
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<LoginCubit>.value(
      value: cubit,
      child: LoginPage(onLoggedIn: onLoggedIn ?? () {}),
    ),
  );
}

void main() {
  late _MockLoginCubit cubit;

  void stubState(LoginState state, {Stream<LoginState>? changes}) {
    whenListen(
      cubit,
      changes ?? const Stream<LoginState>.empty(),
      initialState: state,
    );
  }

  setUp(() {
    cubit = _MockLoginCubit();
    stubState(const LoginState());
    when(
      () => cubit.submit(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> fillForm(
    WidgetTester tester, {
    String email = 'user@example.com',
    String password = 'secret',
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
  }

  group('LoginPage', () {
    testWidgets('shows the title and both fields', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows Polish texts', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit, locale: const Locale('pl')));

      expect(find.text('Witaj ponownie'), findsOneWidget);
      expect(find.text('Zaloguj się'), findsOneWidget);
    });

    testWidgets('renders in the dark theme', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit, theme: AppTheme.dark()));

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('empty form shows validation errors and does not submit', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      verifyNever(
        () => cubit.submit(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('invalid email is rejected', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await fillForm(tester, email: 'not-an-email');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      verifyNever(
        () => cubit.submit(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('valid form submits the typed values', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await fillForm(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      verify(() => cubit.submit(email: 'user@example.com', password: 'secret'))
          .called(1);
    });

    testWidgets('password can be revealed and hidden again', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));
      EditableText field() => tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        ),
      );

      expect(field().obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(field().obscureText, isFalse);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(field().obscureText, isTrue);
    });

    testWidgets('disables the button and shows progress while submitting', (
      tester,
    ) async {
      stubState(const LoginState(status: LoginStatus.submitting));

      await tester.pumpWidget(_buildSubject(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('shows a message for wrong credentials', (tester) async {
      stubState(
        const LoginState(
          status: LoginStatus.failure,
          failure: UnauthorizedFailure('Unauthorized'),
        ),
      );

      await tester.pumpWidget(_buildSubject(cubit));

      expect(find.text('Incorrect email or password'), findsOneWidget);
    });

    testWidgets('shows a message for network problems', (tester) async {
      stubState(
        const LoginState(
          status: LoginStatus.failure,
          failure: NetworkFailure('offline'),
        ),
      );

      await tester.pumpWidget(_buildSubject(cubit));

      expect(
        find.text(
          'Cannot reach the server. '
          'Check your connection and try again.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls onLoggedIn once after a successful login', (
      tester,
    ) async {
      var loggedIn = 0;
      stubState(
        const LoginState(),
        changes: Stream.fromIterable(const [
          LoginState(status: LoginStatus.submitting),
          LoginState(status: LoginStatus.success),
        ]),
      );

      await tester.pumpWidget(
        _buildSubject(cubit, onLoggedIn: () => loggedIn++),
      );
      await tester.pump();

      expect(loggedIn, 1);
    });
  });
}
