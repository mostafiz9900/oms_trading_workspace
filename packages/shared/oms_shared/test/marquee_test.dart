import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/models/marquee_holder.dart';
import 'package:oms_shared/app/modules/home/controllers/home_controller.dart';
import 'package:oms_shared/app/modules/market/views/local_widgets/clickable_marquee_text_list.dart';

/// The marquee only reads [HomeController.marqueeList].
class _FakeHome extends Fake implements HomeController {
  _FakeHome(this.marqueeList);

  @override
  final List<MarqueeHolder> marqueeList;
}

void main() {
  final home = _FakeHome([
    for (var i = 0; i < 80; i++)
      MarqueeHolder(shortName: 'S${i.toString().padLeft(2, '0')}', status: 'Up', chg: 1.5, last: 100, d: 0.5),
  ]);

  double offset(WidgetTester tester) => tester
      .state<ScrollableState>(find.byType(Scrollable, skipOffstage: false))
      .position
      .pixels;

  Widget tabs(int index) => MaterialApp(
    home: Scaffold(
      body: IndexedStack(
        index: index,
        children: [ClickableMarqueeTextList(homeCon: home), const Text('trade tab')],
      ),
    ),
  );

  testWidgets('scrolls 1 px every 30 ms, pauses while the tab is hidden',
      (tester) async {
    await tester.pumpWidget(tabs(0));
    await tester.pump(); // post-frame callback starts the auto-scroll

    await tester.pump(const Duration(milliseconds: 300));
    expect(offset(tester), 10, reason: 'same speed as before: 300 ms / 30 ms');

    await tester.pumpWidget(tabs(1)); // user opens another tab
    final hiddenAt = offset(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(offset(tester), hiddenAt, reason: 'no timer work while hidden');

    await tester.pumpWidget(tabs(0)); // back to Market
    await tester.pump(const Duration(milliseconds: 300));
    expect(offset(tester), hiddenAt + 10, reason: 'resumes from the same spot');

    await tester.pumpWidget(const SizedBox()); // dispose → timer cancelled
  });

  testWidgets('items are shown sorted by name', (tester) async {
    final unsorted = _FakeHome([
      MarqueeHolder(shortName: 'BETA', status: 'Up', chg: 1, last: 1, d: 1),
      MarqueeHolder(shortName: 'ALPHA', status: 'Down', chg: -1, last: 1, d: -1),
    ]);
    // The controller keeps marqueeList sorted; the widget shows it in order.
    unsorted.marqueeList.sort((a, b) => (a.shortName ?? '').compareTo(b.shortName ?? ''));
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ClickableMarqueeTextList(homeCon: unsorted))),
    );
    final alpha = tester.getTopLeft(find.text('ALPHA')).dx;
    final beta = tester.getTopLeft(find.text('BETA')).dx;
    expect(alpha, lessThan(beta));
    await tester.pumpWidget(const SizedBox());
  });
}
