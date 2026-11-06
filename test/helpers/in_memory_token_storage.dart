import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/auth/token_storage.dart';

/// [TokenStorage] that keeps tokens in a field. For tests only.
class InMemoryTokenStorage implements TokenStorage {
  new([this.tokens]);

  AuthTokens? tokens;

  @override
  Future<AuthTokens?> read() async => tokens;

  @override
  Future<void> write(AuthTokens tokens) async => this.tokens = tokens;

  @override
  Future<void> clear() async => tokens = null;
}
