
import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'time_sales_sort.dart';

class TimeAndSalesBarChart extends StatefulWidget {
  /// bucket size in seconds (e.g., 30 => 30s buckets)
  final int bucketSeconds;

  /// if true chart Y will use price*volume (value) instead of volume
  final bool usePriceValue;

  /// maximum number of buckets to render (for performance)
  final int maxBuckets;

  const TimeAndSalesBarChart({super.key, this.bucketSeconds = 30, this.usePriceValue = false, this.maxBuckets = 300});

  @override
  State<TimeAndSalesBarChart> createState() => _TimeAndSalesBarChartState();
}

class _TimeAndSalesBarChartState extends State<TimeAndSalesBarChart> {
  final HomeController homeCont = Get.find<HomeController>();

  DateTime _parseTstToToday(String? tst) {
    if (tst == null) return DateTime.now();
    try {
      final parts = tst.split('.');
      final hhmmss = parts[0];
      final seg = hhmmss.split(':');
      final h = int.tryParse(seg[0]) ?? 0;
      final m = int.tryParse(seg[1]) ?? 0;
      final s = int.tryParse(seg[2]) ?? 0;
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, h, m, s);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// aggregate raw ticks into time buckets
  List<_Bucket> _aggregateBuckets(List<TimeAndSalesModel> raw, int bucketSeconds) {
    if (raw.isEmpty) return [];

    // sort by time ascending
    sortTimeSalesByKey(raw, (t) => _parseTstToToday(t.tst), (a, b) => a.compareTo(b));

    final buckets = <int, _Bucket>{}; // key = epochSeconds of bucket start
    for (var tick in raw) {
      final dt = _parseTstToToday(tick.tst);
      final epoch = dt.millisecondsSinceEpoch;
      final bucketStartEpoch = (epoch ~/ (bucketSeconds * 1000)) * (bucketSeconds * 1000);
      final bucketStart = DateTime.fromMillisecondsSinceEpoch(bucketStartEpoch);
      final bucketEnd = dt;

      final price = tick.p ?? 0.0;
      final vol = tick.v ?? 0;
      final value = price * vol;

      final key = bucketStartEpoch;
      if (!buckets.containsKey(key)) {
        buckets[key] = _Bucket(
          start: bucketStart,
          end: bucketEnd,
          open: price,
          high: price,
          low: price,
          close: price,
          volumeSum: vol,
          valueSum: value,
        );
      } else {
        final b = buckets[key]!;
        b.end = bucketEnd;
        b.close = price;
        if (price > b.high) b.high = price;
        if (price < b.low) b.low = price;
        b.volumeSum += vol;
        b.valueSum += value;
      }
    }

    // sort buckets by start time ascending
    final sortedKeys = buckets.keys.toList()..sort();
    final list = sortedKeys.map((k) => buckets[k]!).toList();

    // keep only last maxBuckets if there are too many
    if (list.length > widget.maxBuckets) {
      return list.sublist(list.length - widget.maxBuckets);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return VisibleGetBuilder<HomeController>(
      id: 'timeAndSales',
      builder: (_) {
        final raw = List<TimeAndSalesModel>.from(homeCont.timeAndSales);
        if (raw.isEmpty) return const Center(child: Text('No trades'));

        final buckets = _aggregateBuckets(raw, widget.bucketSeconds);
        if (buckets.isEmpty) return const Center(child: Text('No buckets'));

        // Prepare chart data: x = bucket.start, y = volumeSum (or valueSum)
        final chartData = buckets.map((b) {
          final y = widget.usePriceValue ? b.valueSum : b.volumeSum.toDouble();
          final up = b.close >= b.open;
          return _BarPoint(time: b.start, y: y, color: up ? Colors.green : Colors.red, open: b.open, close: b.close);
        }).toList();

        final ys = chartData.map((e) => e.y).toList();
        double minY = ys.reduce((a, b) => a < b ? a : b);
        double maxY = ys.reduce((a, b) => a > b ? a : b);
        if (minY == maxY) {
          minY = 0;
          maxY = maxY == 0 ? 1 : maxY * 1.2;
        } else {
          final pad = (maxY - minY) * 0.08;
          minY = (minY - pad).clamp(0, double.infinity);
          maxY = maxY + pad;
        }

        return SizedBox(
          height: 260,
          child: SfCartesianChart(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            plotAreaBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            plotAreaBorderWidth: 0,
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.minutes,
              interval: widget.bucketSeconds.toDouble(),
              dateFormat: DateFormat('HH:mm'),
              majorGridLines: MajorGridLines(color: Colors.grey.alphaSafe(0.12), width: 1),
              labelRotation: -45,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
            ),
            primaryYAxis: NumericAxis(
              minimum: minY,
              maximum: maxY,
              numberFormat: NumberFormat.compact(),
              majorGridLines: MajorGridLines(color: Colors.grey.alphaSafe(0.12), width: 1),
            ),

            series: <CartesianSeries<dynamic, dynamic>>[
              ColumnSeries<_BarPoint, DateTime>(
                dataSource: chartData,
                xValueMapper: (_BarPoint p, _) => p.time,
                yValueMapper: (_BarPoint p, _) => p.y,
                pointColorMapper: (_BarPoint p, _) => p.color,
                width: 0.75, // fraction of bucket width (0..1)
                borderRadius: BorderRadius.circular(6),
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y'),
          ),
        );
      },
    );
  }
}

class _BarPoint {
  final DateTime time;
  final double y;
  final Color color;
  final double open;
  final double close;
  _BarPoint({required this.time, required this.y, required this.color, required this.open, required this.close});
}

/// Bar bucket aggregation
class _Bucket {
  final DateTime start; // bucket start time
  DateTime end; // last time seen
  double open;
  double high;
  double low;
  double close;
  int volumeSum;
  double valueSum; // sum(price * volume) if you want value
  _Bucket({
    required this.start,
    required this.end,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volumeSum,
    required this.valueSum,
  });
}
