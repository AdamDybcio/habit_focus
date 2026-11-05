import 'package:habit_focus/features/auth/presentation/validators/auth_validators.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Password input with a show/hide toggle.
class PasswordField extends StatefulWidget {
  /// Creates the field that edits [controller].
  ///
  /// [onSubmitted] runs when the user confirms on the keyboard.
  const new({required this.controller, required this.onSubmitted, super.key});

  /// Holds the typed password.
  final TextEditingController controller;

  /// Called when the user presses "done" on the keyboard.
  final VoidCallback onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      autocorrect: false,
      enableSuggestions: false,
      onFieldSubmitted: (_) => widget.onSubmitted(),
      validator: (value) => AuthValidators.password(l10n, value),
      decoration: InputDecoration(
        labelText: l10n.loginPasswordLabel,
        suffixIcon: IconButton(
          tooltip: _obscured ? l10n.loginShowPassword : l10n.loginHidePassword,
          icon: Icon(
            _obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}
