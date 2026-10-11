/// Request payload for adding a market instrument to a user's watchlist.
class AddFavItemRequest {
  final int tableId;
  final String ticker;
  final String group;
  final int oderBook;

  AddFavItemRequest({
    required this.tableId,
    required this.ticker,
    required this.group,
    required this.oderBook,
  });

  Map<String, dynamic> toJson() => {
    'table_id': tableId,
    'ticker': ticker,
    'group': group,
    'oder_book': oderBook,
  };
}
