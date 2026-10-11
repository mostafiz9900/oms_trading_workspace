// lib/views/widgets/candle_chart_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../controllers/candle_chart_controller.dart';
import '../../../controllers/historical_volume_controller.dart';

class CandleChartView extends StatefulWidget {
  const CandleChartView({super.key});

  @override
  State<CandleChartView> createState() => _CandleChartViewState();
}

class _CandleChartViewState extends State<CandleChartView> {
  final ValueNotifier<CandleData?> _hoveredCandle = ValueNotifier(null);
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  // 🚀 StockNow Exact Colors
  final Color bullColor = const Color(0xFF00B061); // StockNow Green
  final Color bearColor = const Color(0xFFFF3B30); // StockNow Red
  final Color gridColor = const Color(0xFFF2F4F7); // Ultra Light Grid
  final Color textColor = const Color(0xFF6C757D);
  final Color trackballColor = const Color(0xFF1E222D);

  @override
  void initState() {
    super.initState();
    Get.put(CandleChartController());

    // 🚀 Smooth StockNow Scrolling
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      enableDoubleTapZooming: true,
      zoomMode: ZoomMode.x,
    );

    // 🚀 StockNow Trackball (Crosshair)
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.longPress, // চেপে ধরলে ক্রসহেয়ার আসবে
      hideDelay: 2000,
      lineType: TrackballLineType.vertical,
      lineColor: trackballColor.withOpacity(0.5),
      lineWidth: 1.0,
      lineDashArray: const [5, 5],
      tooltipDisplayMode: TrackballDisplayMode.none, // টুলটিপ হেডারে ও এক্সিসে দেখাবো
    );
  }

  @override
  void dispose() {
    _hoveredCandle.dispose();
    super.dispose();
  }

  // 🚀 Header Date Format (Crosshair Hover)
  String _formatHeaderDate(DateTime time, String timeframe) {
    if (['1D', '1W', '1M', '1Y'].contains(timeframe)) {
      return DateFormat('dd MMM yyyy').format(time);
    }
    return DateFormat('dd MMM, h:mm a').format(time); // e.g., 12 Aug, 10:30 AM
  }

  // 🚀 BUG FIX: X-Axis Date Format (Fixed the "00" issue)
  DateFormat _getAxisDateFormat(String timeframe) {
    if (['1m', '5m', '15m', '30m', '1H'].contains(timeframe)) {
      // 🚀 'HH:mm' এর বদলে 'h:mm a' দেওয়া হলো (e.g. 10:30 AM)
      return DateFormat('h:mm a');
    }
    if (['1M', '1Y'].contains(timeframe)) {
      return DateFormat('MMM yyyy'); // e.g. Aug 2023
    }
    return DateFormat('dd MMM'); // e.g. 12 Aug
  }

  // 🚀 Tooltip Format String
  String _getTooltipFormat(String timeframe) {
    if (['1m', '5m', '15m', '30m', '1H'].contains(timeframe)) {
      return 'dd MMM, h:mm a';
    }
    return 'dd MMM yyyy';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CandleChartController>(
      id: 'main_view',
      builder: (controller) {
        if (controller.isLoading && controller.chartData.isEmpty) {
          return const SizedBox(height: 450, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }

        final bool isLiveUp = controller.priceChange >= 0;
        final Color liveColor = isLiveUp ? bullColor : bearColor;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==========================================
              // 1. StockNow Live Price Header
              // ==========================================
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${controller.currentPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '${isLiveUp ? '+' : ''}${controller.priceChange.toStringAsFixed(2)} (${isLiveUp ? '+' : ''}${controller.priceChangePercent.toStringAsFixed(2)}%)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: liveColor),
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // 2. Realtime OHLC Strip (Snap to Crosshair)
              // ==========================================
              ValueListenableBuilder<CandleData?>(
                valueListenable: _hoveredCandle,
                builder: (context, hovered, child) {
                  final candle = hovered ?? controller.latestCandle;
                  if (candle == null) return const SizedBox();
                  final cColor = candle.close >= candle.open ? bullColor : bearColor;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatHeaderDate(candle.x, controller.selectedTimeframe),
                              style: TextStyle(color: Colors.blue.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _ohlcItem('O', candle.open),
                          _ohlcItem('H', candle.high),
                          _ohlcItem('L', candle.low),
                          _ohlcItem('C', candle.close, color: cColor),
                          _ohlcItem('V', candle.volume, isVol: true),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // ==========================================
              // 3. StockNow Minimal Timeframe Selector
              // ==========================================
              Container(
                height: 38,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.timeframes.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemBuilder: (context, index) {
                    final tf = controller.timeframes[index];
                    final isSelected = controller.selectedTimeframe == tf;

                    return InkWell(
                      onTap: () {
                        _hoveredCandle.value = null;
                        _zoomPanBehavior.reset();
                        controller.changeTimeframe(tf);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? Colors.blue.shade700 : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          tf,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? Colors.blue.shade700 : textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ==========================================
              // 4. Quick Toolbar
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Row(
                  children: [
                    _chartTypeBtn(controller, Icons.candlestick_chart, ChartType.candle),
                    _chartTypeBtn(controller, Icons.show_chart, ChartType.line),
                    const Spacer(),
                    Obx(() => _indicatorChip(controller, 'SMA')),
                    const SizedBox(width: 8),
                    Obx(() => _indicatorChip(controller, 'EMA')),
                  ],
                ),
              ),

              // ==========================================
              // 5. THE STOCKNOW CANVAS (Chart Area)
              // ==========================================
              GetBuilder<CandleChartController>(
                id: 'chart_area',
                builder: (_) {
                  return SizedBox(
                    height: 400, // StockNow Standard Aspect Ratio
                    child: SfCartesianChart(
                      key: ValueKey('${controller.selectedTimeframe}_${controller.currentChartType}'),
                      plotAreaBorderWidth: 0,
                      margin: const EdgeInsets.only(left: 4, right: 8, top: 4, bottom: 4),
                      zoomPanBehavior: _zoomPanBehavior,
                      trackballBehavior: _trackballBehavior,

                      onTrackballPositionChanging: (TrackballArgs args) {
                        if (args.chartPointInfo.dataPointIndex != null) {
                          int index = args.chartPointInfo.dataPointIndex!;
                          if (index >= 0 && index < controller.chartData.length) {
                            Future.microtask(() => _hoveredCandle.value = controller.chartData[index]);
                          }
                        }
                      },

                      // --- 🚀 X-Axis: Perfect StockNow Formatting ---
                      primaryXAxis: DateTimeCategoryAxis(
                        initialZoomFactor: controller.initialZoomFactor,
                        initialZoomPosition: controller.initialZoomPosition,

                        // Clean axis look
                        majorGridLines: MajorGridLines(color: gridColor, width: 0.8),
                        majorTickLines: const MajorTickLines(size: 0),
                        axisLine: AxisLine(color: Colors.grey.shade300, width: 1.2),

                        labelStyle: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w600),
                        labelIntersectAction: AxisLabelIntersectAction.hide, // ওভারল্যাপ রিমুভ
                        // 🚀 BUG FIX: StockNow Smart Date Formatting applied here
                        dateFormat: _getAxisDateFormat(controller.selectedTimeframe),

                        interactiveTooltip: InteractiveTooltip(
                          enable: true,
                          color: trackballColor,
                          format: _getTooltipFormat(controller.selectedTimeframe),
                          textStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),

                      // --- Y-Axis: Right Aligned Price ---
                      primaryYAxis: NumericAxis(
                        opposedPosition: true,
                        anchorRangeToVisiblePoints: true, // Smooth Auto Scale
                        majorGridLines: MajorGridLines(color: gridColor, width: 0.8, dashArray: const [4, 4]),
                        axisLine: const AxisLine(width: 0),
                        labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
                        numberFormat: NumberFormat("##0.00"),

                        interactiveTooltip: InteractiveTooltip(
                          enable: true,
                          color: trackballColor,
                          textStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),

                        plotBands: controller.currentPrice > 0
                            ? <PlotBand>[
                                PlotBand(
                                  isVisible: true,
                                  start: controller.currentPrice,
                                  end: controller.currentPrice,
                                  borderColor: liveColor,
                                  borderWidth: 1.2,
                                  dashArray: const <double>[3, 3],
                                  text: ' ${controller.currentPrice.toStringAsFixed(2)} ',
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    backgroundColor: liveColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  horizontalTextAlignment: TextAnchor.end,
                                ),
                              ]
                            : [],
                      ),

                      axes: <ChartAxis>[
                        NumericAxis(
                          name: 'VolumeAxis',
                          minimum: 0,
                          maximum: controller.maxVolumeScale,
                          opposedPosition: false,
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: const AxisLine(width: 0),
                          labelStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
                        ),
                      ],

                      indicators: <TechnicalIndicator>[
                        if (controller.activeIndicators.contains('SMA'))
                          SmaIndicator<dynamic, dynamic>(
                            seriesName: 'PriceSeries',
                            valueField: 'close',
                            period: 14,
                            signalLineColor: Colors.orange.shade700,
                            signalLineWidth: 1.5,
                          ),
                        if (controller.activeIndicators.contains('EMA'))
                          EmaIndicator<dynamic, dynamic>(
                            seriesName: 'PriceSeries',
                            valueField: 'close',
                            period: 20,
                            signalLineColor: Colors.purple.shade600,
                            signalLineWidth: 1.5,
                          ),
                      ],

                      series: <CartesianSeries>[
                        // 1. Volume Series (Subtle below candles)
                        ColumnSeries<CandleData, DateTime>(
                          dataSource: controller.chartData,
                          xValueMapper: (CandleData b, _) => b.x,
                          yValueMapper: (CandleData b, _) => b.volume,
                          yAxisName: 'VolumeAxis',
                          pointColorMapper: (CandleData b, _) =>
                              b.close >= b.open ? bullColor.withOpacity(0.35) : bearColor.withOpacity(0.35),
                          width: 0.8,
                          spacing: 0.2, // ভলিউম বারে হালকা গ্যাপ
                          enableTooltip: false,
                          animationDuration: 0,
                        ),

                        // 2. Price Series
                        if (controller.currentChartType == ChartType.line || controller.selectedTimeframe == '1m')
                          FastLineSeries<CandleData, DateTime>(
                            name: 'PriceSeries',
                            dataSource: controller.chartData,
                            xValueMapper: (CandleData b, _) => b.x,
                            yValueMapper: (CandleData b, _) => b.close,
                            color: liveColor,
                            width: 1.8,
                            enableTooltip: true,
                            animationDuration: 0,
                          )
                        else
                          CandleSeries<CandleData, DateTime>(
                            name: 'PriceSeries',
                            dataSource: controller.chartData,
                            xValueMapper: (CandleData b, _) => b.x,
                            lowValueMapper: (CandleData b, _) => b.low,
                            highValueMapper: (CandleData b, _) => b.high,
                            openValueMapper: (CandleData b, _) => b.open,
                            closeValueMapper: (CandleData b, _) => b.close,
                            bullColor: bullColor,
                            bearColor: bearColor,
                            enableSolidCandles: true,

                            // 🚀 STOCKNOW PERFECT CANDLE PROPORTIONS (FAT CANDLES)
                            width: 0.85, // 0.85 ensures thick bodies
                            spacing: 0.15, // 0.15 provides the perfect gap

                            enableTooltip: true,
                            animationDuration: 0,
                          ),
                      ],
                    ),
                  );
                },
              ),

              // ==========================================
              // 6. Statistics Card
              // ==========================================
              GetBuilder<CandleChartController>(
                id: 'stats_card',
                builder: (_) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('High', controller.maxPrice),
                        _statItem('Low', controller.minPrice),
                        _statItem('Avg', controller.avgPrice),
                        _statItem('Total Vol', controller.totalVolume, isVol: true),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---
  Widget _ohlcItem(String label, double val, {bool isVol = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: isVol ? NumberFormat.compact().format(val) : val.toStringAsFixed(2),
              style: TextStyle(color: color ?? Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartTypeBtn(CandleChartController controller, IconData icon, ChartType type) {
    final isActive = controller.currentChartType == type;
    return IconButton(
      icon: Icon(icon, color: isActive ? Colors.blue.shade700 : Colors.grey.shade400, size: 20),
      onPressed: () => controller.toggleChartType(type),
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _indicatorChip(CandleChartController controller, String name) {
    final isActive = controller.activeIndicators.contains(name);
    return InkWell(
      onTap: () => controller.toggleIndicator(name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade50 : Colors.transparent,
          border: Border.all(color: isActive ? Colors.blue.shade600 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.blue.shade700 : textColor,
          ),
        ),
      ),
    );
  }

  Widget _statItem(String title, double value, {bool isVol = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 11, color: textColor)),
        const SizedBox(height: 2),
        Text(
          isVol ? NumberFormat.compact().format(value) : value.toStringAsFixed(2),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}
