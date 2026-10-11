import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// import 'package:sse_channel/sse_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../app_pkg.dart';

class WebSocketService2 extends GetxService {
  static WebSocketService2 get instance => Get.find();

  final Map<String, WebSocketChannel> channels = {};
  final Map<String, bool> _connectionStatus = {};
  final Map<String, Function(String)> _messageHandlers = {};
  final Map<String, Function()> _connectedCallbacks = {};
  final Map<String, Function()> _disconnectedCallbacks = {};
  final Map<String, Function(dynamic)> _errorCallbacks = {};
  final Map<String, String> _socketUrls = {};

  // Low Memory Primitive HashMaps for tracking individual pipelines
  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, dynamic> _latestDataPayloads = {};

  // Anti-Crash Exponential Reconnection Matrices
  final Map<String, int> _reconnectAttempts = {};
  static const int maxRecoveryAttempts = 5;

  @override
  void onInit() {
    super.onInit();
    print('WebSocketService initialized');
  }

  @override
  void onClose() {
    _disconnectAll();
    super.onClose();
    print('WebSocketService closed');
  }

  // Connect to WebSocket
  void connect({
    required String socketId,
    required String url,
    required Function(String) onMessage,
    Function()? onConnected,
    Function()? onDisconnected,
    Function(dynamic)? onError,
  }) {
    try {
      // Close existing connection if any (using our safe method)
      if (channels.containsKey(socketId)) {
        _safeClose(socketId);
      }

      final channel = WebSocketChannel.connect(Uri.parse(url));
      channels[socketId] = channel;
      _connectionStatus[socketId] = true;
      _messageHandlers[socketId] = onMessage;
      _socketUrls[socketId] = url;

      if (onConnected != null) {
        _connectedCallbacks[socketId] = onConnected;
      }
      if (onDisconnected != null) {
        _disconnectedCallbacks[socketId] = onDisconnected;
      }
      if (onError != null) {
        _errorCallbacks[socketId] = onError;
      }

      // Listen to messages
      channel.stream.listen(
        (message) {
          if (_messageHandlers.containsKey(socketId)) {
            _messageHandlers[socketId]!(message.toString());
          }
        },
        onError: (error) {
          _handleError(socketId, error);
        },
        onDone: () {
          _handleDisconnect(socketId);
        },
        cancelOnError: false,
      );

      onConnected?.call();
      print('✅ WebSocket connected: $socketId');
    } catch (e) {
      _handleError(socketId, e);
    }
  }

  // Safe close method that avoids the 1001 error
  void _safeClose(String socketId) {
    if (channels.containsKey(socketId)) {
      try {
        final channel = channels[socketId]!;
        channel.sink.close(status.normalClosure);
        _cleanupSocket(socketId);
        channels.remove(socketId);
        print('🔒 Safely closed socket: $socketId');
      } catch (e) {
        print('⚠️ Error during safe close of $socketId: $e');
        _cleanupSocket(socketId);
        channels.remove(socketId);
      }
    }
  }

  // Alternative method for manual disconnection
  void disconnect(String socketId) {
    if (channels.containsKey(socketId)) {
      try {
        final channel = channels[socketId]!;
        final onDisconnected = _disconnectedCallbacks[socketId];
        channel.sink.close(status.normalClosure);
        _cleanupSocket(socketId);
        channels.remove(socketId);
        onDisconnected?.call();
        print('🔌 Manually disconnected: $socketId');
      } catch (e) {
        print('❌ Error disconnecting $socketId: $e');
        _cleanupSocket(socketId);
        channels.remove(socketId);
      }
    }
  }

  void _handleError(String socketId, dynamic error) {
    print('🚨 WebSocket error ($socketId): $error');
    _connectionStatus[socketId] = false;
    _errorCallbacks[socketId]?.call(error);

    // Schedule reconnection
    _scheduleReconnect(socketId); // Always reconnects on error
  }

  void _handleDisconnect(String socketId) {
    print('🔌 WebSocket disconnected: $socketId');
    _connectionStatus[socketId] = false;
    _disconnectedCallbacks[socketId]?.call();

    // Schedule reconnection
    _scheduleReconnect(socketId); // Always reconnects on error
  }

  void _scheduleReconnect(String socketId) {
    Future.delayed(const Duration(seconds: 2), () {
      if ((_connectionStatus[socketId] ?? false) == false &&
          _socketUrls.containsKey(socketId) &&
          _messageHandlers.containsKey(socketId)) {
        print('🔄 Auto-reconnecting: $socketId');
        _reconnect(socketId);
      }
    });
  }

