import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_focus/core/theme/app_spacing.dart';
import 'package:habit_focus/core/theme/theme_context.dart';
import 'package:habit_focus/features/auth/presentation/bloc/login_cubit.dart';
import 'package:habit_focus/features/auth/presentation/bloc/login_state.dart';
import 'package:habit_focus/features/auth/presentation/validators/login_failure_message.dart';
import 'package:habit_focus/features/auth/presentation/widgets/auth_switch_link.dart';
import 'package:habit_focus/features/auth/presentation/widgets/email_field.dart';
import 'package:habit_focus/features/auth/presentation/widgets/login_error_message.dart';
import 'package:habit_focus/features/auth/presentation/widgets/login_submit_button.dart';
import 'package:habit_focus/features/auth/presentation/widgets/password_field.dart';
import 'package:habit_focus/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Login screen. Needs a [LoginCubit] above it in the widget tree.
class LoginPage extends StatefulWidget {
  /// Creates the page. [onLoggedIn] runs once after a successful login,
  /// [onCreateAccount] when the user wants to register instead.
  const new({
    required this.onLoggedIn,
    required this.onCreateAccount,
    super.key,
  });

  /// Called after the login succeeded, to switch the app to the signed-in
  /// state.
  final VoidCallback onLoggedIn;

  /// Called when the user taps the link to the registration screen.
  final VoidCallback onCreateAccount;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double _maxFormWidth = 420;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    unawaited(
      context.read<LoginCubit>().submit(
        email: _email.text,
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == LoginStatus.success,
      listener: (context, state) => widget.onLoggedIn(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxFormWidth),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.loginTitle,
                          style: context.text.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(l10n.loginSubtitle, style: context.text.bodyLarge),
                        const SizedBox(height: AppSpacing.xl),
                        EmailField(controller: _email),
                        const SizedBox(height: AppSpacing.m),
                        PasswordField(
                          controller: _password,
                          onSubmitted: _submit,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            final failure = state.failure;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (failure != null) ...[
                                  LoginErrorMessage(
                                    message: loginFailureMessage(l10n, failure),
                                  ),
                                  const SizedBox(height: AppSpacing.m),
                                ],
                                LoginSubmitButton(
                                  label: l10n.loginSubmit,
                                  isLoading: state.isSubmitting,
                                  onPressed: _submit,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.s),
                        AuthSwitchLink(
                          label: l10n.loginCreateAccount,
                          onPressed: widget.onCreateAccount,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
