import 'package:habit_focus/core/theme/theme_context.dart';
import 'package:material_ui/material_ui.dart';

/// Error line shown under the login form. Announced by screen readers.
class LoginErrorMessage extends StatelessWidget {
  /// Creates the message.
  const new({required this.message, super.key});

  /// Localized text to display.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: context.text.bodyMedium?.copyWith(color: context.colors.error),
      ),
    );
  }
}
