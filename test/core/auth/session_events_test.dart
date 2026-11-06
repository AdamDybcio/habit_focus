import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/auth/session_events.dart';

void main() {
  test('notifyExpired reaches every listener', () async {
    final events = SessionEvents();
    var first = 0;
    var second = 0;
    events.expired.listen((_) => first++);
    events.expired.listen((_) => second++);

    events.notifyExpired();
    await Future<void>.delayed(Duration.zero);

    expect(first, 1);
    expect(second, 1);
    await events.dispose();
  });

  test('notifyExpired after dispose does nothing', () async {
    final events = SessionEvents();
    await events.dispose();

    expect(events.notifyExpired, returnsNormally);
  });
}
