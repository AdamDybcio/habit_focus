import 'package:habit_focus/core/theme/app_colors_extension.dart';
import 'package:material_ui/material_ui.dart';

/// Shortcuts for reading theme data from a [BuildContext].
extension ThemeContext on BuildContext {
  /// The active [ColorScheme].
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// The active [TextTheme].
  TextTheme get text => Theme.of(this).textTheme;

  /// Semantic app colors such as success and warning.
  AppColorsExtension get appColors {
    return Theme.of(this).extension<AppColorsExtension>()!;
  }
}
