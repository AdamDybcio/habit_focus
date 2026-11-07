import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/core/theme/app_theme.dart';
import 'package:habit_focus/features/auth/presentation/bloc/register_cubit.dart';
import 'package:habit_focus/features/auth/presentation/bloc/register_state.dart';
import 'package:habit_focus/features/auth/presentation/pages/register_page.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegisterCubit extends MockCubit<RegisterState>
    implements RegisterCubit;

Widget _buildSubject(
  RegisterCubit cubit, {
  VoidCallback? onRegistered,
  VoidCallback? onHaveAccount,
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
    home: BlocProvider<RegisterCubit>.value(
      value: cubit,
      child: RegisterPage(
        onRegistered: onRegistered ?? () {},
        onHaveAccount: onHaveAccount ?? () {},
      ),
    ),
  );
}

void main() {
  late _MockRegisterCubit cubit;

  void stubState(RegisterState state, {Stream<RegisterState>? changes}) {
    whenListen(
      cubit,
      changes ?? const Stream<RegisterState>.empty(),
      initialState: state,
    );
  }

  setUp(() {
    cubit = _MockRegisterCubit();
    stubState(const RegisterState());
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
    String password = 'long enough password',
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
  }

  void verifyNotSubmitted() {
    verifyNever(
      () => cubit.submit(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  }

  group('RegisterPage', () {
    testWidgets('shows the title and both fields', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows Polish texts', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit, locale: const Locale('pl')));

      expect(find.text('Załóż konto'), findsOneWidget);
      expect(find.text('Utwórz konto'), findsOneWidget);
    });

    testWidgets('renders in the dark theme', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit, theme: AppTheme.dark()));

      expect(find.text('Create your account'), findsOneWidget);
    });

    testWidgets('empty form shows validation errors and does not submit', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      verifyNotSubmitted();
    });

    testWidgets('too short password is rejected', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await fillForm(tester, password: 'short');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Use at least 10 characters'), findsOneWidget);
      verifyNotSubmitted();
    });

    testWidgets('invalid email is rejected', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await fillForm(tester, email: 'not-an-email');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      verifyNotSubmitted();
    });

    testWidgets('valid form submits the typed values', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await fillForm(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      verify(
        () => cubit.submit(
          email: 'user@example.com',
          password: 'long enough password',
        ),
      ).called(1);
    });

    testWidgets('disables the button and shows progress while submitting', (
      tester,
    ) async {
      stubState(const RegisterState(status: RegisterStatus.submitting));

      await tester.pumpWidget(_buildSubject(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('shows a message when the email is already taken', (
      tester,
    ) async {
      stubState(
        const RegisterState(
          status: RegisterStatus.failure,
          failure: ConflictFailure('taken'),
        ),
      );

      await tester.pumpWidget(_buildSubject(cubit));

      expect(find.text('This email is already registered'), findsOneWidget);
    });

    testWidgets('shows a message for network problems', (tester) async {
      stubState(
        const RegisterState(
          status: RegisterStatus.failure,
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

    testWidgets('link opens the login screen', (tester) async {
      var opened = 0;

      await tester.pumpWidget(
        _buildSubject(cubit, onHaveAccount: () => opened++),
      );
      await tester.ensureVisible(find.text('I already have an account'));
      await tester.tap(find.text('I already have an account'));

      expect(opened, 1);
    });

    testWidgets('calls onRegistered once after the account was created', (
      tester,
    ) async {
      var registered = 0;
      stubState(
        const RegisterState(),
        changes: Stream.fromIterable(const [
          RegisterState(status: RegisterStatus.submitting),
          RegisterState(status: RegisterStatus.success),
        ]),
      );

      await tester.pumpWidget(
        _buildSubject(cubit, onRegistered: () => registered++),
      );
      await tester.pump();

      expect(registered, 1);
    });
  });
}
