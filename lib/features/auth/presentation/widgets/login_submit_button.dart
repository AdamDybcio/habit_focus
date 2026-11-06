import 'package:habit_focus/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Full-width primary button that shows a spinner while [isLoading].
class LoginSubmitButton extends StatelessWidget {
  /// Creates the button.
  const new({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  /// Text shown when idle.
  final String label;

  /// Whether a request is running. The button is disabled meanwhile.
  final bool isLoading;

  /// Called when the user taps the button.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpacing.xxl),
      ),
      child: isLoading
          ? const SizedBox.square(
              dimension: AppSpacing.m,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
