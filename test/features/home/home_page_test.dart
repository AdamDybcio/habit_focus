import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/config/flavor.dart';
import 'package:habit_focus/core/theme/app_theme.dart';
import 'package:habit_focus/features/home/presentation/pages/home_page.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

Widget _buildSubject({
  required Flavor flavor,
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
    home: HomePage(flavor: flavor),
  );
}

void main() {
  group('HomePage', () {
    testWidgets('shows the English title and tagline', (tester) async {
      await tester.pumpWidget(_buildSubject(flavor: Flavor.prod));

      expect(find.text('Habit Focus'), findsOneWidget);
      expect(find.text('Build habits. Stay focused.'), findsOneWidget);
    });

    testWidgets('shows the Polish tagline', (tester) async {
      await tester.pumpWidget(
        _buildSubject(flavor: Flavor.prod, locale: const Locale('pl')),
      );

      expect(find.text('Buduj nawyki. Utrzymaj skupienie.'), findsOneWidget);
    });

    testWidgets('shows a badge outside production', (tester) async {
      await tester.pumpWidget(_buildSubject(flavor: Flavor.dev));

      expect(find.text('DEV'), findsOneWidget);
    });

    testWidgets('hides the badge in production', (tester) async {
      await tester.pumpWidget(_buildSubject(flavor: Flavor.prod));

      expect(find.text('PROD'), findsNothing);
    });

    testWidgets('renders with the dark theme', (tester) async {
      await tester.pumpWidget(
        _buildSubject(flavor: Flavor.staging, theme: AppTheme.dark()),
      );

      expect(find.text('STAGING'), findsOneWidget);
    });
  });
}
