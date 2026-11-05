import 'package:go_router/go_router.dart';
import 'package:habit_focus/core/theme/app_theme.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Root widget: wires theme, localization and routing together.
class App extends StatelessWidget {
  /// Creates the app that navigates with [router].
  const new({required this.router, super.key});

  /// Router configuration of the app.
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
