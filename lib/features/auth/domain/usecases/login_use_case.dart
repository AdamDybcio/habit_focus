import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/domain/repositories/auth_repository.dart';

/// Logs the user in with email and password.
class LoginUseCase {
  /// Creates the use case.
  const new(this._repository);

  final AuthRepository _repository;

  /// Logs in. The [email] is trimmed, the [password] is sent as typed.
  Future<Result<void>> call({required String email, required String password}) {
    return _repository.login(email: email.trim(), password: password);
  }
}
