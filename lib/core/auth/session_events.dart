import 'dart:async';

/// Broadcasts that the server-side session is gone and the user must log in.
///
/// The network layer reports it, the session state listens to it. This keeps
/// `core/network` independent from navigation and UI.
class SessionEvents {
  /// Creates the event hub.
  new();

  final StreamController<void> _controller = StreamController<void>.broadcast();

  /// Emits once every time the refresh token has been rejected.
  Stream<void> get expired => _controller.stream;

  /// Reports that the session expired.
  void notifyExpired() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  /// Releases the underlying stream.
  Future<void> dispose() => _controller.close();
}
