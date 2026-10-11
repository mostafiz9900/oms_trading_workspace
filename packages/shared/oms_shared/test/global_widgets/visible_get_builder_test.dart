import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/global_widgets/visible_get_builder.dart';

class _Counter extends GetxController {
  int value = 0;

  void bump([Object id = 'v']) {
    value++;
    update([id]);
  }
}

void main() {
  late _Counter counter;
  late int builds;

  setUp(() {
    counter = Get.put(_Counter());
    builds = 0;
  });

  tearDown(Get.reset);

  Widget visibleBuilder() => VisibleGetBuilder<_Counter>(
    id: 'v',
    builder: (c) {
      builds++;
      return Text('visible=${c.value}');
    },
  );

  Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('on screen it rebuilds exactly like GetBuilder', (tester) async {
    await tester.pumpWidget(
      app(
        Column(
          children: [
            GetBuilder<_Counter>(id: 'v', builder: (c) => Text('get=${c.value}')),
            visibleBuilder(),
          ],
        ),
      ),
    );
    expect(builds, 1);

    for (var i = 0; i < 3; i++) {
      counter.bump();
      await tester.pump();
    }
    expect(find.text('get=3'), findsOneWidget);
    expect(find.text('visible=3'), findsOneWidget);
    expect(builds, 4);

    // Updates for other ids are ignored, as with GetBuilder.
    counter.bump('other');
    await tester.pump();
    expect(builds, 4);
    expect(find.text('get=3'), findsOneWidget);
    expect(find.text('visible=3'), findsOneWidget);
  });

  testWidgets('hidden IndexedStack tab skips rebuilds and catches up when shown',
      (tester) async {
    Widget tabs(int index) => app(
      IndexedStack(index: index, children: [visibleBuilder(), const Text('other tab')]),
    );

    await tester.pumpWidget(tabs(0));
    expect(builds, 1);

    await tester.pumpWidget(tabs(1)); // switch away
    final buildsWhenHidden = builds;

    for (var i = 0; i < 5; i++) {
      counter.bump();
      await tester.pump();
    }
    expect(builds, buildsWhenHidden, reason: 'no work while the tab is hidden');

    await tester.pumpWidget(tabs(0)); // switch back
    expect(find.text('visible=5'), findsOneWidget);
    expect(builds, buildsWhenHidden + 1, reason: 'one rebuild with latest data');

    counter.bump();
    await tester.pump();
    expect(find.text('visible=6'), findsOneWidget);
  });

  testWidgets('screen covered by another page skips rebuilds until it returns',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(navigatorKey: navigator, home: Scaffold(body: visibleBuilder())),
    );

    navigator.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('confirm page'))),
    );
    await tester.pumpAndSettle();
    final buildsWhenCovered = builds;

    for (var i = 0; i < 3; i++) {
      counter.bump();
      await tester.pump();
    }
    expect(builds, buildsWhenCovered);

    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('visible=3'), findsOneWidget);
  });

  testWidgets('stops listening when disposed', (tester) async {
    await tester.pumpWidget(app(visibleBuilder()));
    await tester.pumpWidget(app(const SizedBox()));

    counter.bump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(builds, 1);
  });
}
