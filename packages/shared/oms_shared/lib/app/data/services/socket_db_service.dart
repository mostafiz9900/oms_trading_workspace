import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Opens a websocket channel; replaced in tests.
typedef WebSocketConnector = WebSocketChannel Function(Uri uri);

/// Owns every named websocket in the app.
///
/// A socket stays wanted from [connect] until [disconnect]. While wanted it
/// is kept alive: after a drop or error it reconnects with a growing delay
/// (2 s, 4 s ... capped at 30 s) and never gives up, and it reconnects at once
/// when the network comes back or the app returns to the foreground.
class WebSocketService extends GetxService with WidgetsBindingObserver {
  WebSocketService({WebSocketConnector? connector, Stream<bool>? onlineChanges})
    : _connector = connector ?? WebSocketChannel.connect,
      _onlineChanges = onlineChanges ?? _connectivityOnline();

  static WebSocketService get instance => Get.find<WebSocketService>();

  final WebSocketConnector _connector;
  final Stream<bool> _onlineChanges;

  // ─── Private State ────────────────────────────────────────────────────────

  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, StreamSubscription> _subscriptions = {}; // 🚀 Memory Leak রোধ করার জন্য
  final Map<String, bool> _connectionStatus = {};
  final Map<String, String> _socketUrls = {};
  final Set<String> _connecting = {};

  // Callbacks — kept alive across reconnects
  final Map<String, Function(String)> _messageHandlers = {};
  final Map<String, Function()> _connectedCallbacks = {};
  final Map<String, Function()> _disconnectedCallbacks = {};
  final Map<String, Function(dynamic)> _errorCallbacks = {};

  // Reconnect control
  final Map<String, int> _retryCount = {};
  final Map<String, Timer?> _reconnectTimers = {};
  static const int _maxDelaySeconds = 30;

