import 'dart:convert';

import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:sse_channel/sse_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;
// import 'package:web_socket_channel/web_socket_channel.dart';

import '../../app_pkg.dart';

/*

class SSEService extends GetxService {
  static SSEService get instance => Get.find();

  final Map<String, SseChannel> _channels = {};
  final Map<String, bool> _connectionStatus = {};
  final Map<String, Function(String)> _messageHandlers = {};
  final Map<String, Function()> _connectedCallbacks = {};
  final Map<String, Function()> _disconnectedCallbacks = {};
  final Map<String, Function(dynamic)> _errorCallbacks = {};
  final Map<String, String> _socketUrls = {};

  @override
  void onInit() {
    super.onInit();
    print('SSE Service initialized');
  }

  @override
  void onClose() {
    _disconnectAll();
    super.onClose();
    print('SSE Service closed');
  }

  // Connect to SSE with MessageEvent handling
  void connect({
    required String socketId,
    required String url,
    required Function(String) onMessage,
    Function()? onConnected,
    Function()? onDisconnected,
    Function(dynamic)? onError,
  }) {
    try {
      // Close existing connection if any
      if (_channels.containsKey(socketId)) {
        _safeClose(socketId);
      }

      // Create SSE channel
      final channel = SseChannel.connect(Uri.parse(url));
      _channels[socketId] = channel;
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

      // Listen to SSE messages - Handle MessageEvent with null safety
      channel.stream.listen(
            (MessageEvent message) {
          // Handle nullable message.data
          final String? messageData = message.data;

          if (messageData != null && _messageHandlers.containsKey(socketId)) {
            _messageHandlers[socketId]!(messageData);
          } else if (messageData == null) {
            print('⚠️ Null message received from $socketId');
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
      print('✅ SSE connected: $socketId');
    } catch (e) {
      _handleError(socketId, e);
    }
  }

  // Alternative method that provides full MessageEvent access
  void connectWithMessageEvent({
    required String socketId,
    required String url,
    required Function(MessageEvent) onMessage,
    Function()? onConnected,
    Function()? onDisconnected,
    Function(dynamic)? onError,
  }) {
    try {
      if (_channels.containsKey(socketId)) {
        _safeClose(socketId);
      }

      final channel = SseChannel.connect(Uri.parse(url));
      _channels[socketId] = channel;
      _connectionStatus[socketId] = true;
      _socketUrls[socketId] = url;

      channel.stream.listen(
            (MessageEvent message) {
          onMessage(message);
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
      print('✅ SSE connected (Full MessageEvent): $socketId');
    } catch (e) {
      _handleError(socketId, e);
    }
  }

  // Safe close method for SSE
  void _safeClose(String socketId) {
    if (_channels.containsKey(socketId)) {
      try {
        final channel = _channels[socketId]!;
        channel.sink.close();

        _cleanupSocket(socketId);
        _channels.remove(socketId);

        print('🔒 Safely closed SSE: $socketId');
      } catch (e) {
        print('⚠️ Error during safe close of $socketId: $e');
        _cleanupSocket(socketId);
        _channels.remove(socketId);
      }
    }
  }

  // Manual disconnection
  void disconnect(String socketId) {
    if (_channels.containsKey(socketId)) {
      try {
        _safeClose(socketId);
        _connectionStatus[socketId] = false;

        _disconnectedCallbacks[socketId]?.call();

        print('🔌 Manually disconnected SSE: $socketId');
      } catch (e) {
        print('❌ Error disconnecting $socketId: $e');
        _cleanupSocket(socketId);
        _channels.remove(socketId);
      }
    }
  }

  void _handleError(String socketId, dynamic error) {
    print('🚨 SSE error ($socketId): $error');
    _connectionStatus[socketId] = false;
    _errorCallbacks[socketId]?.call(error);

    _scheduleReconnect(socketId);
  }

  void _handleDisconnect(String socketId) {
    print('🔌 SSE disconnected: $socketId');
    _connectionStatus[socketId] = false;
    _disconnectedCallbacks[socketId]?.call();

    _scheduleReconnect(socketId);
  }

  void _scheduleReconnect(String socketId) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!_connectionStatus[socketId]! &&
          _socketUrls.containsKey(socketId) &&
          _messageHandlers.containsKey(socketId)) {
        print('🔄 Auto-reconnecting SSE: $socketId');
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

  // Send message via SSE (if server supports it)
  void sendMessage(String socketId, String message) {
    if (_channels.containsKey(socketId) && _connectionStatus[socketId]!) {
      try {
        _channels[socketId]!.sink.add(message);
        print('📤 Message sent to $socketId: $message');
      } catch (e) {
        print('❌ Error sending message to $socketId: $e');
        print('💡 Note: Some SSE implementations may not support client-to-server messages');
        _handleError(socketId, e);
      }
    } else {
      print('⚠️ Cannot send message - $socketId is not connected');
    }
  }

  void _cleanupSocket(String socketId) {
    _messageHandlers.remove(socketId);
    _connectedCallbacks.remove(socketId);
    _disconnectedCallbacks.remove(socketId);
    _errorCallbacks.remove(socketId);
    _connectionStatus.remove(socketId);
  }

  // Disconnect all sockets
  void _disconnectAll() {
    for (var socketId in _channels.keys.toList()) {
      _safeClose(socketId);
    }
    _channels.clear();
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
    return _connectionStatus.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // Get channel for specific socket
  SseChannel? getChannel(String socketId) {
    return _channels[socketId];
  }

  // Get message event details for debugging
  void printMessageEventDetails(MessageEvent event) {
    print('📨 MessageEvent Details:');
    print('  - Data: ${event.data}');
    print('  - Last Event ID: ${event.id}');
    print('  - Origin: ${event.event}');
  }

  // Helper method to extract data from MessageEvent with null safety
  String? extractMessageData(MessageEvent event) {
    return event.data;
  }

  // Helper method to extract data with default value
  String extractMessageDataWithDefault(MessageEvent event, {String defaultValue = ''}) {
    return event.data ?? defaultValue;
  }
}*/
