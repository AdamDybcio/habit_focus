import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns every event of a stream into a [ChangeNotifier] notification.
///
/// `go_router` uses it as `refreshListenable` to re-run its redirect when the
/// session changes.
class StreamRefreshListenable extends ChangeNotifier {
  /// Starts listening to [stream].
  new(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