  void _reconnect(String socketId) {
    final url = _socketUrls[socketId];
    final handler = _messageHandlers[socketId];
    final onConnected = _connectedCallbacks[socketId];
    final onDisconnected = _disconnectedCallbacks[socketId];
    final onError = _errorCallbacks[socketId];

    if (url != null && handler != null) {
      connect(
        socketId: socketId,
        url: url,
        onMessage: handler,
        onConnected: onConnected,
        onDisconnected: onDisconnected,
        onError: onError,
      );
    }
  }

  // Send message
  void sendMessage(String socketId, String message) {
    if (channels.containsKey(socketId) && _connectionStatus[socketId]!) {
      try {
        channels[socketId]!.sink.add(message);
      } catch (e) {
        print('❌ Error sending message to $socketId: $e');
        _handleError(socketId, e);
      }
    } else {
      print('⚠️ Cannot send message - $socketId is not connected');
    }
  }

  void _cleanupSocket(String socketId) {
    // Remove callbacks but keep URLs for reconnection
    _messageHandlers.remove(socketId); // removes handler
    _connectedCallbacks.remove(socketId);
    _disconnectedCallbacks.remove(socketId);
    _errorCallbacks.remove(socketId);
    _connectionStatus.remove(socketId);
  }

  // Disconnect all sockets
  void _disconnectAll() {
    for (var socketId in channels.keys.toList()) {
      _safeClose(socketId);
    }
    channels.clear();
    _connectionStatus.clear();
    _messageHandlers.clear();
    _connectedCallbacks.clear();
    _disconnectedCallbacks.clear();
    _errorCallbacks.clear();
    _socketUrls.clear();
  }

  // Check connection status
  bool isConnected(String socketId) {
    return _connectionStatus[socketId] ?? false;
  }

  // Get all connected sockets
  List<String> getConnectedSockets() {
    return _connectionStatus.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
  }
}

