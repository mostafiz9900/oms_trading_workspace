import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../app_pkg.dart';

// =========================================================================
// =========================================================================
class TimeSalesChartsView extends StatelessWidget {
  final List<dynamic> data; // TimeAndSalesModel

  const TimeSalesChartsView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final chartData = data.reversed.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          // আগের দুটি চার্ট
          CombinedPriceVolumeChart(chartData: chartData),
          AppSpace.spaceH12,
          WhaleTrackerChart(chartData: chartData),
          AppSpace.spaceH12,

          // 🚀 নতুন ৩টি প্রো-চার্ট
          CvdLineChart(chartData: chartData),
          AppSpace.spaceH12,
          BuySellBreakdownChart(chartData: chartData),
          AppSpace.spaceH12,
          TradeSizeHistogramChart(chartData: chartData),
        ],
      ),
    );
  }
}

// =========================================================================
// =========================================================================
class WhaleTrackerChart extends StatelessWidget {
  final List<dynamic> chartData;

  const WhaleTrackerChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      context: context,
      title: "Whale Tracker (Trade Size)",
      height: 250,
      chart: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x),
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          lineType: TrackballLineType.vertical,
          lineColor: context.isDark ? Colors.white30 : Colors.black26,
          tooltipSettings: InteractiveTooltip(
            enable: true,
            color: context.isDark ? Colors.grey.shade900 : Colors.black87,
            format: 'Price: point.y\nVol: point.size',
            textStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            borderRadius: 6,
          ),
        ),
        primaryXAxis: _buildXAxis(chartData),
        primaryYAxis: NumericAxis(
          opposedPosition: true,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: MajorGridLines(color: Colors.grey.withOpacity(0.15), dashArray: const [4, 4]),
          axisLine: const AxisLine(width: 0),
          labelStyle: Get.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: 10),
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            return ChartAxisLabel(details.value.toStringAsFixed(2), details.textStyle);
          },
        ),
        series: <CartesianSeries>[
          BubbleSeries<dynamic, int>(
            dataSource: chartData,
            xValueMapper: (_, index) => index,
            yValueMapper: (model, _) => model.p,
            sizeValueMapper: (model, _) => model.v,
            pointColorMapper: (model, _) =>
                model.s == 'BUY' ? ColorConstants.success.withOpacity(0.6) : ColorConstants.error.withOpacity(0.6),
            borderColor: context.isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
            borderWidth: 1,
            minimumRadius: 3,
            maximumRadius: 18,
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// =========================================================================
class CombinedPriceVolumeChart extends StatelessWidget {
  final List<dynamic> chartData;

  const CombinedPriceVolumeChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    double maxVol = 0;
    double maxPrice = 0;
    double minPrice = double.infinity;

    for (var model in chartData) {
      double vol = (model.v ?? 0).toDouble();
      double price = (model.p ?? 0.0).toDouble();

      if (vol > maxVol) maxVol = vol;
      if (price > maxPrice) maxPrice = price;
      if (price > 0 && price < minPrice) minPrice = price;
    }

    if (maxVol == 0) maxVol = 10;
    if (minPrice == double.infinity) minPrice = 0;

    double baselinePrice = chartData.isNotEmpty ? (chartData.first.p ?? minPrice) : minPrice;
    double priceDiff = maxPrice - minPrice;
    if (priceDiff == 0) priceDiff = 1;

    double yAxisMin = minPrice - (priceDiff * 0.4);
    double yAxisMax = maxPrice + (priceDiff * 0.25);

    bool isOverallPositive = true;
    if (chartData.length >= 2) {
      double firstPrice = (chartData.first.p ?? 0.0).toDouble();
      double lastPrice = (chartData.last.p ?? 0.0).toDouble();
      isOverallPositive = lastPrice >= firstPrice;
    }
    final Color trendColor = isOverallPositive ? ColorConstants.success : ColorConstants.error;

    return _ChartCard(
      context: context,
      title: "Price Trend & Tick Volume",
      height: 280,
      chart: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x),
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          lineType: TrackballLineType.vertical,
          lineColor: context.isDark ? Colors.white30 : Colors.black26,
          tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          tooltipSettings: InteractiveTooltip(
            enable: true,
            color: context.isDark ? Colors.grey.shade900 : Colors.black87,
            textStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            borderRadius: 6,
          ),
        ),
        primaryXAxis: _buildXAxis(chartData),
        primaryYAxis: NumericAxis(
          name: 'PriceAxis',
          opposedPosition: true,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: MajorGridLines(color: Colors.grey.withOpacity(0.15), dashArray: const [4, 4]),
          axisLine: const AxisLine(width: 0),
          labelStyle: Get.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: 10),
          minimum: yAxisMin,
          maximum: yAxisMax,
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            return ChartAxisLabel(details.value.toStringAsFixed(2), details.textStyle);
          },
          plotBands: <PlotBand>[
            PlotBand(
              isVisible: true,
              start: baselinePrice,
              end: baselinePrice,
              borderColor: trendColor.withOpacity(0.6),
              borderWidth: 1.2,
              dashArray: const <double>[5, 5],
              text: 'Ref',
              textStyle: TextStyle(color: trendColor, fontSize: 9, fontWeight: FontWeight.bold),
              horizontalTextAlignment: TextAnchor.start,
            ),
          ],
        ),
        axes: <ChartAxis>[
          NumericAxis(name: 'VolumeAxis', opposedPosition: false, isVisible: false, minimum: 0, maximum: maxVol * 1.5),
        ],
        series: <CartesianSeries>[
          ColumnSeries<dynamic, int>(
            name: 'Vol',
            dataSource: chartData,
            xValueMapper: (_, index) => index,
            yValueMapper: (model, _) => model.v,
            yAxisName: 'VolumeAxis',
            width: 0.9,
            spacing: 0.1,
            pointColorMapper: (model, _) =>
                model.s == 'BUY' ? ColorConstants.success.withOpacity(0.7) : ColorConstants.error.withOpacity(0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            animationDuration: 0,
          ),
          AreaSeries<dynamic, int>(
            name: 'Price',
            dataSource: chartData,
            xValueMapper: (_, index) => index,
            yValueMapper: (model, _) => model.p,
            yAxisName: 'PriceAxis',
            borderColor: trendColor,
            borderWidth: 2.5,
            gradient: LinearGradient(
              colors: [trendColor.withOpacity(0.4), trendColor.withOpacity(0.02)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// =========================================================================
class CvdModel {
  final int index;
  final double cvd;
  final String tst;
  CvdModel(this.index, this.cvd, this.tst);
}

class CvdLineChart extends StatelessWidget {
  final List<dynamic> chartData;

  const CvdLineChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    // ক্যালকুলেশন: BUY হলে প্লাস, SELL হলে মাইনাস
    List<CvdModel> cvdList = [];
    double runningCvd = 0;
    for (int i = 0; i < chartData.length; i++) {
      var model = chartData[i];
      double vol = (model.v ?? 0).toDouble();
      if (model.s == 'BUY') {
        runningCvd += vol;
      } else {
        runningCvd -= vol;
      }
      cvdList.add(CvdModel(i, runningCvd, model.tst ?? ''));
    }

    bool isPositive = runningCvd >= 0;
    Color cvdColor = isPositive ? ColorConstants.success : ColorConstants.error;

    return _ChartCard(
      context: context,
      title: "Cumulative Volume Delta (CVD)",
      height: 220,
      chart: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x),
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          lineType: TrackballLineType.vertical,
          lineColor: context.isDark ? Colors.white30 : Colors.black26,
          tooltipSettings: InteractiveTooltip(
            enable: true,
            color: context.isDark ? Colors.grey.shade900 : Colors.black87,
            format: 'CVD: point.y',
            textStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            borderRadius: 6,
          ),
        ),
        primaryXAxis: _buildXAxis(chartData),
        primaryYAxis: NumericAxis(
          opposedPosition: true,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: MajorGridLines(color: Colors.grey.withOpacity(0.15), dashArray: const [4, 4]),
          axisLine: const AxisLine(width: 0),
          labelStyle: Get.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: 10),
        ),
        series: <CartesianSeries>[
          FastLineSeries<CvdModel, int>(
            dataSource: cvdList,
            xValueMapper: (CvdModel model, _) => model.index,
            yValueMapper: (CvdModel model, _) => model.cvd,
            color: cvdColor,
            width: 2.2,
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// =========================================================================
class BuySellBreakdownChart extends StatelessWidget {
  final List<dynamic> chartData;

  const BuySellBreakdownChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      context: context,
      title: "Buy vs Sell Volume Split",
      height: 220,
      chart: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x),
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          lineType: TrackballLineType.vertical,
          lineColor: context.isDark ? Colors.white30 : Colors.black26,
          tooltipSettings: InteractiveTooltip(
            enable: true,
            color: context.isDark ? Colors.grey.shade900 : Colors.black87,
            format: 'series.name: point.y',
            textStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            borderRadius: 6,
          ),
        ),
        primaryXAxis: _buildXAxis(chartData),
        primaryYAxis: NumericAxis(
          opposedPosition: true,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: MajorGridLines(color: Colors.grey.withOpacity(0.15), dashArray: const [4, 4]),
          axisLine: const AxisLine(width: 0),
          labelStyle: Get.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: 10),
        ),
        series: <CartesianSeries>[
          ColumnSeries<dynamic, int>(
            name: 'Buy Vol',
            dataSource: chartData,
            xValueMapper: (_, index) => index,
            yValueMapper: (model, _) => model.s == 'BUY' ? model.v : 0,
            color: ColorConstants.success.withOpacity(0.8),
            width: 0.8,
            animationDuration: 0,
          ),
          ColumnSeries<dynamic, int>(
            name: 'Sell Vol',
            dataSource: chartData,
            xValueMapper: (_, index) => index,
            yValueMapper: (model, _) => model.s == 'SELL' ? model.v : 0,
            color: ColorConstants.error.withOpacity(0.8),
            width: 0.8,
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// =========================================================================
class TradeSizeHistogramChart extends StatelessWidget {
  final List<dynamic> chartData;

  const TradeSizeHistogramChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      context: context,
      title: "Trade Frequency by Volume Size",
      height: 220,
      chart: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true, zoomMode: ZoomMode.x),
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          lineType: TrackballLineType.vertical,
          lineColor: context.isDark ? Colors.white30 : Colors.black26,
          tooltipSettings: InteractiveTooltip(
            enable: true,
            color: context.isDark ? Colors.grey.shade900 : Colors.black87,
            format: 'Volume: point.y',
            textStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            borderRadius: 6,
          ),
        ),
        primaryXAxis: _buildXAxis(chartData),
        primaryYAxis: NumericAxis(
          opposedPosition: true,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: MajorGridLines(color: Colors.grey.withOpacity(0.15), dashArray: const [4, 4]),
          axisLine: const AxisLine(width: 0),
          labelStyle: Get.textTheme.labelSmall?.copyWith(color: Colors.grey, fontSize: 10),
        ),
        series: <CartesianSeries>[
          SplineAreaSeries<dynamic, int>(
            dataSource: chartData,
            xValueMapper: (_, index) => index,
            yValueMapper: (model, _) => model.v,
            color: context.buttonColor.withOpacity(0.2),
            borderColor: context.buttonColor,
            borderWidth: 2,
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 🛠️ Shared Helpers & Card Wrapper
// =========================================================================
NumericAxis _buildXAxis(List<dynamic> chartData) {
  return NumericAxis(
    isVisible: true,
    edgeLabelPlacement: EdgeLabelPlacement.shift,
    majorGridLines: const MajorGridLines(width: 0),
    axisLine: const AxisLine(width: 0.5, color: Colors.grey),
    labelStyle: const TextStyle(color: Colors.grey, fontSize: 9),
    interactiveTooltip: const InteractiveTooltip(enable: true),
    axisLabelFormatter: (AxisLabelRenderDetails details) {
      int index = details.value.toInt();
      if (index >= 0 && index < chartData.length) {
        String time = Helpers.formatTimeToString(chartData[index].tst ?? '');
        return ChartAxisLabel(time, details.textStyle);
      }
      return ChartAxisLabel('', details.textStyle);
    },
  );
}

class _ChartCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final double height;
  final Widget chart;

  const _ChartCard({required this.context, required this.title, required this.height, required this.chart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8, left: 10, right: 10),
      decoration: BoxDecoration(
        color: context.isDark ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.isDark ? Colors.white10 : Colors.grey.shade200, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                title,
                style: Get.textTheme.labelMedium?.copyWith(
                  color: context.isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: height, child: chart),
        ],
      ),
    );
  }
}
