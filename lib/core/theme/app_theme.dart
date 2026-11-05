import 'package:habit_focus/core/theme/app_colors_extension.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the light and dark [ThemeData] of the app.
abstract final class AppTheme {
  /// Seed color from which all tonal palettes are generated.
  static const Color seedColor = Color(0xFF2F6F5E);

  /// Light theme.
  static ThemeData light() {
    return _build(Brightness.light, AppColorsExtension.light);
  }

  /// Dark theme.
  static ThemeData dark() {
    return _build(Brightness.dark, AppColorsExtension.dark);
  }

  static ThemeData _build(Brightness brightness, AppColorsExtension colors) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}
