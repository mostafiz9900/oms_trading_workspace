/// An exchange instrument identifier.
///
/// DSE currently sends numeric identifiers; CSE can send identifiers such as
/// `CSE_101001462`. Keep the feed representation (and therefore its type)
/// intact; order requests normalize by exchange. Do not use this for arithmetic.
typedef MarketIdentifier = Object;

/// Preserves exchange identifiers while accepting legacy numeric strings.
MarketIdentifier? marketIdentifierFromJson(Object? value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? value;
  if (value is num && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }
  return null;
}

/// Converts CSE feed IDs to the integer accepted by the order API.
/// Supports `CSE_101001462`, numeric strings, and whole numeric values.
int? cseOrderBookIdToInt(Object? value) {
  if (value is int) return value;
  if (value is num && value.isFinite && value == value.truncateToDouble()) {
    return value.toInt();
  }
  if (value is String) {
    final numericPart = value.startsWith('CSE_') ? value.substring(4) : value;
    return int.tryParse(numericPart);
  }
  return null;
}