  StreamSubscription<bool>? _onlineSubscription;
  bool _online = true;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _onlineSubscription = _onlineChanges.listen(_onOnlineChanged);
    debugPrint('WebSocketService initialized');
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _onlineSubscription?.cancel();
    disconnectAll();
    super.onClose();
    debugPrint('WebSocketService closed');
  }

  static Stream<bool> _connectivityOnline() => Connectivity().onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );

  void _onOnlineChanged(bool online) {
    final cameBack = online && !_online;
    _online = online;
    if (cameBack) {
      debugPrint('🌐 Network is back — reconnecting dropped sockets');
      _reconnectDropped();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reconnectDropped();
  }

  /// Reconnects, without waiting for the back-off timer, every socket that is
  /// still wanted but not connected.
  void _reconnectDropped() {
    for (final socketId in _socketUrls.keys.toList()) {
      if (isConnected(socketId) || _connecting.contains(socketId)) continue;
      forceReconnect(socketId);
    }
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Connect (or reconnect) a named socket.
  Future<void> connect({
    required String socketId,
    required String url,
    required Function(String) onMessage,
    Function()? onConnected,
    Function()? onDisconnected,
    Function(dynamic)? onError,
  }) async {
    // 1. Clean up stale channel and timers
    _closeChannel(socketId);
    _cancelReconnectTimer(socketId);

    // 2. Store metadata for auto-reconnect
    _socketUrls[socketId] = url;
    _messageHandlers[socketId] = onMessage;
    if (onConnected != null) _connectedCallbacks[socketId] = onConnected;
    if (onDisconnected != null) _disconnectedCallbacks[socketId] = onDisconnected;
    if (onError != null) _errorCallbacks[socketId] = onError;

    WebSocketChannel? channel;
    _connecting.add(socketId);
    try {
      debugPrint('🔄 Attempting to connect: $socketId');

      channel = _connector(Uri.parse(url));
      _channels[socketId] = channel;

      // 🚀 FIX: সকেট পুরোপুরি কানেক্ট হওয়া পর্যন্ত অপেক্ষা করবে
      await channel.ready;

      // কানেক্ট হতে হতে যদি ইউজার disconnect কল করে দেয়, তবে আর এগোবে না
      // ...or if a newer connect() for the same socket replaced this channel.
      if (!identical(_channels[socketId], channel)) return;

      _connectionStatus[socketId] = true;
      _retryCount[socketId] = 0; // Reset counter on fresh connect

      // 🚀 FIX: StreamSubscription সেভ করা হচ্ছে যাতে পরে cancel করা যায়
      _subscriptions[socketId] = channel.stream.listen(
        (message) => _messageHandlers[socketId]?.call(message.toString()),
        onError: (error) => _handleError(socketId, error),
        onDone: () => _handleDisconnect(socketId),
        cancelOnError: false,
      );

      _connectedCallbacks[socketId]?.call();
      debugPrint('✅ WebSocket connected: $socketId');
    } catch (e) {
      // A failure of a superseded channel must not affect the current one.
      if (channel == null || identical(_channels[socketId], channel)) {
        _handleError(socketId, e);
      }
    } finally {
      // Only the current attempt clears the flag (a newer one may be running).
      if (channel == null || identical(_channels[socketId], channel)) {
        _connecting.remove(socketId);
      }
    }
  }

  /// Send a text message to a named socket. Returns false when the socket is
  /// not connected (nothing is sent).
  bool sendMessage(String socketId, String message) {
    final connected = _connectionStatus[socketId] ?? false;
    if (_channels.containsKey(socketId) && connected) {
      try {
        _channels[socketId]!.sink.add(message);
        return true;
      } catch (e) {
        debugPrint('❌ Error sending message to $socketId: $e');
        _handleError(socketId, e);
        return false;
      }
    }
    debugPrint('⚠️ Cannot send — $socketId is not connected');
    return false;
  }

  /// Gracefully disconnect a named socket (no auto-reconnect).
  void disconnect(String socketId) {
    // Always drop the callbacks and timer, even if the channel is already
    // gone, so a pending reconnect cannot bring the socket back.
    final hadChannel = _channels.containsKey(socketId);
    _closeChannel(socketId);
    _removeCallbacks(socketId); // full cleanup — no reconnect desired
    _cancelReconnectTimer(socketId);
    _connecting.remove(socketId);

    if (hadChannel) debugPrint('🔌 Manually disconnected: $socketId');
  }

  /// Whether a socket is currently marked as connected.
  bool isConnected(String socketId) => _connectionStatus[socketId] ?? false;

  /// IDs of all currently connected sockets.
  List<String> getConnectedSockets() => _connectionStatus.entries.where((e) => e.value).map((e) => e.key).toList();

  /// Reconnect now instead of waiting for the back-off timer.
  void forceReconnect(String socketId) {
    debugPrint('⚡ Forcing immediate reconnect for: $socketId');
    _retryCount[socketId] = 0;
    _cancelReconnectTimer(socketId);

    if (_socketUrls.containsKey(socketId) && _messageHandlers.containsKey(socketId)) {
      connect(socketId: socketId, url: _socketUrls[socketId]!, onMessage: _messageHandlers[socketId]!);
    }
  }

  // ─── Internal Helpers ─────────────────────────────────────────────────────

  void _handleError(String socketId, dynamic error) {
    debugPrint('🚨 WebSocket error ($socketId): $error');
    _connectionStatus[socketId] = false;
    _errorCallbacks[socketId]?.call(error);
    _scheduleReconnect(socketId);
  }

  void _handleDisconnect(String socketId) {
    if ((_connectionStatus[socketId] ?? false) == false) return;

    debugPrint('📡 WebSocket disconnected: $socketId');
    _connectionStatus[socketId] = false;
    _disconnectedCallbacks[socketId]?.call();
    _scheduleReconnect(socketId);
  }

  void _scheduleReconnect(String socketId) {
    _cancelReconnectTimer(socketId); // আগের টাইমার ক্লিয়ার করা

    if (!_socketUrls.containsKey(socketId) || !_messageHandlers.containsKey(socketId)) {
      return;
    }

    final retries = _retryCount[socketId] ?? 0;
    _retryCount[socketId] = retries + 1;

    // Back-off: 2s, 4s, 6s ... capped at 30s, retried for as long as the
    // socket is wanted (it used to give up for good after 10 attempts).
    int delaySeconds = 2 * (retries + 1);
    if (delaySeconds > _maxDelaySeconds) delaySeconds = _maxDelaySeconds;

    final delay = Duration(seconds: delaySeconds);
    debugPrint('🔄 Reconnect attempt ${retries + 1} for $socketId in ${delay.inSeconds}s');

    _reconnectTimers[socketId] = Timer(delay, () {
      final stillDisconnected = (_connectionStatus[socketId] ?? false) == false;
      if (stillDisconnected && _socketUrls.containsKey(socketId)) {
        connect(socketId: socketId, url: _socketUrls[socketId]!, onMessage: _messageHandlers[socketId]!);
      }
    });
  }

  void _closeChannel(String socketId) {
    _subscriptions[socketId]?.cancel(); // 🚀 Stream cancel করা হলো
    _subscriptions.remove(socketId);

    if (_channels.containsKey(socketId)) {
      try {
        _channels[socketId]!.sink.close(status.normalClosure);
      } catch (_) {
        // The channel may already be closed; nothing else to clean up.
      }
      _channels.remove(socketId);
    }
    _connectionStatus[socketId] = false;
  }

  void _cancelReconnectTimer(String socketId) {
    _reconnectTimers[socketId]?.cancel();
    _reconnectTimers.remove(socketId);
  }

  void _removeCallbacks(String socketId) {
    _messageHandlers.remove(socketId);
    _connectedCallbacks.remove(socketId);
    _disconnectedCallbacks.remove(socketId);
    _errorCallbacks.remove(socketId);
    _socketUrls.remove(socketId);
    _retryCount.remove(socketId);
  }

  void disconnectAll() {
    final activeSockets = _channels.keys.toList();
    for (final socketId in activeSockets) {
      _closeChannel(socketId);
      _cancelReconnectTimer(socketId);
    }
    _messageHandlers.clear();
    _socketUrls.clear();
    _connecting.clear();
  }

  @visibleForTesting
  bool get isOnline => _online;
}
