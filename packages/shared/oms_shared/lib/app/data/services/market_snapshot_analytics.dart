import '../models/response/market_model.dart';

class MarketDistributionSummary {
  const MarketDistributionSummary({
    required this.counts,
    required this.total,
    required this.maxCount,
  });

  final List<int> counts;
  final int total;
  final int maxCount;
}

/// Calculates chart aggregates from a snapshot of the latest market quotes.
class MarketSnapshotAnalytics {
  MarketDistributionSummary? calculateMovementDistribution(
    List<MarketModel> marketItems,
    List<Bucket> buckets,
  ) {
    if (buckets.isEmpty) return null;

    final counts = List<int>.filled(buckets.length, 0);
    var total = 0;
    var maxCount = 0;

    for (final model in marketItems) {
      if (model.group == 'PUBLIC' &&
          (model.board == 'Main Board' || model.board == 'Small Cap Board')) {
        final value = model.d ?? 0.0;
        final index = buckets.indexWhere((bucket) {
          if (bucket.isCenter) return value == 0.0;
          if (bucket.min == double.negativeInfinity) return value < bucket.max;
          if (bucket.max == double.infinity) return value >= bucket.min;
          return value >= bucket.min && value < bucket.max;
        });

        final indexToCount = index >= 0
            ? index
            : buckets.indexWhere((bucket) => bucket.isCenter);
        if (indexToCount >= 0) {
          counts[indexToCount]++;
          total++;
          if (counts[indexToCount] > maxCount) {
            maxCount = counts[indexToCount];
          }
        }
      }
    }

    return MarketDistributionSummary(
      counts: counts,
      total: total,
      maxCount: maxCount,
    );
  }

  List<Map<String, dynamic>> calculateSectorGainers(
    List<MarketModel> marketItems,
  ) {
    final sectorStats = <String, Map<String, int>>{};

    for (final model in marketItems) {
      if ((model.volume ?? 0) <= 0 &&
          (model.trades ?? 0) <= 0 &&
          (model.val ?? 0) <= 0) {
        continue;
      }
      if (model.board != 'Main Board' && model.board != 'Small Cap Board') {
        continue;
      }
      if (model.instrumentType != 'EQ' && model.instrumentType != 'MF') {
        continue;
      }

      var sectorName = model.sector?.trim();
      if (sectorName == null ||
          sectorName.isEmpty ||
          sectorName.contains('Bond') ||
          num.tryParse(sectorName) != null ||
          RegExp(r'^[0-9\.\-\s]+$').hasMatch(sectorName)) {
        continue;
      }
      if (model.board == 'Small Cap Board') sectorName = 'SME';

      sectorStats.putIfAbsent(
        sectorName,
        () => {'up': 0, 'down': 0, 'equal': 0},
      );

      var changeValue = model.chg ?? 0.0;
      if (changeValue == 0.0 &&
          model.last != null &&
          model.reference != null &&
          model.reference! > 0) {
        changeValue = model.last! - model.reference!;
      }

      if (changeValue > 0) {
        sectorStats[sectorName]!['up'] = sectorStats[sectorName]!['up']! + 1;
      } else if (changeValue < 0) {
        sectorStats[sectorName]!['down'] =
            sectorStats[sectorName]!['down']! + 1;
      } else {
        sectorStats[sectorName]!['equal'] =
            sectorStats[sectorName]!['equal']! + 1;
      }
    }

    final formattedData = sectorStats.entries.map((entry) {
      final up = entry.value['up']!;
      final down = entry.value['down']!;
      final equal = entry.value['equal']!;
      return {
        'sector': entry.key,
        'up': up.toDouble(),
        'down': down.toDouble(),
        'equal': equal.toDouble(),
        'total': (up + down + equal).toDouble(),
      };
    }).toList();

    formattedData.sort((a, b) {
      final upCompare = (b['up'] as double).compareTo(a['up'] as double);
      if (upCompare != 0) return upCompare;
      return (b['total'] as double).compareTo(a['total'] as double);
    });
    return formattedData;
  }

  List<Map<String, dynamic>> calculateSectorShareTypeValues(
    List<MarketModel> marketItems,
  ) {
    final sectorStats = <String, Map<String, double>>{};

    for (final model in marketItems) {
      if ((model.volume ?? 0) <= 0 &&
          (model.trades ?? 0) <= 0 &&
          (model.val ?? 0) <= 0) {
        continue;
      }
      if (model.board != 'Main Board' && model.board != 'Small Cap Board') {
        continue;
      }
      if (model.instrumentType != 'EQ' && model.instrumentType != 'MF') {
        continue;
      }

      var sectorName = model.sector;
      final shareType = model.shareType?.toUpperCase();
      if (sectorName == null ||
          sectorName.isEmpty ||
          sectorName == 'TBond' ||
          double.tryParse(sectorName) != null) {
        continue;
      }
      if (!const ['A', 'B', 'N', 'Z'].contains(shareType)) continue;
      if (model.board == 'Small Cap Board') sectorName = 'SME';

      sectorStats.putIfAbsent(
        sectorName,
        () => {'A': 0.0, 'B': 0.0, 'N': 0.0, 'Z': 0.0},
      );
      var stockValue = model.val ?? 0.0;
      if (stockValue.isNaN || stockValue.isInfinite) stockValue = 0.0;
      sectorStats[sectorName]![shareType!] =
          sectorStats[sectorName]![shareType]! + stockValue / 1000000;
    }

    final formattedData = sectorStats.entries.map((entry) {
      final a = entry.value['A']!;
      final b = entry.value['B']!;
      final n = entry.value['N']!;
      final z = entry.value['Z']!;
      return {
        'sector': entry.key,
        'A': a,
        'B': b,
        'N': n,
        'Z': z,
        'total': a + b + n + z,
      };
    }).toList();

    formattedData.sort(
      (a, b) => (b['total'] as double).compareTo(a['total'] as double),
    );
    return formattedData;
  }
}
