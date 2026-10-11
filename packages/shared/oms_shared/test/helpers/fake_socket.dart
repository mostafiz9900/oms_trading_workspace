import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

/// In-memory websocket: the test decides when it opens, fails or drops,
/// and reads everything the app sent.
class FakeChannel implements WebSocketChannel {
  FakeChannel(this.uri);

  final Uri uri;
  final _ready = Completer<void>();
  final _incoming = StreamController<dynamic>();
  final sent = <dynamic>[];

  void open() => _ready.complete();
  void fail() => _ready.completeError(Exception('connection refused'));
  void serverSends(String message) => _incoming.add(message);

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

  final FakeChannel channel;

  @override
  void add(dynamic data) => channel.sent.add(data);

  @override
  Future close([int? closeCode, String? closeReason]) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
