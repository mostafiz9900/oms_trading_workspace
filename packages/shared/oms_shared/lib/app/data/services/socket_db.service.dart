import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';


class WebSocketService extends GetxService {
  static WebSocketService get instance => Get.find<WebSocketService>();

  // ─── Private State ────────────────────────────────────────────────────────

  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, StreamSubscription> _subscriptions = {}; // 🚀 Memory Leak রোধ করার জন্য
  final Map<String, bool> _connectionStatus = {};
  final Map<String, String> _socketUrls = {};

  // Callbacks — kept alive across reconnects
  final Map<String, Function(String)> _messageHandlers = {};
  final Map<String, Function()> _connectedCallbacks = {};
  final Map<String, Function()> _disconnectedCallbacks = {};
  final Map<String, Function(dynamic)> _errorCallbacks = {};

  // Reconnect control
  final Map<String, int> _retryCount = {};
  final Map<String, Timer?> _reconnectTimers = {};
  static const int _maxRetries = 10;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    debugPrint('WebSocketService initialized');
  }

  @override
  void onClose() {
    disconnectAll();
    super.onClose();
    debugPrint('WebSocketService closed');
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
    try {
      debugPrint('🔄 Attempting to connect: $socketId');

      channel = WebSocketChannel.connect(Uri.parse(url));
      _channels[socketId] = channel;

      // 🚀 FIX: সকেট পুরোপুরি কানেক্ট হওয়া পর্যন্ত অপেক্ষা করবে
      await channel.ready;

      // কানেক্ট হতে হতে যদি ইউজার disconnect কল করে দেয়, তবে আর এগোবে না
      // ...or if a newer connect() for the same socket replaced this channel.
      if (!identical(_channels[socketId], channel)) return;

      _connectionStatus[socketId] = true;
      _retryCount[socketId] = 0; // Reset counter on fresh connect

      // 🚀 FIX: StreamSubscription সেভ করা হচ্ছে যাতে পরে cancel করা যায়
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
    }
  }

  /// Send a text message to a named socket.
  void sendMessage(String socketId, String message) {
    final connected = _connectionStatus[socketId] ?? false;
    if (_channels.containsKey(socketId) && connected) {
      try {
        _channels[socketId]!.sink.add(message);
      } catch (e) {
        debugPrint('❌ Error sending message to $socketId: $e');
        _handleError(socketId, e);
      }
    } else {
      debugPrint('⚠️ Cannot send — $socketId is not connected');
    }
  }

  /// Gracefully disconnect a named socket (no auto-reconnect).
  void disconnect(String socketId) {
    if (!_channels.containsKey(socketId)) return;

    _closeChannel(socketId);
    _removeCallbacks(socketId); // full cleanup — no reconnect desired
    _cancelReconnectTimer(socketId);

    debugPrint('🔌 Manually disconnected: $socketId');
  }

  // 🚀 MISSING FUNCTION 1: Whether a socket is currently marked as connected.
  bool isConnected(String socketId) => _connectionStatus[socketId] ?? false;

  // 🚀 MISSING FUNCTION 2: IDs of all currently connected sockets.
  List<String> getConnectedSockets() => _connectionStatus.entries.where((e) => e.value).map((e) => e.key).toList();

  // 🚀 MISSING FUNCTION 3: Force immediate reconnect
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
    _cancelReconnectTimer(socketId); // আগের টাইমার ক্লিয়ার করা

    final retries = _retryCount[socketId] ?? 0;

    // Stop retrying after max attempts
    if (retries >= _maxRetries) {
      debugPrint('🛑 Max retries ($retries) reached for $socketId — giving up');
      return;
    }

    if (!_socketUrls.containsKey(socketId) || !_messageHandlers.containsKey(socketId)) {
      return;
    }

    _retryCount[socketId] = retries + 1;

    // Exponential back-off: 2s, 4s, 8s, 16s, 32s
    int delaySeconds = 2 * (retries + 1);
    if (delaySeconds > 30) delaySeconds = 30; // Max 30 seconds delay

    final delay = Duration(seconds: delaySeconds);
    debugPrint('🔄 Reconnect attempt ${retries + 1}/$_maxRetries for $socketId in ${delay.inSeconds}s');

    _reconnectTimers[socketId] = Timer(delay, () {
      final stillDisconnected = (_connectionStatus[socketId] ?? false) == false;
      if (stillDisconnected) {
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
      } catch (_) {}
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
  }
}
