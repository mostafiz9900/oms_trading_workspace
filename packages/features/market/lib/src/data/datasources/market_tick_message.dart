import 'dart:convert';

/// Kind of market event encoded in a websocket message.
enum MarketTickKind { session, heartbeat, marketIndex, quote, other }

/// Decoded market websocket envelope; transport and UI effects stay app-owned.
class MarketTickMessage {
  const MarketTickMessage({required this.kind, required this.payload});

  final MarketTickKind kind;
  final Map<String, dynamic> payload;

  factory MarketTickMessage.decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException(
        'Market websocket message must be an object.',
      );
    }

    final payload = Map<String, dynamic>.from(decoded);
    final kind = switch (true) {
      _ when payload['cs'] != null => MarketTickKind.session,
      _ when payload['message_type'] == 'itch_heartbeat' =>
        MarketTickKind.heartbeat,
      _ when payload['b'] == 'INDEX' => MarketTickKind.marketIndex,
      _ when payload['ob'] != null => MarketTickKind.quote,
      _ => MarketTickKind.other,
    };
    return MarketTickMessage(kind: kind, payload: payload);
  }
}
