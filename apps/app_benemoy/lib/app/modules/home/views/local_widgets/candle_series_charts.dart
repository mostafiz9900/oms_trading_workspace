import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../app_pkg.dart';
import '../../controllers/historical_volume_controller.dart';
import 'time_sales_line_chart.dart';

class _VolBucket {
  final DateTime start;
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

  double get change => close - open;
  double get percentChange => open == 0 ? 0 : ((close - open) / open) * 100;
}

class CandleSeriesChartsWidget extends HookWidget {
  const CandleSeriesChartsWidget({super.key});

  static const Color bullColor = Color(0xFF089981);
  static const Color bearColor = Color(0xFFF23645);

  DateTime _parseTst(String? tst) {
    if (tst == null || tst.isEmpty) return DateTime.now();
    try {
      final now = DateTime.now();
      if (tst.contains('-') || tst.contains('T')) {
        return DateTime.parse(tst).toLocal();
      }
      final parts = tst.split('.');
      final seg = parts[0].split(':');

      final int h = int.tryParse(seg[0]) ?? now.hour;
      final int m = seg.length > 1 ? (int.tryParse(seg[1]) ?? 0) : 0;
      final int s = seg.length > 2 ? (int.tryParse(seg[2]) ?? 0) : 0;

      return DateTime(now.year, now.month, now.day, h, m, s);
    } catch (_) {
      return DateTime.now();
    }
  }

  DateTime _getBucketStart(DateTime dt, int intervalMins) {
    if (intervalMins == 60) return DateTime(dt.year, dt.month, dt.day, dt.hour, 0);
    final int bucketMin = (dt.minute ~/ intervalMins) * intervalMins;
    return DateTime(dt.year, dt.month, dt.day, dt.hour, bucketMin);
  }

  List<_VolBucket> _aggregateVolumeBuckets(List<TimeAndSalesModel> raw, int bucketMins) {
    if (raw.isEmpty) return [];

    final now = DateTime.now();
    final parsedList = raw.map((t) => MapEntry(t, _parseTst(t.tst))).toList();

    final filteredList = parsedList.where((entry) {
      final dt = entry.value;
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }).toList();

    filteredList.sort((a, b) => a.value.compareTo(b.value));

    final Map<int, _VolBucket> map = {};

    for (final entry in filteredList) {
      final t = entry.key;
      final dt = entry.value;

      final bucketStart = _getBucketStart(dt, bucketMins);
      final key = bucketStart.millisecondsSinceEpoch;

      final price = t.p ?? 0.0;
      final vol = (t.v ?? 0).toDouble();

      if (!map.containsKey(key)) {
        map[key] = _VolBucket(start: bucketStart, volume: vol, open: price, high: price, low: price, close: price);
      } else {
        final b = map[key]!;
        b.volume += vol;
        b.close = price;
        if (price > b.high) b.high = price;
        if (price < b.low) b.low = price;
      }
    }

    final sortedKeys = map.keys.toList()..sort();
    return sortedKeys.map((k) => map[k]!).toList();
  }

