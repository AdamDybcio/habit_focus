import 'package:equatable/equatable.dart';

/// Pair of credentials issued by the backend after a login or a refresh.
class AuthTokens extends Equatable {
  /// Creates a token pair.
  const new({required this.accessToken, required this.refreshToken});

  /// Short-lived token sent with every API request.
  final String accessToken;

  /// Long-lived token used only to obtain a new [accessToken].
  final String refreshToken;

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
