import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/core/utils/helpers/update_throttle.dart';

void main() {
  const interval = Duration(milliseconds: 500);

  // testWidgets runs in a fake-async zone, so tester.pump() drives the timer.
  testWidgets('first update is immediate, a burst ends on the latest value',
      (tester) async {
    var now = DateTime(2026, 1, 1, 10);
    final throttle = UpdateThrottle(now: () => now);
    final shown = <int>[];

    throttle.run(() => shown.add(1));
    expect(shown, [1], reason: 'leading run is immediate');

    // A burst of ticks inside the interval...
    now = now.add(const Duration(milliseconds: 100));
    throttle.run(() => shown.add(2));
    throttle.run(() => shown.add(3));
    throttle.run(() => shown.add(4));
    expect(shown, [1]);

    // ...is drawn once, with the last value.
    await tester.pump(interval);
    expect(shown, [1, 4]);

    // After a quiet interval the next tick is immediate again.
    now = now.add(const Duration(seconds: 1));
    throttle.run(() => shown.add(5));
    expect(shown, [1, 4, 5]);
  });

  testWidgets('reset drops a pending run; cancel stops it', (tester) async {
    var now = DateTime(2026, 1, 1, 10);
    final throttle = UpdateThrottle(now: () => now);
    final shown = <int>[];

    throttle.run(() => shown.add(1));
    throttle.run(() => shown.add(2)); // pending trailing run
    throttle.reset(); // e.g. a new snapshot was drawn directly
    await tester.pump(interval);
    expect(shown, [1]);

    throttle.run(() => shown.add(3)); // inside interval after reset → trailing
    throttle.cancel(); // controller closed
    await tester.pump(interval);
    expect(shown, [1]);
  });
}
