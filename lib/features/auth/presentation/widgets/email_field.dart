import 'package:habit_focus/features/auth/presentation/validators/auth_validators.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Email input with validation and autofill support.
class EmailField extends StatelessWidget {
  /// Creates the field that edits [controller].
  const new({required this.controller, super.key});

  /// Holds the typed address.
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
      autocorrect: false,
      enableSuggestions: false,
      validator: (value) => AuthValidators.email(l10n, value),
      decoration: InputDecoration(labelText: l10n.loginEmailLabel),
    );
  }
}