///

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

    try {
      debugPrint('🔄 Attempting to connect: $socketId');

      final channel = WebSocketChannel.connect(Uri.parse(url));
      _channels[socketId] = channel;

      // 🚀 FIX: সকেট পুরোপুরি কানেক্ট হওয়া পর্যন্ত অপেক্ষা করবে
      await channel.ready;

      // কানেক্ট হতে হতে যদি ইউজার disconnect কল করে দেয়, তবে আর এগোবে না
      if (!_channels.containsKey(socketId)) return;

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
      _handleError(socketId, e);
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

///new
class WebSocketServiceOld extends GetxService {
  static WebSocketServiceOld get instance => Get.find<WebSocketServiceOld>();

  // ─── Private State ────────────────────────────────────────────────────────

  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, StreamSubscription> _subscriptions = {}; // 🚀 NEW: মেমোরি লিক রোধ করার জন্য
  final Map<String, bool> _connectionStatus = {};
  final Map<String, String> _socketUrls = {};

  // Callbacks — kept alive across reconnects
  final Map<String, Function(String)> _messageHandlers = {};
  final Map<String, Function()> _connectedCallbacks = {};
  final Map<String, Function()> _disconnectedCallbacks = {};
  final Map<String, Function(dynamic)> _errorCallbacks = {};

  // Reconnect control
  final Map<String, int> _retryCount = {};
  final Map<String, Timer?> _reconnectTimers = {}; // 🚀 NEW: ডাবল রিকানেক্ট রোধ করার জন্য
  static const int _maxRetries = 10; // স্টক মার্কেটের জন্য রিট্রাই বেশি রাখাই ভালো

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    debugPrint('WebSocketService initialized');
  }

  @override
  void onClose() {
    _disconnectAll();
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
    // 1. Clean up stale channel and subscriptions cleanly
    _closeChannel(socketId);
    _cancelReconnectTimer(socketId);

    // 2. Store metadata for auto-reconnect
    _socketUrls[socketId] = url;
    _messageHandlers[socketId] = onMessage;
    if (onConnected != null) _connectedCallbacks[socketId] = onConnected;
    if (onDisconnected != null) _disconnectedCallbacks[socketId] = onDisconnected;
    if (onError != null) _errorCallbacks[socketId] = onError;

    try {
      debugPrint('🔄 Attempting to connect: $socketId to $url');

      final channel = WebSocketChannel.connect(Uri.parse(url));
      _channels[socketId] = channel;

      // 🚀 FIX 1: Wait for the connection to be fully established
      await channel.ready;

      // If we manually disconnected while waiting for `ready`, abort safely.
      if (!_channels.containsKey(socketId)) return;

      _connectionStatus[socketId] = true;
      _retryCount[socketId] = 0; // Reset retry counter on successful connection

      // 🚀 FIX 2: Store subscription to cancel it properly later
      _subscriptions[socketId] = channel.stream.listen(
        (message) {
          _messageHandlers[socketId]?.call(message.toString());
        },
        onError: (error) => _handleError(socketId, error),
        onDone: () => _handleDisconnect(socketId),
        cancelOnError: false,
      );

      _connectedCallbacks[socketId]?.call();
      debugPrint('✅ WebSocket connected successfully: $socketId');
    } catch (e) {
      _handleError(socketId, e);
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
    _removeCallbacks(socketId); // Full cleanup — no reconnect desired
    _cancelReconnectTimer(socketId);

    debugPrint('🔌 Manually disconnected: $socketId');
  }

  /// Whether a socket is currently marked as connected.
  bool isConnected(String socketId) => _connectionStatus[socketId] ?? false;

  /// IDs of all currently connected sockets.
  List<String> getConnectedSockets() => _connectionStatus.entries.where((e) => e.value).map((e) => e.key).toList();

  // ─── Internal Helpers ─────────────────────────────────────────────────────

  void _handleError(String socketId, dynamic error) {
    debugPrint('🚨 WebSocket error ($socketId): $error');
    _connectionStatus[socketId] = false;
    _errorCallbacks[socketId]?.call(error);
    _scheduleReconnect(socketId);
  }

  void _handleDisconnect(String socketId) {
    if ((_connectionStatus[socketId] ?? false) == false) return; // Prevent duplicate calls

    debugPrint('📡 WebSocket disconnected unexpectedly: $socketId');
    _connectionStatus[socketId] = false;
    _disconnectedCallbacks[socketId]?.call();
    _scheduleReconnect(socketId);
  }

  void _scheduleReconnect(String socketId) {
    // 🚀 FIX 3: Prevent overlapping reconnect timers
    _cancelReconnectTimer(socketId);

    final retries = _retryCount[socketId] ?? 0;

    if (retries >= _maxRetries) {
      debugPrint('🛑 Max retries ($retries) reached for $socketId — giving up');
      return;
    }

    // Only reconnect if metadata exists (wasn't manually disconnected)
    if (!_socketUrls.containsKey(socketId) || !_messageHandlers.containsKey(socketId)) {
      return;
    }

    _retryCount[socketId] = retries + 1;

    // Exponential back-off: 2s, 4s, 8s, 16s, 32s (Capped at 30 seconds max delay)
    int delaySeconds = 2 * (retries + 1);
    if (delaySeconds > 30) delaySeconds = 30;

    final delay = Duration(seconds: delaySeconds);
    debugPrint('⏳ Reconnect attempt ${retries + 1}/$_maxRetries for $socketId in ${delay.inSeconds}s');

    _reconnectTimers[socketId] = Timer(delay, () {
      final stillDisconnected = (_connectionStatus[socketId] ?? false) == false;
      if (stillDisconnected) {
        connect(socketId: socketId, url: _socketUrls[socketId]!, onMessage: _messageHandlers[socketId]!);
      }
    });
  }

  void forceReconnect(String socketId) {
    debugPrint('⚡ Forcing immediate reconnect for: $socketId');
    _retryCount[socketId] = 0;
    _cancelReconnectTimer(socketId);

    if (_socketUrls.containsKey(socketId) && _messageHandlers.containsKey(socketId)) {
      connect(socketId: socketId, url: _socketUrls[socketId]!, onMessage: _messageHandlers[socketId]!);
    }
  }

  void _closeChannel(String socketId) {
    // Cancel the stream listener properly
    _subscriptions[socketId]?.cancel();
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
    _connectionStatus.remove(socketId);
  }

  void _disconnectAll() {
    final activeSockets = _channels.keys.toList();
    for (final socketId in activeSockets) {
      _closeChannel(socketId);
      _cancelReconnectTimer(socketId);
    }
    _messageHandlers.clear();
    _connectedCallbacks.clear();
    _disconnectedCallbacks.clear();
    _errorCallbacks.clear();
    _socketUrls.clear();
    _retryCount.clear();
    _connectionStatus.clear();
  }
}


//last update code: 2024-06-17 12:00:00
/*
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

// ─── Socket Config Model ──────────────────────────────────────────────────────

class WebSocketConfig {
  final String socketId;
  final String url;
  final Function(String)? onMessage;
  final Function()? onConnected;
  final Function()? onDisconnected;
  final Function(dynamic)? onError;

  const WebSocketConfig({
    required this.socketId,
    required this.url,
    this.onMessage,
    this.onConnected,
    this.onDisconnected,
    this.onError,
  });
}

// ─── WebSocketService ─────────────────────────────────────────────────────────

class WebSocketService extends GetxService with WidgetsBindingObserver {
  static WebSocketService get instance => Get.find();

  // Raw channels
  final Map<String, WebSocketChannel> _channels = {};

  // FIX #1 — StreamSubscription tracked explicitly, cancelled on close
  final Map<String, StreamSubscription> _subscriptions = {};

  // FIX #2 — Confirmed connected only after ready future resolves
  final Map<String, bool> _connectionStatus = {};

  // Socket metadata
  final Map<String, WebSocketConfig> _configs = {};

  // Reconnect control
  final Map<String, int> _retryCount = {};
  final Map<String, bool> _manuallyDisconnected = {};
  static const int _maxRetries = 5;

  // FIX #5 — Broadcast StreamControllers for reactive/stream-based listeners
  final Map<String, StreamController<String>> _streamControllers = {};

  // FIX #6 — Connectivity
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;
  bool _hasInternet = true;

  // ─── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    // FIX #7 — App lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // FIX #6 — Listen to connectivity changes
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);

    debugPrint('WebSocketService initialized');
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub.cancel();
    _disconnectAll();
    super.onClose();
    debugPrint('WebSocketService closed');
  }

  // FIX #7 — Pause sockets when app goes to background, resume on foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      debugPrint('📱 App backgrounded — pausing all sockets');
      for (final id in _configs.keys.toList()) {
        _closeChannel(id); // close channel but keep config
      }
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed — reconnecting all sockets');
      for (final id in _configs.keys.toList()) {
        if (!(_manuallyDisconnected[id] ?? false)) {
          _reconnect(id);
        }
      }
    }
  }

  // FIX #6 — React to connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final nowOnline = results.any((r) => r != ConnectivityResult.none);

    if (!_hasInternet && nowOnline) {
      debugPrint('🌐 Internet restored — reconnecting sockets');
      for (final id in _configs.keys.toList()) {
        if (!(_manuallyDisconnected[id] ?? false) &&
            !(_connectionStatus[id] ?? false)) {
          _retryCount[id] = 0; // reset retries on fresh network
          _reconnect(id);
        }
      }
    }

    if (_hasInternet && !nowOnline) {
      debugPrint('🚫 Internet lost — pausing reconnect attempts');
    }

    _hasInternet = nowOnline;
  }

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Connect a named socket.
  Future<void> connect({
    required String socketId,
    required String url,
    Function(String)? onMessage,
    Function()? onConnected,
    Function()? onDisconnected,
    Function(dynamic)? onError,
  }) async {
    _manuallyDisconnected[socketId] = false;

    // Store config for reconnects
    _configs[socketId] = WebSocketConfig(
      socketId: socketId,
      url: url,
      onMessage: onMessage,
      onConnected: onConnected,
      onDisconnected: onDisconnected,
      onError: onError,
    );

    // FIX #5 — Create broadcast StreamController if not exists
    if (!_streamControllers.containsKey(socketId)) {
      _streamControllers[socketId] = StreamController<String>.broadcast();
    }

    _retryCount[socketId] = 0;
    await _openChannel(socketId);
  }

  /// Send a plain text message.
  void sendMessage(String socketId, String message) {
    // FIX #2 — Guard with confirmed status
    if (_connectionStatus[socketId] ?? false) {
      try {
        _channels[socketId]!.sink.add(message);
      } catch (e) {
        debugPrint('❌ Send failed ($socketId): $e');
        _handleError(socketId, e);
      }
    } else {
      debugPrint('⚠️ Cannot send — $socketId not connected');
    }
  }

  // FIX #4 — JSON helper
  void sendJson(String socketId, Map<String, dynamic> data) {
    sendMessage(socketId, jsonEncode(data));
  }

  /// Graceful manual disconnect — suppresses auto-reconnect.
  void disconnect(String socketId) {
    _manuallyDisconnected[socketId] = true;
    _closeChannel(socketId);
    _configs.remove(socketId);
    _retryCount.remove(socketId);
    _streamControllers[socketId]?.close();
    _streamControllers.remove(socketId);
    debugPrint('🔌 Manually disconnected: $socketId');
  }

  // FIX #5 — Expose broadcast stream for reactive listeners
  Stream<String>? messageStream(String socketId) {
    return _streamControllers[socketId]?.stream;
  }

  bool isConnected(String socketId) => _connectionStatus[socketId] ?? false;

  List<String> getConnectedSockets() => _connectionStatus.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  // ─── Internal Channel Management ────────────────────────────────────────────

  Future<void> _openChannel(String socketId) async {
    _closeChannel(socketId); // clean up any stale channel first

    final config = _configs[socketId];
    if (config == null) return;

    try {
      final channel = WebSocketChannel.connect(Uri.parse(config.url));
      _channels[socketId] = channel;

      // FIX #2 — Wait for the WebSocket handshake to complete
      await channel.ready;
      _connectionStatus[socketId] = true;

      debugPrint('✅ WebSocket connected: $socketId');
      config.onConnected?.call();

      // FIX #1 — Store subscription so we can cancel it explicitly
      // FIX #9 — cancelOnError: true  (stream closes on error, _handleError reconnects)
      final sub = channel.stream.listen(
        (message) {
          final raw = message.toString();
          config.onMessage?.call(raw);
          // FIX #5 — also push into broadcast stream
          _streamControllers[socketId]?.add(raw);
        },
        onError: (error) => _handleError(socketId, error),
        onDone: () => _handleDisconnect(socketId),
        cancelOnError: true, // FIX #9
      );

      _subscriptions[socketId] = sub;
    } catch (e) {
      _handleError(socketId, e);
    }
  }

  /// Closes only the raw channel + subscription. Keeps config & stream controller.
  void _closeChannel(String socketId) {
    // FIX #1 — Cancel subscription before closing sink
    _subscriptions[socketId]?.cancel();
    _subscriptions.remove(socketId);

    if (_channels.containsKey(socketId)) {
      try {
        _channels[socketId]!.sink.close(ws_status.normalClosure);
      } catch (_) {}
      _channels.remove(socketId); // FIX #8 — only removed here, not in disconnect()
    }

    _connectionStatus.remove(socketId);
  }

  void _handleError(String socketId, dynamic error) {
    debugPrint('🚨 WebSocket error ($socketId): $error');
    _connectionStatus[socketId] = false;
    _configs[socketId]?.onError?.call(error);
    _scheduleReconnect(socketId);
  }

  void _handleDisconnect(String socketId) {
    debugPrint('🔌 WebSocket disconnected: $socketId');
    _connectionStatus[socketId] = false;
    _configs[socketId]?.onDisconnected?.call();
    _scheduleReconnect(socketId);
  }

  void _scheduleReconnect(String socketId) {
    // Don't reconnect if manually disconnected
    if (_manuallyDisconnected[socketId] ?? false) return;

    // Don't reconnect if no internet
    if (!_hasInternet) {
      debugPrint('⏸️ No internet — skipping reconnect for $socketId');
      return;
    }

    final retries = _retryCount[socketId] ?? 0;
    if (retries >= _maxRetries) {
      debugPrint('🛑 Max retries reached for $socketId');
      return;
    }

    if (!_configs.containsKey(socketId)) return;

    _retryCount[socketId] = retries + 1;

    // FIX #3 — True exponential backoff with jitter: 2^n seconds + random ms
    final expSeconds = 1 << (retries + 1); // 2, 4, 8, 16, 32
    final jitter = (100 * (retries + 1)); // small jitter in ms
    final delay = Duration(seconds: expSeconds, milliseconds: jitter);

    debugPrint(
        '🔄 Retry ${retries + 1}/$_maxRetries for $socketId in ${delay.inSeconds}s');

    Future.delayed(delay, () {
      final stillDown = (_connectionStatus[socketId] ?? false) == false;
      final notManual = !(_manuallyDisconnected[socketId] ?? false);
      final hasConfig = _configs.containsKey(socketId);

      if (stillDown && notManual && hasConfig && _hasInternet) {
        _reconnect(socketId);
      }
    });
  }

  void _reconnect(String socketId) {
    final config = _configs[socketId];
    if (config == null) return;
    _openChannel(socketId);
  }

  void _disconnectAll() {
    for (final id in _channels.keys.toList()) {
      _closeChannel(id);
    }
    for (final sc in _streamControllers.values) {
      sc.close();
    }
    _streamControllers.clear();
    _configs.clear();
    _retryCount.clear();
    _manuallyDisconnected.clear();
    _connectionStatus.clear();
  }
}
*/