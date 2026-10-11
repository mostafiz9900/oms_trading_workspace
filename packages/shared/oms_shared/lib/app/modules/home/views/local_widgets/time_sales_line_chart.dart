import 'dart:math';

import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../controllers/historical_volume_controller.dart';
import 'historical/price_table_tab_widget.dart';

// FastLineChart widget
class FastLineChart extends StatefulWidget {
  const FastLineChart({super.key});
  @override
  State<FastLineChart> createState() => _FastLineChartState();
}

class _FastLineChartState extends State<FastLineChart> {
  final HomeController homeCont = Get.find<HomeController>();
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(enablePanning: true, enablePinching: true, zoomMode: ZoomMode.x);

    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(enable: true, format: 'point.x : point.y'),
    );
  }

  DateTime _parseTst(String? tst) {
    if (tst == null) return DateTime.now();
    try {
      final parts = tst.split('.');
      final hhmmss = parts[0]; // '14:26:55'
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

  // here a simple uniform sampling to keep example short.
  List<_ChartPoint> _downsampleIfNeeded(List<_ChartPoint> pts, {int threshold = 1500}) {
    if (pts.length <= threshold) return pts;
    final step = (pts.length / threshold).ceil();
    final res = <_ChartPoint>[];
    for (var i = 0; i < pts.length; i += step) {
      res.add(pts[i]);
    }
    // ensure last point included
    if (res.isEmpty || res.last != pts.last) res.add(pts.last);
    return res;
  }

  List<_ChartPoint> _buildChartData() {
    final raw = homeCont.timeAndSales;
    if (raw.isEmpty) return [];

    // sort by time
    raw.sort((a, b) => _parseTst(a.tst).compareTo(_parseTst(b.tst)));

    final points = raw.map((e) {
      return _ChartPoint(xDate: _parseTst(e.tst), y: e.p ?? 0.0, index: 0, label: '', volume: null);
    }).toList();
    return _downsampleIfNeeded(points, threshold: 1500);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'timeAndSales',
      builder: (_) {
        final data = _buildChartData();
        if (data.isEmpty) return const Center(child: CircularProgressIndicator());
        final ys = data.map((e) => e.y).toList();
        final minY = ys.reduce((a, b) => a < b ? a : b);
        final maxY = ys.reduce((a, b) => a > b ? a : b);
        double alignToStep(double value, double step) {
          return (value / step).floor() * step;
        }

        double alignToStepCeil(double value, double step) {
          return (value / step).ceil() * step;
        }

        final step = 0.10;
        final alignedMin = alignToStep(minY, step);
        final alignedMax = alignToStepCeil(maxY, step);
        final paddedMax = alignedMax + (step * 1);

        return Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              mainAxisAlignment: .end,
              children: [
                AppSpace.spaceW10,
                Expanded(
                  child: Text(
                    homeCont.marketData.shortName ?? '',
                    style: Get.textTheme.bodyLarge?.copyWith(color: context.buttonColor),
                  ),
                ),
                IconButton(
                  onPressed: () => _zoomPanBehavior.zoomOut(),
                  icon: Icon(Icons.zoom_out, color: context.buttonColor),
                ),
                IconButton(
                  onPressed: () => _zoomPanBehavior.reset(),
                  icon: Icon(Icons.refresh, color: context.buttonColor),
                ),
                IconButton(
                  onPressed: () => _zoomPanBehavior.zoomIn(),
                  icon: Icon(Icons.zoom_in, color: context.buttonColor),
                ),
                const SizedBox(width: 8),
              ],
            ),

            SizedBox(
              child: SfCartesianChart(
                backgroundColor: context.bgColor,
                plotAreaBackgroundColor: context.bgColor,
                plotAreaBorderWidth: 0,
                zoomPanBehavior: _zoomPanBehavior,
                trackballBehavior: _trackballBehavior,
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.minutes,
                  interval: 30,
                  dateFormat: DateFormat('HH:mm'),
                  labelRotation: -90,
                  majorGridLines: MajorGridLines(color: context.isDark ? Colors.white12 : Colors.black12, width: 0.5),
                  labelStyle: TextStyle(color: context.textColor),
                ),
                primaryYAxis: NumericAxis(
                  minimum: alignedMin,
                  maximum: paddedMax,
                  interval: step,
                  opposedPosition: true,
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  numberFormat: NumberFormat("##0.00"),
                  majorGridLines: MajorGridLines(color: context.isDark ? Colors.white12 : Colors.black12, width: 0.5),
                  minorGridLines: MinorGridLines(color: Colors.grey.alphaSafe(0.08), width: 0.5),
                  labelStyle: TextStyle(color: context.textColor, fontSize: 11),
                ),

                // USE FastLineSeries for speed
                series: <CartesianSeries<dynamic, dynamic>>[
                  // StepLineSeries,AreaSeries,SplineAreaSeries,SplineAreaSeries
                  //RangeAreaSeries,StackedLineSeries
                  AreaSeries<_ChartPoint, DateTime>(
                    dataSource: data,
                    xValueMapper: (_ChartPoint p, _) => p.xDate,
                    yValueMapper: (_ChartPoint p, _) => p.y,
                    color: Colors.green,
                    borderColor: Colors.green.shade800,
                    borderWidth: 1.6,
                    isVisibleInLegend: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.green.shade300.alphaSafe(0.99), // top stronger
                        Colors.green.shade200.alphaSafe(0.45),
                        Colors.green.shade100.alphaSafe(0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.25, 0.65, 1.0],
                    ),
                    animationDuration: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
//

// Simple helper model
class _ChartPoint {
  final int index;
  final String label;
  final DateTime xDate;
  final double y;
  final dynamic volume;
  final String? id;
  _ChartPoint({
    required this.index,
    required this.label,
    required this.xDate,
    required this.y,
    required this.volume,
    this.id,
  });
}

// Make sure TimeAndSalesModel and HomeController are imported/defined in your project.

// --- Your widget (full updated state class) ---
class FastLineWithBarChart extends StatefulWidget {
  const FastLineWithBarChart({super.key});
  @override
  State<FastLineWithBarChart> createState() => _FastLineWithBarChartState();
}

class _FastLineWithBarChartState extends State<FastLineWithBarChart> {
  final HomeController homeCont = Get.find<HomeController>();
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  // State variable to toggle between 1D and 1Y
  bool _show1D = true;

  final int bucketSeconds = 30;
  final int maxBuckets = 300;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(enablePanning: true, enablePinching: true, zoomMode: ZoomMode.x);

    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(enable: true, format: 'point.x : point.y'),
    );
  }

  DateTime _parseTst(String? tst) {
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

  List<_PricePoint> _downsampleIfNeeded(List<_PricePoint> pts, {int threshold = 1500}) {
    if (pts.length <= threshold) return pts;
    final step = (pts.length / threshold).ceil();
    final res = <_PricePoint>[];
    for (var i = 0; i < pts.length; i += step) {
      res.add(pts[i]);
    }
    if (res.isEmpty || res.last.xDate != pts.last.xDate) res.add(pts.last);
    return res;
  }

  List<_PricePoint> _buildPricePoints() {
    final raw = List<TimeAndSalesModel>.from(homeCont.timeAndSales);
    if (raw.isEmpty) return [];
    raw.sort((a, b) => _parseTst(a.tst).compareTo(_parseTst(b.tst)));
    final pts = raw.map((e) => _PricePoint(xDate: _parseTst(e.tst), y: e.p ?? 0.0, volume: e.v ?? 0)).toList();
    return _downsampleIfNeeded(pts, threshold: 2000);
  }

  List<_VolBucket> _aggregateVolumeBuckets(List<TimeAndSalesModel> raw, int bucketSeconds, {int keepLast = 300}) {
    if (raw.isEmpty) return [];
    raw.sort((a, b) => _parseTst(a.tst).compareTo(_parseTst(b.tst)));

    final Map<int, _VolBucket> map = {};
    for (final t in raw) {
      final dt = _parseTst(t.tst);
      final epoch = dt.millisecondsSinceEpoch;
      final bucketStartEpoch = (epoch ~/ (bucketSeconds * 1000)) * (bucketSeconds * 1000);
      final key = bucketStartEpoch;
      final price = t.p ?? 0.0;
      final vol = (t.v ?? 0);
      if (!map.containsKey(key)) {
        map[key] = _VolBucket(
          start: DateTime.fromMillisecondsSinceEpoch(key),
          volume: vol.toDouble(),
          open: price,
          high: price,
          low: price,
          close: price,
        );
      } else {
        final b = map[key]!;
        b.volume += vol;
        b.close = price;
        if (price > b.high) b.high = price;
        if (price < b.low) b.low = price;
      }
    }

    final keys = map.keys.toList()..sort();
    final list = keys.map((k) => map[k]!).toList();
    if (list.length > keepLast) return list.sublist(list.length - keepLast);
    return list;
  }

  double _alignFloor(double value, double step) => (value / step).floorToDouble() * step;
  double _alignCeil(double value, double step) => (value / step).ceilToDouble() * step;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'timeAndSales',
      builder: (_) {
        final pricePts = _buildPricePoints();
        if (pricePts.isEmpty) return const Center(child: CircularProgressIndicator());

        final rawTicks = List<TimeAndSalesModel>.from(homeCont.timeAndSales);
        final volBuckets = _aggregateVolumeBuckets(rawTicks, bucketSeconds, keepLast: maxBuckets);

        final volSeriesData = <_VolPoint>[];
        for (int i = 0; i < volBuckets.length; i++) {
          final b = volBuckets[i];
          final prevClose = (i > 0) ? volBuckets[i - 1].close : b.open;
          volSeriesData.add(
            _VolPoint(time: b.start, volume: b.volume, open: b.open, close: b.close, previousClose: prevClose),
          );
        }

        final ys = pricePts.map((e) => e.y).toList();
        double minY = ys.reduce((a, b) => a < b ? a : b);
        double maxY = ys.reduce((a, b) => a > b ? a : b);
        if ((maxY - minY).abs() < 1e-8) {
          minY -= 1.0;
          maxY += 1.0;
        }
        final rawRange = maxY - minY;
        final pad = max(rawRange * 0.12, 0.05);
        final paddedMin = minY - pad;
        final paddedMax = maxY + pad;

        final step = 0.10;
        final alignedMin = _alignFloor(paddedMin, step);
        final alignedMax = _alignCeil(paddedMax, step);
        final paddedMaxForLabel = alignedMax + step;

        final volYs = volSeriesData.map((e) => e.volume).toList();
        double volMax = volYs.isEmpty ? 1.0 : volYs.reduce((a, b) => a > b ? a : b);
        final volAxisMax = (volMax * 1.12).ceilToDouble();

        final upColor = ColorConstants.upColor;
        final downColor = ColorConstants.downColor;
        final equalColor = ColorConstants.unchangedColor;
        const eps = 1e-8;

        volSeriesData.sort((a, b) => a.time.compareTo(b.time));

        final volMidPoints = volSeriesData.map((p) {
          final mid = p.time.add(Duration(seconds: (bucketSeconds / 2).floor()));
          return _VolPoint(time: mid, volume: p.volume, open: p.open, close: p.close, previousClose: p.previousClose);
        }).toList();

        return ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppSpace.spaceW10,
                Expanded(
                  child: Text(
                    homeCont.marketData.shortName ?? '',
                    style: Get.textTheme.bodyLarge?.copyWith(color: context.buttonColor),
                  ),
                ),

                // // Show zoom controls only when 1D is selected
                const SizedBox(width: 8),
                // --- 1D and 1Y Toggle Buttons ---
                TextButton(
                  onPressed: () => setState(() => _show1D = true),
                  style: TextButton.styleFrom(
                    backgroundColor: _show1D ? context.buttonColor?.withOpacity(0.15) : Colors.transparent,
                    minimumSize: const Size(44, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(
                    '1D',
                    style: TextStyle(
                      color: _show1D ? context.buttonColor : Colors.grey,
                      fontWeight: _show1D ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                TextButton(
                  onPressed: () => setState(() => _show1D = false),
                  style: TextButton.styleFrom(
                    backgroundColor: !_show1D ? context.buttonColor?.withOpacity(0.15) : Colors.transparent,
                    minimumSize: const Size(44, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(
                    '1Y',
                    style: TextStyle(
                      color: !_show1D ? context.buttonColor : Colors.grey,
                      fontWeight: !_show1D ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Conditionally display 1D or 1Y section
            if (_show1D) ...[
              // 1D Chart
              SizedBox(
                height: 360,
                child: SfCartesianChart(
                  backgroundColor: context.bgColor,
                  plotAreaBackgroundColor: context.bgColor,
                  plotAreaBorderWidth: 0,
                  zoomPanBehavior: _zoomPanBehavior,
                  trackballBehavior: _trackballBehavior,
                  primaryXAxis: DateTimeAxis(
                    intervalType: DateTimeIntervalType.minutes,
                    interval: bucketSeconds.toDouble(),
                    dateFormat: DateFormat('HH:mm'),
                    labelRotation: -45,
                    majorGridLines: MajorGridLines(color: context.isDark ? Colors.white12 : Colors.black12, width: 0.5),
                    labelStyle: TextStyle(color: context.textColor, fontSize: 11),
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: alignedMin,
                    maximum: paddedMaxForLabel,
                    interval: step,
                    opposedPosition: true,
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    numberFormat: NumberFormat("##0.0"),
                    majorGridLines: MajorGridLines(color: context.isDark ? Colors.white12 : Colors.black12, width: 0.5),
                    minorGridLines: MinorGridLines(color: Colors.grey.alphaSafe(0.08), width: 0.5),
                    labelStyle: TextStyle(color: context.textColor, fontSize: 11),
                  ),
                  axes: <ChartAxis>[
                    NumericAxis(
                      name: 'volumeAxis',
                      minimum: 0,
                      maximum: volAxisMax,
                      opposedPosition: false,
                      interval: (volAxisMax / 16).ceilToDouble(),
                      numberFormat: NumberFormat.compact(),
                      majorGridLines: MajorGridLines(color: Colors.transparent),
                      labelStyle: TextStyle(color: context.textColor, fontSize: 11),
                    ),
                  ],
                  series: <CartesianSeries>[
                    ColumnSeries<_VolPoint, DateTime>(
                      dataSource: volMidPoints,
                      xValueMapper: (_VolPoint p, _) => p.time,
                      yValueMapper: (_VolPoint p, _) => p.volume,
                      yAxisName: 'volumeAxis',
                      pointColorMapper: (_VolPoint p, _) {
                        if ((p.close - p.previousClose) > eps) return upColor;
                        if ((p.previousClose - p.close) > eps) return downColor;
                        return equalColor;
                      },
                      width: 0.9,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    FastLineSeries<_PricePoint, DateTime>(
                      dataSource: pricePts,
                      xValueMapper: (_PricePoint p, _) => p.xDate,
                      yValueMapper: (_PricePoint p, _) => p.y,
                      color: Colors.green.shade800,
                      width: 1.5,
                      markerSettings: const MarkerSettings(isVisible: false),
                      animationDuration: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              VolumePieByDirection(
                homeCont: homeCont,
                upColor: ColorConstants.upColor,
                downColor: ColorConstants.downColor,
                equalColor: ColorConstants.unchangedColor,
              ),
            ] else ...[
              // 1Y Chart
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

/// Pie widget: shows Up / Down / Equal volume share
class VolumePieByDirection extends StatelessWidget {
  /// bucket size in seconds (default 30)
  final HomeController homeCont;
  final int bucketSeconds;

  /// keep last N buckets (for performance)
  final int maxBuckets;

  /// colors for categories (override if you want)
  final Color upColor;
  final Color downColor;
  final Color equalColor;

  const VolumePieByDirection({
    super.key,
    required this.homeCont,
    this.bucketSeconds = 30,
    this.maxBuckets = 300,
    this.upColor = Colors.green,
    this.downColor = Colors.red,
    this.equalColor = Colors.grey,
  });

  DateTime? _tryParseTst(String? tst) {
    if (tst == null) return null;
    try {
      final parts = tst.split('.');
      final hhmmss = parts[0];
      final seg = hhmmss.split(':');
      if (seg.length != 3) return null;
      final h = int.tryParse(seg[0]);
      final m = int.tryParse(seg[1]);
      final s = int.tryParse(seg[2]);
      if (h == null || m == null || s == null) return null;
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, h, m, s);
    } catch (_) {
      return null;
    }
  }

  List<_VolBucket> _aggregateBuckets(List<TimeAndSalesModel> raw, int bucketSeconds, {int keepLast = 300}) {
    if (raw.isEmpty) return [];
    raw.sort((a, b) {
      final ta = _tryParseTst(a.tst);
      final tb = _tryParseTst(b.tst);
      if (ta == null && tb == null) return 0;
      if (ta == null) return -1;
      if (tb == null) return 1;
      return ta.compareTo(tb);
    });

    final Map<int, _VolBucket> map = {};
    for (final t in raw) {
      final dt = _tryParseTst(t.tst);
      if (dt == null) continue;
      final epoch = dt.millisecondsSinceEpoch;
      final bucketStartEpoch = (epoch ~/ (bucketSeconds * 1000)) * (bucketSeconds * 1000);
      final key = bucketStartEpoch;
      final price = t.p ?? 0.0;
      final vol = (t.v ?? 0);
      if (!map.containsKey(key)) {
        map[key] = _VolBucket(
          start: DateTime.fromMillisecondsSinceEpoch(key),
          volume: vol.toDouble(),
          open: price,
          high: price,
          low: price,
          close: price,
        );
      } else {
        final b = map[key]!;
        b.volume += vol;
        b.close = price;
        if (price > b.high) b.high = price;
        if (price < b.low) b.low = price;
      }
    }

    final keys = map.keys.toList()..sort();
    final list = keys.map((k) => map[k]!).toList();
    if (list.length > keepLast) return list.sublist(list.length - keepLast);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (_) {
        final raw = List<TimeAndSalesModel>.from(homeCont.timeAndSales);
        if (raw.isEmpty) {
          return Center(child: Text('No trades', style: Get.textTheme.bodyLarge));
        }

        final buckets = _aggregateBuckets(raw, bucketSeconds, keepLast: maxBuckets);
        if (buckets.isEmpty) return Center(child: Text('No buckets', style: Get.textTheme.bodyLarge));

        // Sum volumes into categories based on bucket close vs previous close
        double upVol = 0.0, downVol = 0.0, equalVol = 0.0;
        for (int i = 0; i < buckets.length; i++) {
          final b = buckets[i];
          final prevClose = (i > 0) ? buckets[i - 1].close : b.open; // fallback
          if (b.close > prevClose) {
            upVol += b.volume;
          } else if (b.close < prevClose) {
            downVol += b.volume;
          } else {
            equalVol += b.volume;
          }
        }

        final total = upVol + downVol + equalVol;
        if (total <= 0) {
          return Center(child: Text('No volume', style: Theme.of(context).textTheme.bodyLarge));
        }

        final slices = <_PieSlice>[];
        if (upVol > 0) slices.add(_PieSlice(category: 'Up', value: upVol, color: upColor));
        if (downVol > 0) slices.add(_PieSlice(category: 'Down', value: downVol, color: downColor));
        if (equalVol > 0) slices.add(_PieSlice(category: 'Equal', value: equalVol, color: equalColor));

        return SizedBox(
          height: 260,
          child: SfCircularChart(
            legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y'),
            series: <CircularSeries>[
              DoughnutSeries<_PieSlice, String>(
                dataSource: slices,
                xValueMapper: (_PieSlice s, _) => s.category,
                yValueMapper: (_PieSlice s, _) => s.value,
                pointColorMapper: (_PieSlice s, _) => s.color,
                innerRadius: '55%',
                radius: '85%',
                enableTooltip: true,
                explode: true,
                explodeIndex: 0,
              ),
            ],
          ),
        );
      },
    );
  }
}

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
    raw.sort((a, b) => _parseTstToToday(a.tst).compareTo(_parseTstToToday(b.tst)));

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
    return GetBuilder<HomeController>(
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

class _PricePoint {
  final DateTime xDate;
  final double y;
  final int volume;
  _PricePoint({required this.xDate, required this.y, required this.volume});
}

class _VolBucket {
  DateTime start;
  double volume;
  double open;
  double high;
  double low;
  double close;
  _VolBucket({
    required this.start,
    required this.volume,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

class _VolPoint {
  final DateTime time;
  final double volume;
  final double open;
  final double close;
  double previousClose; // <--- important for color decision
  _VolPoint({
    required this.time,
    required this.volume,
    required this.open,
    required this.close,
    required this.previousClose,
  });
}

/// Pie data model
class _PieSlice {
  final String category;
  final double value;
  final Color color;
  _PieSlice({required this.category, required this.value, required this.color});
}
