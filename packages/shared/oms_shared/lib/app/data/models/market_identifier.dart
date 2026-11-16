/// An exchange instrument identifier.
///
/// DSE currently sends numeric identifiers; CSE can send identifiers such as
/// `CSE_101001462`. Keep the wire representation (and therefore its type)
/// intact. Do not use this value for arithmetic.
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
