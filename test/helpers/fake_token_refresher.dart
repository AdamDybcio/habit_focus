import 'package:habit_focus/core/auth/auth_tokens.dart';
import 'package:habit_focus/core/network/token_refresher.dart';

/// [TokenRefresher] with a replaceable behavior that counts its calls.
class FakeTokenRefresher implements TokenRefresher {
  new(this.onRefresh);

  Future<AuthTokens> Function(String refreshToken) onRefresh;

  int calls = 0;

  @override
  Future<AuthTokens> refresh(String refreshToken) {
    calls++;
    return onRefresh(refreshToken);
  }
}
