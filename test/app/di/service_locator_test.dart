import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/app/di/service_locator.dart';
import 'package:habit_focus/core/config/app_config.dart';

void main() {
  tearDown(resetDependencies);

  test('configureDependencies registers the AppConfig', () {
    final config = AppConfig.parse(
      flavor: 'dev',
      apiBaseUrl: 'http://10.0.2.2:8000/api',
    );

    configureDependencies(config);

    expect(getIt<AppConfig>(), same(config));
  });
}
