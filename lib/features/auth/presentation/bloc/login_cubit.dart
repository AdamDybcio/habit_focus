import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_focus/features/auth/domain/usecases/login_use_case.dart';
import 'package:habit_focus/features/auth/presentation/bloc/login_state.dart';

/// Runs login attempts for the login screen.
class LoginCubit extends Cubit<LoginState> {
  /// Creates the cubit.
  new(this._login) : super(const LoginState());

  final LoginUseCase _login;

  /// Logs in with [email] and [password]. Ignored while a request is running.
  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) {
      return;
    }
    emit(const LoginState(status: LoginStatus.submitting));
    final result = await _login(email: email, password: password);
    if (isClosed) {
      return;
    }
    emit(
      result.when<LoginState>(
        success: (_) => const LoginState(status: LoginStatus.success),
        failure: (error) =>
            LoginState(status: LoginStatus.failure, failure: error),
      ),
    );
  }
}
