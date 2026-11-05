import 'package:material_ui/material_ui.dart';

/// Semantic colors that the Material [ColorScheme] does not provide.
///
/// Raw color literals belong here and in `AppTheme`, nowhere else.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  /// Creates a set of semantic colors.
  const new({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
  });

  /// Semantic colors for the light theme.
  static const AppColorsExtension light = AppColorsExtension(
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFB26A00),
    onWarning: Color(0xFFFFFFFF),
  );

  /// Semantic colors for the dark theme.
  static const AppColorsExtension dark = AppColorsExtension(
    success: Color(0xFF81C995),
    onSuccess: Color(0xFF00391A),
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF3E2700),
  );

  /// Color for positive outcomes such as a completed habit.
  final Color success;

  /// Content color drawn on top of [success].
  final Color onSuccess;

  /// Color for cautions such as a streak at risk.
  final Color warning;

  /// Content color drawn on top of [warning].
  final Color onWarning;

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}
