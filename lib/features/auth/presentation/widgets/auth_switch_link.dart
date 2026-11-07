import 'package:material_ui/material_ui.dart';

/// Text button that moves between the login and registration screens.
class AuthSwitchLink extends StatelessWidget {
  /// Creates the link.
  const new({required this.label, required this.onPressed, super.key});

  /// Text of the link.
  final String label;

  /// Called when the user taps the link.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}
