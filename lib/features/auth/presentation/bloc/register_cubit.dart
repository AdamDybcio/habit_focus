import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_focus/features/auth/domain/usecases/register_use_case.dart';
import 'package:habit_focus/features/auth/presentation/bloc/register_state.dart';

/// Runs registration attempts for the registration screen.
class RegisterCubit extends Cubit<RegisterState> {
  /// Creates the cubit.
  new(this._register) : super(const RegisterState());

  final RegisterUseCase _register;

  /// Creates an account with [email] and [password]. Ignored while a request
  /// is running.
  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) {
      return;
    }
    emit(const RegisterState(status: RegisterStatus.submitting));
    final result = await _register(email: email, password: password);
    if (isClosed) {
      return;
    }
    emit(
      result.when<RegisterState>(
        success: (_) => const RegisterState(status: RegisterStatus.success),
        failure: (error) =>
            RegisterState(status: RegisterStatus.failure, failure: error),
      ),
    );
  }
}
