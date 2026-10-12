/// Maintains the sector options discovered from live market quotes.
class MarketSectorFilterStore {
  MarketSectorFilterStore({List<String>? sectors})
    : sectors = sectors ?? <String>[];

  final List<String> sectors;

  /// Adds a sector when it is eligible and not already present.
  ///
  /// Returns true only when the visible options changed.
  bool addSector(String? sector) {
    if (sector == null || sector.isEmpty) return false;
    if (sector == 'TBond' || sector == 'CorpBond') return false;
    if (sectors.contains(sector)) return false;
    sectors.add(sector);
    return true;
  }

  void reset() {
    sectors
      ..clear()
      ..add('All');
  }
}
