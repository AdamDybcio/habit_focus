import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/app/router/stream_refresh_listenable.dart';

void main() {
  test('notifies listeners for every event of the stream', () async {
    final controller = StreamController<int>();
    final listenable = StreamRefreshListenable(controller.stream);
    var notifications = 0;
    listenable.addListener(() => notifications++);

    controller
      ..add(1)
      ..add(2);
    await Future<void>.delayed(Duration.zero);

    expect(notifications, 2);
    listenable.dispose();
    await controller.close();
  });

  test('stops listening after dispose', () async {
    final controller = StreamController<int>.broadcast();
    StreamRefreshListenable(controller.stream).dispose();

    await Future<void>.delayed(Duration.zero);

    expect(controller.hasListener, isFalse);
    await controller.close();
  });
}
