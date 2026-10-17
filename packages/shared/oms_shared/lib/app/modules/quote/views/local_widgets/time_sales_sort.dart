import '../../../../data/models/response/time_sales_model.dart';

/// Sorts [list] in place by a key parsed once per element, instead of
/// re-parsing both timestamps on every comparison. Same order as before.
void sortTimeSalesByKey<K>(
  List<TimeAndSalesModel> list,
  K Function(TimeAndSalesModel) key,
  int Function(K, K) compare,
) {
  final keyed = [for (final t in list) (t, key(t))];
  keyed.sort((a, b) => compare(a.$2, b.$2));
  for (var i = 0; i < list.length; i++) {
    list[i] = keyed[i].$1;
  }
}