  int _getBucketMinutes(String tab) {
    switch (tab) {
      case '1m':
        return 1;
      case '5m':
        return 5;
      case '15m':
        return 15;
      case '30m':
        return 30;
      case '1H':
        return 60;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeCont = useMemoized(() => Get.find<HomeController>());
    final histCont = useMemoized(() => Get.find<HistoricalVolumeController>());

    // 🚀 Screen size for responsiveness
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final selectedTab = useState<String>('1m');
    final hoveredCandle = useState<_VolBucket?>(null);

    final zoomPanBehavior = useMemoized(
      () => ZoomPanBehavior(enablePanning: true, enablePinching: true, zoomMode: ZoomMode.x, maximumZoomLevel: 0.05),
    );

    final trackballBehavior = useMemoized(
      () => TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        hideDelay: 3000,
        tooltipDisplayMode: TrackballDisplayMode.none,
        lineType: TrackballLineType.vertical,
        lineColor: Theme.of(context).dividerColor.withOpacity(0.6),
        lineWidth: 1.2,
        lineDashArray: const [4, 4],
        shouldAlwaysShow: false,
      ),
    );

    final isIntradayTab = ['1m', '5m', '15m', '30m', '1H'].contains(selectedTab.value);
    final timeframes = ['1m', '5m', '15m', '30m', '1H', '1D'];

    return GetBuilder<HomeController>(
      init: homeCont,
      id: 'timeAndSales',
      builder: (_) {
        return GetBuilder<HistoricalVolumeController>(
          init: histCont,
          builder: (_) {
            List<_VolBucket> volBuckets = [];

            if (isIntradayTab) {
              final rawTicks = List<TimeAndSalesModel>.from(homeCont.timeAndSales);
              volBuckets = _aggregateVolumeBuckets(rawTicks, _getBucketMinutes(selectedTab.value));
            } else if (selectedTab.value == '1D') {
              volBuckets = histCont.chartData
                  .map(
                    (e) => _VolBucket(
                      start: e.x,
                      volume: e.volume,
                      open: e.open,
                      high: e.high,
                      low: e.low,
                      close: e.close,
                    ),
                  )
                  .toList();
            }

            if (volBuckets.isEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  _buildTimeframeBar(timeframes, selectedTab, hoveredCandle),
                  const SizedBox(height: 80),
                  const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                  const SizedBox(height: 80),
                ],
              );
            }

            final currentLivePrice = volBuckets.last.close;
            final prevLivePrice = volBuckets.length > 1
                ? volBuckets[volBuckets.length - 2].close
                : volBuckets.last.open;
            final bool isLiveUp = currentLivePrice >= prevLivePrice;
            final Color liveColor = isLiveUp ? bullColor : bearColor;

            double minY = volBuckets.map((e) => e.low).reduce(min);
            double maxY = volBuckets.map((e) => e.high).reduce(max);

            if (minY == maxY) {
              minY -= 1.0;
              maxY += 1.0;
            }

            final pad = (maxY - minY) * 0.12;
            final volAxisMax = volBuckets.map((e) => e.volume).reduce(max) * 4.5;
            final double candleWidth = selectedTab.value == '1D' ? 0.6 : 0.7;

            final activeCandle = hoveredCandle.value ?? volBuckets.last;
            final bool isCandleUp = activeCandle.close >= activeCandle.open;
            final Color candleColor = isCandleUp ? bullColor : bearColor;

            // 🚀 Chart Height Increased (45% of screen height, minimum 350px)
            final double dynamicChartHeight = (screenHeight * 0.45).clamp(350.0, 550.0);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),

                  _buildTimeframeBar(timeframes, selectedTab, hoveredCandle),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildInfoTag('O', activeCandle.open.toStringAsFixed(2), context),
                          _buildInfoTag('H', activeCandle.high.toStringAsFixed(2), context),
                          _buildInfoTag('L', activeCandle.low.toStringAsFixed(2), context),
                          _buildInfoTag('C', activeCandle.close.toStringAsFixed(2), context, color: candleColor),
                          _buildInfoTag('V', NumberFormat.compact().format(activeCandle.volume), context),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: candleColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${isCandleUp ? '+' : ''}${activeCandle.change.toStringAsFixed(2)} (${activeCandle.percentChange.toStringAsFixed(2)}%)',
                              style: TextStyle(color: candleColor, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: dynamicChartHeight,
                    width: screenWidth,
                    child: SfCartesianChart(
                      backgroundColor: Colors.transparent,
                      plotAreaBorderWidth: 0,
                      // 🚀 Right & Left margin increased slightly
                      margin: const EdgeInsets.only(right: 18, left: 8, top: 4, bottom: 4),
                      zoomPanBehavior: zoomPanBehavior,
                      trackballBehavior: trackballBehavior,
                      onTrackballPositionChanging: (TrackballArgs args) {
                        if (args.chartPointInfo.dataPointIndex != null) {
                          final idx = args.chartPointInfo.dataPointIndex!;
                          if (idx >= 0 && idx < volBuckets.length) {
                            hoveredCandle.value = volBuckets[idx];
                          }
                        }
                      },
                      primaryXAxis: DateTimeAxis(
                        intervalType: DateTimeIntervalType.auto,
                        dateFormat: selectedTab.value == '1D' ? DateFormat('dd MMM') : DateFormat('hh:mm a'),
                        // 🚀 Prevents the extreme left/right labels from being cut off
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        majorGridLines: MajorGridLines(
                          color: Theme.of(context).dividerColor.withOpacity(0.15),
                          dashArray: const [4, 4],
                          width: 0.8,
                        ),
                        axisLine: const AxisLine(width: 0),
                        labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: minY - pad,
                        maximum: maxY + pad,
                        opposedPosition: true,
                        numberFormat: NumberFormat("##0.00"),
                        majorGridLines: MajorGridLines(
                          color: Theme.of(context).dividerColor.withOpacity(0.15),
                          dashArray: const [4, 4],
                          width: 0.8,
                        ),
                        axisLine: const AxisLine(width: 0),
                        labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        plotBands: currentLivePrice > 0
                            ? <PlotBand>[
                                PlotBand(
                                  isVisible: true,
                                  start: currentLivePrice,
                                  end: currentLivePrice,
                                  borderColor: liveColor,
                                  borderWidth: 1.2,
                                  dashArray: const <double>[3, 3],
                                  text: ' ${currentLivePrice.toStringAsFixed(2)}',
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    backgroundColor: liveColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  horizontalTextAlignment: TextAnchor.end,
                                ),
                              ]
                            : [],
                      ),
                      axes: <ChartAxis>[
                        NumericAxis(
                          name: 'volumeAxis',
                          minimum: 0,
                          maximum: volAxisMax,
                          opposedPosition: false,
                          isVisible: false,
                        ),
                      ],
                      series: <CartesianSeries>[
                        ColumnSeries<_VolBucket, DateTime>(
                          dataSource: volBuckets,
                          xValueMapper: (_VolBucket b, _) => b.start,
                          yValueMapper: (_VolBucket b, _) => b.volume,
                          yAxisName: 'volumeAxis',
                          pointColorMapper: (_VolBucket b, _) =>
                              b.close >= b.open ? bullColor.withOpacity(0.25) : bearColor.withOpacity(0.25),
                          width: candleWidth,
                        ),
                        if (selectedTab.value == '1m') ...[
                          AreaSeries<_VolBucket, DateTime>(
                            dataSource: volBuckets,
                            xValueMapper: (_VolBucket b, _) => b.start,
                            yValueMapper: (_VolBucket b, _) => b.close,
                            gradient: LinearGradient(
                              colors: [liveColor.withOpacity(0.25), liveColor.withOpacity(0.0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          FastLineSeries<_VolBucket, DateTime>(
                            dataSource: volBuckets,
                            xValueMapper: (_VolBucket b, _) => b.start,
                            yValueMapper: (_VolBucket b, _) => b.close,
                            color: liveColor,
                            width: 1.8,
                          ),
                        ] else ...[
                          CandleSeries<_VolBucket, DateTime>(
                            dataSource: volBuckets,
                            xValueMapper: (_VolBucket b, _) => b.start,
                            lowValueMapper: (_VolBucket b, _) => b.low,
                            highValueMapper: (_VolBucket b, _) => b.high,
                            openValueMapper: (_VolBucket b, _) => b.open,
                            closeValueMapper: (_VolBucket b, _) => b.close,
                            bullColor: bullColor,
                            bearColor: bearColor,
                            enableSolidCandles: true,
                            width: candleWidth,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (isIntradayTab)
                    VolumePieByDirection(
                      homeCont: homeCont,
                      upColor: bullColor,
                      downColor: bearColor,
                      equalColor: Colors.grey.shade400,
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🚀 Updated Timeframe Bar with FittedBox
  Widget _buildTimeframeBar(
    List<String> items,
    ValueNotifier<String> selectedTab,
    ValueNotifier<_VolBucket?> hoveredCandle,
  ) {
    return Padding(
      padding: const .symmetric(horizontal: 16.0),
      child: Container(
        padding: const .all(3),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Get.theme.dividerColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((t) {
            final isSelected = selectedTab.value == t;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  selectedTab.value = t;
                  hoveredCandle.value = null;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const .symmetric(vertical: 6, horizontal: 2), // 🚀 Added horizontal padding limit
                  decoration: BoxDecoration(
                    color: isSelected ? ColorConstants.unchangedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: FittedBox(
                      // 🚀 Protects against text overflow on very narrow devices
                      fit: BoxFit.scaleDown,
                      child: Text(
                        t,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoTag(String label, String value, BuildContext context, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min, // 🚀 Important for Wrap to measure properly
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
