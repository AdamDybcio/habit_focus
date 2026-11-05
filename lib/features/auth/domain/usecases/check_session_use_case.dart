import 'package:habit_focus/features/auth/domain/repositories/auth_repository.dart';

/// Tells whether the user is still logged in from a previous app run.
class CheckSessionUseCase {
  /// Creates the use case.
  const new(this._repository);

  final AuthRepository _repository;

  /// Returns `true` when tokens are stored on this device.
  Future<bool> call() => _repository.hasSession();
}
