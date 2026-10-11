import 'package:market/market.dart' show IndexCandleModel;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../../../../app_pkg.dart';

import '../../../controllers/live_index_controller.dart';
import '../index_value_loader.dart';

class IndexChartWidget extends StatelessWidget {
  IndexChartWidget({super.key}); // 🚀 const remove kora hoyeche

  // 🚀 FIX: TrackballBehavior ke build() method er baire define kora holo jate live update e hide na hoy
  final TrackballBehavior _trackballBehavior = TrackballBehavior(
    enable: true,
    activationMode: ActivationMode.longPress,
    lineType: TrackballLineType.vertical,
    lineColor: Colors.grey.withOpacity(0.4),
    lineWidth: 1.2,
    lineDashArray: const [4, 4],
    tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
  );

  DateFormat _getDateFormat(String timeframe) {
    switch (timeframe) {
      case "1D":
        return DateFormat('hh:mm a');
      case "1W":
        return DateFormat('dd MMM');
      case "1M":
      case "3M":
        return DateFormat('dd MMM');
      case "6M":
      case "1Y":
        return DateFormat('MMM yy');
      default:
        return DateFormat('dd MMM');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      id: 'index_chart',
      builder: (cont) {
        // 🚀 FIX: isChartLoading true ebang list empty hole sathe sathe shimmer asbe
        if (cont.isChartLoading && cont.indexCandleList.isEmpty) {
          return const FullIndexChartShimmer();
        }

        final indexData = cont.selectedIndexData ?? cont.newArr;
        final String indexName = indexData?.sn ?? cont.selectedSn;
        final double currentVal = indexData?.civ ?? 0.0;
        final double changeVal = indexData?.ivd ?? 0.0;
        final double changePct = indexData?.ip ?? 0.0;

        final bool isUp = changeVal >= 0;
        final Color statusColor = isUp
            ? const Color(0xFF00C853)
            : const Color(0xFFFF3D00);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            //  Top Header: Index Info (Left) & Toggle (Right)
            // ==========================================
            Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                top: 12.0,
                bottom: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              indexName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.isDark
                                    ? Colors.white70
                                    : Colors.grey.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpace.spaceW10,
                            Flexible(
                              child: Text(
                                NumberFormat("#,##0.00").format(currentVal),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: context.isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isUp
                                        ? Icons.arrow_drop_up_rounded
                                        : Icons.arrow_drop_down_rounded,
                                    color: statusColor,
                                    size: 18,
                                  ),
                                  Text(
                                    '${changeVal.abs().toStringAsFixed(2)} (${isUp ? '+' : ''}${changePct.toStringAsFixed(2)}%)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Compact Toggle
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0xFF1E222D)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: cont.chartParamList.map((param) {
                        final isSelected = cont.selectedChartParam == param;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => cont.changeChartParam(param),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (context.isDark
                                        ? const Color(0xFF2962FF)
                                        : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isSelected && !context.isDark
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              param,
                              style: TextStyle(
                                color: isSelected
                                    ? (context.isDark
                                          ? Colors.white
                                          : Colors.black87)
                                    : (context.isDark
                                          ? Colors.white54
                                          : Colors.grey.shade600),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Professional Stock Chart
            Builder(
              builder: (context) {
                final List<IndexCandleModel> activeData = cont.indexCandleList
                    .where((data) {
                      if (data.time == null) return false;
                      final int weekday = data.time!.weekday;
                      return weekday != DateTime.friday &&
                          weekday != DateTime.saturday;
                    })
                    .toList();

                if (activeData.isEmpty) {
                  return SizedBox(
                    height: 280,
                    child: Center(
                      child: Text(
                        "No Chart Data Available",
                        style: TextStyle(
                          color: context.isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }

                double maxVolume = 0;
                for (var item in activeData) {
                  if ((item.volume ?? 0) > maxVolume) {
                    maxVolume = item.volume ?? 0;
                  }
                }

                final double firstPrice = activeData.first.close ?? 0;
                final double lastPrice = activeData.last.close ?? 0;
                final bool isBullish = lastPrice >= firstPrice;

                final Color themeColor = isBullish
                    ? const Color(0xFF00C853)
                    : const Color(0xFFFF3D00);
                final Color volumeBullColor = const Color(0xFF00C853)
                    .withOpacity(0.35);
                final Color volumeBearColor = const Color(0xFFFF3D00)
                    .withOpacity(0.35);

                final LinearGradient areaGradient = LinearGradient(
                  colors: <Color>[
                    themeColor.withOpacity(0.30),
                    themeColor.withOpacity(0.0),
                  ],
                  stops: const <double>[0.0, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                );

                return Container(
                  height: 280,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: SfCartesianChart(
                    margin: EdgeInsets.zero,
                    plotAreaBorderWidth: 0,
                    backgroundColor: Colors.transparent,

                    zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true,
                      enablePanning: true,
                      zoomMode: ZoomMode.x,
                      maximumZoomLevel: 0.2,
                    ),

                    // 🚀 USE CACHED TRACKBALL HERE
                    trackballBehavior: _trackballBehavior,

                    primaryXAxis: DateTimeCategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelPlacement: LabelPlacement.onTicks,
                      dateFormat: _getDateFormat(cont.selectedChartParam),
                      intervalType: DateTimeIntervalType.auto,
                      axisLine: const AxisLine(width: 1, color: Colors.grey),
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: context.isDark
                            ? Colors.white60
                            : Colors.grey.shade600,
                      ),
                    ),

                    primaryYAxis: NumericAxis(
                      opposedPosition: false,
                      majorGridLines: MajorGridLines(
                        width: 1,
                        color: context.isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.05),
                        dashArray: const [5, 5],
                      ),
                      axisLine: const AxisLine(width: 0),
                      labelStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: context.isDark
                            ? Colors.white70
                            : Colors.grey.shade700,
                      ),
                      numberFormat: NumberFormat.compact(),
                    ),

                    axes: <ChartAxis>[
                      NumericAxis(
                        name: 'yAxisVolume',
                        opposedPosition: true,
                        isVisible: false,
                        minimum: 0,
                        maximum: maxVolume * 3.5,
                      ),
                    ],

                    series: <CartesianSeries>[
                      ColumnSeries<IndexCandleModel, DateTime>(
                        dataSource: activeData,
                        xValueMapper: (IndexCandleModel data, _) =>
                            data.time ?? DateTime.now(),
                        yValueMapper: (IndexCandleModel data, _) =>
                            data.volume ?? 0.0,
                        yAxisName: 'yAxisVolume',
                        pointColorMapper: (IndexCandleModel data, _) {
                          bool isBull = (data.close ?? 0) >= (data.open ?? 0);
                          return isBull ? volumeBullColor : volumeBearColor;
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(2),
                          topRight: Radius.circular(2),
                        ),
                        // 🚀 FIX: animationDuration 0 kora hoyeche jate live ashar somoy frame jhamela na kore
                        animationDuration: 0,
                      ),

                      AreaSeries<IndexCandleModel, DateTime>(
                        dataSource: activeData,
                        xValueMapper: (IndexCandleModel data, _) =>
                            data.time ?? DateTime.now(),
                        yValueMapper: (IndexCandleModel data, _) =>
                            data.close ?? 0.0,
                        gradient: areaGradient,
                        borderColor: themeColor,
                        borderWidth: 2,
                        markerSettings: const MarkerSettings(isVisible: false),
                        // 🚀 FIX: animationDuration 0 kora hoyeche jate trackball hide na hoy
                        animationDuration: 0,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
