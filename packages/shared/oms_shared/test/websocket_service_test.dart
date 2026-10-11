import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:oms_shared/app/data/services/socket_db.service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// In-memory websocket: the test decides when it opens, fails or drops.
class _FakeChannel implements WebSocketChannel {
  _FakeChannel(this.uri);

  final Uri uri;
  final _ready = Completer<void>();
  final _incoming = StreamController<dynamic>();
  final sent = <dynamic>[];
  bool closedByClient = false;

  void open() => _ready.complete();
  void fail() => _ready.completeError(Exception('connection refused'));
  void serverSends(String message) => _incoming.add(message);
  void serverDrops() => _incoming.close();

  @override
  Future<void> get ready => _ready.future;

  @override
  Stream get stream => _incoming.stream;

  @override
  WebSocketSink get sink => _FakeSink(this);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSink implements WebSocketSink {
  _FakeSink(this.channel);

  final _FakeChannel channel;

  @override
  void add(dynamic data) => channel.sent.add(data);

  @override
  Future close([int? closeCode, String? closeReason]) async {
    channel.closedByClient = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<_FakeChannel> opened;
  late StreamController<bool> online;
  late WebSocketService service;
  late List<String> received;
  late int connectedCalls;

  setUp(() {
    opened = [];
    online = StreamController<bool>.broadcast();
    received = [];
    connectedCalls = 0;
  });

  tearDown(() async {
    if (Get.isRegistered<WebSocketService>()) {
      await Get.delete<WebSocketService>(force: true); // runs onClose
    }
    Get.reset();
    await online.close();
  });

  // Created inside the test body so its listeners run in the test's fake
  // async zone (setUp runs outside it).
  void startService() {
    if (Get.isRegistered<WebSocketService>()) return;
    service = Get.put(
      WebSocketService(
        connector: (uri) {
          final c = _FakeChannel(uri);
          opened.add(c);
          return c;
        },
        onlineChanges: online.stream,
      ),
    );
  }

  Future<void> connect(WidgetTester tester) async {
    startService();
    unawaited(
      service.connect(
        socketId: 'market',
        url: 'wss://example.test/market',
        onMessage: received.add,
        onConnected: () => connectedCalls++,
      ),
    );
    await tester.pump();
  }

  // testWidgets gives fake time, so back-off timers run instantly via pump.
  testWidgets('connects, delivers messages and sends', (tester) async {
    await connect(tester);
    expect(service.sendMessage('market', 'sub'), isFalse, reason: 'not open yet');

    opened.last.open();
    await tester.pump();
    expect(service.isConnected('market'), isTrue);
    expect(connectedCalls, 1);

    opened.last.serverSends('tick-1');
    await tester.pump();
    expect(received, ['tick-1']);

    expect(service.sendMessage('market', 'sub'), isTrue);
    expect(opened.last.sent, ['sub']);
  });

  testWidgets('reconnects after the server drops the connection', (tester) async {
    await connect(tester);
    opened.last.open();
    await tester.pump();

    opened.last.serverDrops();
    await tester.pump();
    expect(service.isConnected('market'), isFalse);

    await tester.pump(const Duration(seconds: 2)); // first back-off step
    expect(opened.length, 2, reason: 'a new connection was opened');
    opened.last.open();
    await tester.pump();
    opened.last.serverSends('tick-after-reconnect');
    await tester.pump();
    expect(received, ['tick-after-reconnect']);
    expect(connectedCalls, 2);
  });

  testWidgets('keeps retrying past the old 10-attempt limit', (tester) async {
    await connect(tester);
    for (var attempt = 0; attempt < 15; attempt++) {
      opened.last.fail();
      await tester.pump();
      await tester.pump(const Duration(seconds: 30)); // longest back-off
    }
    expect(opened.length, 16, reason: 'still trying after 15 failures');

    opened.last.open();
    await tester.pump();
    expect(service.isConnected('market'), isTrue);
  });

  testWidgets('reconnects at once when the network comes back', (tester) async {
    await connect(tester);
    opened.last.open();
    await tester.pump();
    opened.last.serverDrops();
    await tester.pump();

    online.add(false);
    await tester.pump();
    final before = opened.length;
    online.add(true); // network back: no need to wait for the timer
    await tester.pump();
    expect(opened.length, before + 1);

    opened.last.open();
    await tester.pump();
    expect(service.isConnected('market'), isTrue);
    await tester.pump(const Duration(seconds: 30)); // pending timer is harmless
    expect(opened.length, before + 1, reason: 'no extra connection');
  });

  testWidgets('reconnects at once when the app is resumed', (tester) async {
    await connect(tester);
    opened.last.fail();
    await tester.pump();
    final before = opened.length;

    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    expect(opened.length, before + 1);
  });

  testWidgets('disconnect stops all reconnecting', (tester) async {
    await connect(tester);
    opened.last.open();
    await tester.pump();
    opened.last.serverDrops();
    await tester.pump();

    service.disconnect('market');
    final before = opened.length;
    await tester.pump(const Duration(minutes: 2));
    online.add(false);
    online.add(true);
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();
    expect(opened.length, before, reason: 'a closed socket stays closed');
    expect(service.sendMessage('market', 'x'), isFalse);
  });

  testWidgets('a superseded connection cannot affect the new one', (tester) async {
    await connect(tester);
    final first = opened.last;
    await connect(tester); // e.g. resume reconnects while the first is still opening
    final second = opened.last;
    expect(first.closedByClient, isTrue);

    second.open();
    await tester.pump();
    first.fail(); // late failure of the old attempt
    await tester.pump();
    expect(service.isConnected('market'), isTrue);

    await tester.pump(const Duration(seconds: 30));
    expect(opened.length, 2, reason: 'no reconnect triggered by the old one');
  });
}
