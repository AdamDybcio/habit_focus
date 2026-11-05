import 'package:habit_focus/core/result/result.dart';
import 'package:habit_focus/features/auth/domain/repositories/auth_repository.dart';

/// Ends the current session on this device.
class LogoutUseCase {
  /// Creates the use case.
  const new(this._repository);

  final AuthRepository _repository;

  /// Removes the stored tokens.
  Future<Result<void>> call() => _repository.logout();
}
