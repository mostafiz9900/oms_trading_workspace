import 'package:market/market.dart' show IndexChartModel;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../controllers/market_index_controller.dart';

class ProfessionalStockChart extends StatefulWidget {
  const ProfessionalStockChart({super.key});

  @override
  State<ProfessionalStockChart> createState() => _ProfessionalStockChartState();
}

class _ProfessionalStockChartState extends State<ProfessionalStockChart> {
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    super.initState();

    // 🔴 FIX 1: ZoomMode.xy দিয়ে 2D Scroll/Pan এনাবল করা হয়েছে
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      zoomMode: ZoomMode.xy, // X এবং Y উভয় দিকেই Pan/Scroll কাজ করবে
      enableDoubleTapZooming: true,
    );

    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      lineType: TrackballLineType.vertical,
      lineColor: const Color(0xFF90A4AE),
      lineWidth: 1,
      lineDashArray: const <double>[4, 4],
      shouldAlwaysShow: false,
      tooltipDisplayMode: TrackballDisplayMode.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketIndexController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const AspectRatio(
            aspectRatio: 1.2,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF2962FF),
              ),
            ),
          );
        }

        if (controller.errorMessage != null) {
          return AspectRatio(
            aspectRatio: 1.2,
            child: Center(
              child: Text(
                controller.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFF23645),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        if (controller.allData.isEmpty) {
          return const AspectRatio(
            aspectRatio: 1.2,
            child: Center(
              child: Text(
                "No chart data available",
                style: TextStyle(color: Color(0xFF787B86)),
              ),
            ),
          );
        }

        const Color greenColor = Color(0xFF00A859); // BullBD Green
        const Color redColor = Color(0xFFE53935); // BullBD Red
        final Color themeColor = controller.isBullish ? greenColor : redColor;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double chartHeight = constraints.maxHeight.isInfinite
                ? (MediaQuery.of(context).orientation == Orientation.landscape
                      ? 260
                      : 380)
                : constraints.maxHeight;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===========================================================
                  // 1. TOP HEADER & TIMEFRAME SELECTOR
                  // ===========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            controller.indexName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "DSE INDEX",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Timeframe Filter Buttons
                      Row(
                        children: controller.timeframes.map((tf) {
                          final isSelected = controller.selectedTimeframe == tf;
                          return GestureDetector(
                            onTap: () => controller.changeTimeframe(tf),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                tf,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ===========================================================
                  // 2. LIVE PRICE & CHANGE DISPLAY
                  // ===========================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        controller.currentValue.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: themeColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${controller.isBullish ? '+' : ''}${controller.change.toStringAsFixed(2)} (${controller.changePercent.toStringAsFixed(2)}%)",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: themeColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (controller.hoveredItem != null)
                        InkWell(
                          onTap: () => controller.resetHoveredItem(),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 13,
                                color: Color(0xFF2563EB),
                              ),
                              SizedBox(width: 2),
                              Text(
                                "Live",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ===========================================================
                  // 3. BULLBD TRADINGVIEW-STYLE HUD (O H L C Vol Time)
                  // ===========================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildHudItem(
                            "O",
                            controller.displayOpen.toStringAsFixed(2),
                          ),
                          _buildHudItem(
                            "H",
                            controller.displayHigh.toStringAsFixed(2),
                          ),
                          _buildHudItem(
                            "L",
                            controller.displayLow.toStringAsFixed(2),
                          ),
                          _buildHudItem(
                            "C",
                            controller.displayClose.toStringAsFixed(2),
                          ),
                          _buildHudItem(
                            "Vol",
                            NumberFormat.compact().format(
                              controller.displayVolume,
                            ),
                          ),
                          if (controller.activeItem?.lmDateTime != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                DateFormat('HH:mm')
                                    .format(controller.activeItem!.lmDateTime!),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ===========================================================
                  // 4. CHART CANVAS
                  // ===========================================================
                  SizedBox(
                    height: chartHeight > 220 ? chartHeight - 110 : 220,
                    child: SfCartesianChart(
                      margin: const EdgeInsets.only(
                        top: 12,
                        bottom: 4,
                        left: 4,
                        right: 4,
                      ),
                      plotAreaBorderWidth: 0,
                      zoomPanBehavior: _zoomPanBehavior,
                      trackballBehavior: _trackballBehavior,

                      onTrackballPositionChanging: (TrackballArgs args) {
                        final pointIndex = args.chartPointInfo.dataPointIndex;
                        if (pointIndex != null &&
                            pointIndex >= 0 &&
                            pointIndex < controller.allData.length) {
                          controller.setHoveredItem(
                            controller.allData[pointIndex],
                          );
                        }
                      },

                      primaryXAxis: DateTimeAxis(
                        minimum: controller.minX,
                        maximum: controller.maxX,
                        dateFormat: controller.xAxisDateFormat,
                        intervalType: controller.xAxisIntervalType,
                        interval: controller.xAxisInterval,
                        enableAutoIntervalOnZooming: true,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        majorGridLines: const MajorGridLines(
                          width: 0.5,
                          color: Color(0xFFF1F5F9),
                        ),
                        axisLine: const AxisLine(
                          width: 1,
                          color: Color(0xFFCBD5E1),
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      primaryYAxis: NumericAxis(
                        opposedPosition: true,
                        enableAutoIntervalOnZooming: true,
                        minimum: controller.yMin,
                        maximum: controller.yMax,
                        axisLine: const AxisLine(width: 0),
                        majorGridLines: const MajorGridLines(
                          width: 0.5,
                          color: Color(0xFFF1F5F9),
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        numberFormat: NumberFormat("####.00"),

                        plotBands: [
                          // Previous Close Baseline
                          PlotBand(
                            start: controller.basePrevClose,
                            end: controller.basePrevClose,
                            borderColor: const Color(0xFF64748B),
                            borderWidth: 1,
                            dashArray: const <double>[4, 4],
                            text:
                                " Prev ${controller.basePrevClose.toStringAsFixed(1)} ",
                            horizontalTextAlignment: TextAnchor.end,
                            verticalTextAlignment: TextAnchor.middle,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Color(0xFF64748B),
                            ),
                          ),
                          // Live LTP Current Price Badge
                          PlotBand(
                            start: controller.currentValue,
                            end: controller.currentValue,
                            borderColor: themeColor,
                            borderWidth: 1,
                            dashArray: const <double>[2, 2],
                            text:
                                " ${controller.currentValue.toStringAsFixed(2)} ",
                            horizontalTextAlignment: TextAnchor.end,
                            verticalTextAlignment: TextAnchor.middle,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              backgroundColor: themeColor,
                            ),
                          ),
                        ],
                      ),

                      // 🔴 FIX 2: Secondary Volume Axis-এর range কন্ট্রোল করা হয়েছে
                      axes: <ChartAxis>[
                        NumericAxis(
                          name: 'volumeAxis',
                          opposedPosition: true,
                          isVisible: false,
                          minimum: 0,
                          // maxVolume যদি 0 থাকে তবে ডিফল্ট মান ১০০ দেওয়া হয়েছে
                          maximum: controller.maxVolume <= 0
                              ? 100
                              : controller.maxVolume * 3.5,
                        ),
                      ],

                      series: <CartesianSeries>[
                        // 1. Area Fill
                        AreaSeries<IndexChartModel, DateTime>(
                          name: 'Area',
                          animationDuration: 0,
                          dataSource: controller.allData,
                          xValueMapper: (IndexChartModel item, _) =>
                              item.lmDateTime ?? DateTime.now(),
                          yValueMapper: (IndexChartModel item, _) =>
                              item.ltp ?? controller.basePrevClose,
                          gradient: LinearGradient(
                            colors: [
                              themeColor.withOpacity(0.25),
                              themeColor.withOpacity(0.02),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),

                        // 🔴 FIX 3: Volume ColumnSeries সঠিক Visible & Width সেট করে দেওয়া হয়েছে
                        ColumnSeries<IndexChartModel, DateTime>(
                          name: 'Volume',
                          yAxisName: 'volumeAxis',
                          animationDuration: 0,
                          dataSource: controller.allData,
                          xValueMapper: (IndexChartModel item, _) =>
                              item.lmDateTime ?? DateTime.now(),
                          yValueMapper: (IndexChartModel item, _) {
                            final vol =
                                (item.volumeNew ?? item.totalVolume ?? 0)
                                    .toDouble();
                            return vol;
                          },
                          pointColorMapper: (IndexChartModel item, int index) {
                            double prevLtp = index > 0
                                ? (controller.allData[index - 1].ltp ??
                                      controller.basePrevClose)
                                : controller.basePrevClose;
                            return (item.ltp ?? 0) >= prevLtp
                                ? greenColor.withOpacity(0.45)
                                : redColor.withOpacity(0.45);
                          },
                          width: 0.8, // Explicit Column Width
                          spacing: 0.0,
                        ),

                        // 3. Index Line
                        LineSeries<IndexChartModel, DateTime>(
                          name: 'Index',
                          animationDuration: 0,
                          dataSource: controller.allData,
                          xValueMapper: (IndexChartModel item, _) =>
                              item.lmDateTime ?? DateTime.now(),
                          yValueMapper: (IndexChartModel item, _) =>
                              item.ltp ?? controller.basePrevClose,
                          width: 2,
                          color: themeColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHudItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
