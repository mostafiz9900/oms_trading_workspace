import 'package:market/market.dart' show IndexChartModel2;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controllers/index_chart_controller.dart';
import '/app/app_pkg.dart';

class MarketIndexChart extends StatelessWidget {
  const MarketIndexChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: 'indexList',
      builder: (homeCon) {
        final selectedIndex = homeCon.newArr;

        if (selectedIndex == null) {
          return const SizedBox.shrink();
        }

        final bool isNegative = (selectedIndex.ivd ?? 0) < 0;
        final themeColor = isNegative
            ? Colors.redAccent
            : Colors.green.shade700;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.isDark ? hexToColor('#161A33') : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.isDark ? Colors.white12 : Colors.grey.shade300,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(context.isDark ? 0.2 : 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================================
              // 🚀 ১. Header: Index Name & Live Values
              // ========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedIndex.sn ?? "DSEX",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        NumberFormatter.bdFormat(selectedIndex.civ ?? 0),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: context.textColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isNegative
                                ? Icons.arrow_drop_down_rounded
                                : Icons.arrow_drop_up_rounded,
                            color: themeColor,
                            size: 24,
                          ),
                          Text(
                            '${isNegative ? '' : '+'}${selectedIndex.ivd?.toStringAsFixed(2) ?? "0.00"}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${isNegative ? '' : '+'}${selectedIndex.ip?.toStringAsFixed(2) ?? "0.00"}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Divider(height: 20),

              // ========================================================
              // 🚀 ২. Intraday Area Chart Section (StockNow স্টাইল)
              // ========================================================
              SizedBox(
                height: 210,
                child: GetBuilder<IndexChartController>(
                  builder: (chartCon) {
                    if (chartCon.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }

                    if (chartCon.chartData.isEmpty) {
                      return Center(
                        child: Text(
                          chartCon.errorMessage.isNotEmpty
                              ? chartCon.errorMessage
                              : "No chart data available",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }

                    final List<IndexChartModel2> chartData = chartCon.chartData;

                    return SfCartesianChart(
                      margin: EdgeInsets.zero,
                      plotAreaBorderWidth: 0,
                      primaryXAxis: DateTimeAxis(
                        isVisible: true,
                        majorGridLines: const MajorGridLines(width: 0),
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        intervalType: DateTimeIntervalType.minutes,
                      ),
                      primaryYAxis: NumericAxis(
                        isVisible: true,
                        opposedPosition: true, // ডানপাশে প্রাইস শো করবে
                        majorGridLines: MajorGridLines(
                          width: 0.5,
                          color: context.isDark
                              ? Colors.white10
                              : Colors.grey.shade200,
                        ),
                        decimalPlaces: 2,
                      ),
                      trackballBehavior: TrackballBehavior(
                        enable: true,
                        activationMode: ActivationMode.singleTap,
                        tooltipSettings: const InteractiveTooltip(
                          enable: true,
                          color: Colors.blueAccent,
                        ),
                      ),
                      series: <CartesianSeries>[
                        // ওপরের কার্ভ এবং গ্রেডিয়েন্ট শেড এরিয়া চার্ট
                        SplineAreaSeries<IndexChartModel2, DateTime>(
                          dataSource: chartData,
                          xValueMapper: (IndexChartModel2 data, _) =>
                              DateTime.fromMillisecondsSinceEpoch(
                                data.timestamp * 1000,
                              ),
                          yValueMapper: (IndexChartModel2 data, _) =>
                              data.price,
                          borderColor: themeColor,
                          borderWidth: 2,
                          gradient: LinearGradient(
                            colors: [
                              themeColor.withOpacity(0.35),
                              themeColor.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Divider(height: 20),

              // ========================================================
              // 🚀 ৩. Market Statistics (Advance, Declined, Volume)
              // ========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    context,
                    "Advance",
                    "${selectedIndex.u ?? 0}",
                    Colors.green.shade700,
                  ),
                  _buildStatItem(
                    context,
                    "Declined",
                    "${selectedIndex.d ?? 0}",
                    Colors.redAccent,
                  ),
                  _buildStatItem(
                    context,
                    "Unchanged",
                    "${selectedIndex.uc ?? 0}",
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    context,
                    "Trades",
                    "${selectedIndex.nt ?? 0}",
                    context.textColor,
                  ),
                  _buildStatItem(
                    context,
                    "Volume",
                    NumberFormatter.bdFormat(selectedIndex.v?.toDouble() ?? 0),
                    context.textColor,
                  ),
                  _buildStatItem(
                    context,
                    "Value (BDT)",
                    NumberFormatter.bdFormat(selectedIndex.vl ?? 0),
                    context.textColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    Color valueColor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: context.isDark ? Colors.white60 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
