import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/theme/app_colors_extension.dart';
import 'package:habit_focus/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppTheme', () {
    test('light theme is light and carries semantic colors', () {
      final theme = AppTheme.light();

      expect(theme.colorScheme.brightness, Brightness.light);
      expect(
        theme.extension<AppColorsExtension>(),
        same(AppColorsExtension.light),
      );
    });

    test('dark theme is dark and carries semantic colors', () {
      final theme = AppTheme.dark();

      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(
        theme.extension<AppColorsExtension>(),
        same(AppColorsExtension.dark),
      );
    });

    test('light and dark color schemes differ', () {
      expect(
        AppTheme.light().colorScheme.primary,
        isNot(AppTheme.dark().colorScheme.primary),
      );
    });
  });

  group('AppColorsExtension', () {
    test('lerp at 0 keeps the start colors', () {
      final lerped = AppColorsExtension.light.lerp(AppColorsExtension.dark, 0);

      expect(lerped.success, AppColorsExtension.light.success);
      expect(lerped.warning, AppColorsExtension.light.warning);
    });

    test('lerp at 1 reaches the end colors', () {
      final lerped = AppColorsExtension.light.lerp(AppColorsExtension.dark, 1);

      expect(lerped.success, AppColorsExtension.dark.success);
      expect(lerped.onWarning, AppColorsExtension.dark.onWarning);
    });

    test('lerp with a foreign extension returns this instance', () {
      final lerped = AppColorsExtension.light.lerp(null, 0.5);

      expect(lerped, same(AppColorsExtension.light));
    });

    test('copyWith replaces only the given colors', () {
      final copy = AppColorsExtension.light.copyWith(
        success: const Color(0xFF000000),
      );

      expect(copy.success, const Color(0xFF000000));
      expect(copy.warning, AppColorsExtension.light.warning);
    });
  });
}
