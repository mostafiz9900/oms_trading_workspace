
import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'time_sales_sort.dart';

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
    sortTimeSalesByKey(raw, (t) => _parseTst(t.tst), (a, b) => a.compareTo(b));

    final points = raw.map((e) {
      return _ChartPoint(xDate: _parseTst(e.tst), y: e.p ?? 0.0, index: 0, label: '', volume: null);
    }).toList();
    return _downsampleIfNeeded(points, threshold: 1500);
  }

  @override
  Widget build(BuildContext context) {
    return VisibleGetBuilder<HomeController>(
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
  }) : id = null;
}

// Make sure TimeAndSalesModel and HomeController are imported/defined in your project.
