import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/app/app.dart';
import 'package:habit_focus/app/router/app_router.dart';
import 'package:habit_focus/core/config/app_config.dart';

void main() {
  testWidgets('App shows the localized home page', (tester) async {
    final config = AppConfig.parse(
      flavor: 'prod',
      apiBaseUrl: 'https://api.example.com/api',
    );

    await tester.pumpWidget(App(router: createRouter(config)));
    await tester.pumpAndSettle();

    expect(find.text('Habit Focus'), findsOneWidget);
    expect(find.text('Build habits. Stay focused.'), findsOneWidget);
  });
}
