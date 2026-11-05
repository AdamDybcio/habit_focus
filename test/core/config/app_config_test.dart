import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/config/app_config.dart';
import 'package:habit_focus/core/config/flavor.dart';

void main() {
  group('AppConfig.parse', () {
    test('accepts plain http for dev', () {
      final config = AppConfig.parse(
        flavor: 'dev',
        apiBaseUrl: 'http://10.0.2.2:8000/api',
      );

      expect(config.flavor, Flavor.dev);
      expect(config.apiBaseUrl.host, '10.0.2.2');
      expect(config.isProd, isFalse);
      expect(config.loggingEnabled, isTrue);
    });

    test('accepts https for prod and disables logging', () {
      final config = AppConfig.parse(
        flavor: 'prod',
        apiBaseUrl: 'https://api.example.com/api',
      );

      expect(config.flavor, Flavor.prod);
      expect(config.isProd, isTrue);
      expect(config.loggingEnabled, isFalse);
    });

    test('rejects an unknown flavor', () {
      expect(
        () => AppConfig.parse(
          flavor: 'qa',
          apiBaseUrl: 'https://api.example.com',
        ),
        throwsFormatException,
      );
    });

    test('rejects an empty base url', () {
      expect(
        () => AppConfig.parse(flavor: 'dev', apiBaseUrl: ''),
        throwsFormatException,
      );
    });

    test('rejects a relative base url', () {
      expect(
        () => AppConfig.parse(flavor: 'dev', apiBaseUrl: '/api'),
        throwsFormatException,
      );
    });

    test('rejects non-http schemes', () {
      expect(
        () => AppConfig.parse(flavor: 'dev', apiBaseUrl: 'ftp://host/api'),
        throwsFormatException,
      );
    });

    test('rejects plain http for staging', () {
      expect(
        () => AppConfig.parse(
          flavor: 'staging',
          apiBaseUrl: 'http://staging.example.com',
        ),
        throwsFormatException,
      );
    });

    test('rejects plain http for prod', () {
      expect(
        () => AppConfig.parse(
          flavor: 'prod',
          apiBaseUrl: 'http://api.example.com',
        ),
        throwsFormatException,
      );
    });
  });
}
