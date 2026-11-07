import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/domain/repositories/auth_repository.dart';

/// Creates an account and logs the new user in.
class RegisterUseCase {
  /// Creates the use case.
  const new(this._repository);

  final AuthRepository _repository;

  /// Registers. The [email] is trimmed, the [password] is sent as typed.
  Future<Result<void>> call({required String email, required String password}) {
    return _repository.register(email: email.trim(), password: password);
  }
}
