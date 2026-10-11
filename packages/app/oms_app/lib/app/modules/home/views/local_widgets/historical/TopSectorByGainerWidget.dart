import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../app_pkg.dart';
import '../index_value_loader.dart';

class TopSectorByGainerWidget extends StatelessWidget {
  const TopSectorByGainerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: "marketListByGainer",
      builder: (homeCon) {
        if (homeCon.chartData.isEmpty) {
          return const CartesianChartLoader(title: 'Top Sectors By Gainer');
        }
        return Container(
          margin: const .symmetric(horizontal: 8, vertical: 2),
          // padding: const .symmetric(horizontal: 2, vertical: 0),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.alphaSafe(0.10),
                spreadRadius: 0,
                blurRadius: 5,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const .only(top: 1.0),
                child: SfCartesianChart(
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    canShowMarker: true,
                  ),
                  crosshairBehavior: CrosshairBehavior(
                    enable: true, // Enable crosshair
                    activationMode: ActivationMode.singleTap, // Show on tap
                    lineType: CrosshairLineType.both, // Show both vertical and horizontal lines
                  ),

                  primaryXAxis: CategoryAxis(
                    labelRotation: -90, // rotate labels to fit
                    interval: 1,
                    minimum: -0.5, // বামপাশের গ্যাপ (আগের মতোই থাকবে)
                    maximum: homeCon.chartData.isNotEmpty ? homeCon.chartData.length - 0.5 : null,
                    majorGridLines: const MajorGridLines(width: 0),
                    labelPlacement: LabelPlacement.onTicks,
                    labelIntersectAction: AxisLabelIntersectAction.rotate90, // show all labels
                    labelAlignment: LabelAlignment.center,
                  ),
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePanning: true, // allows horizontal scroll
                    enablePinching: true, // optional pinch zoom
                    zoomMode: ZoomMode.xy,
                    // enableSelectionZooming: true,
                    // only X-axis scroll/zoom
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    // maximum: 100,
                    interval: 5,
                    majorGridLines: const MajorGridLines(width: 0.5),
                  ),
                  legend: Legend(
                    isVisible: true, // Enable the legend
                    position: LegendPosition.top, // Position the legend at the top
                    alignment: ChartAlignment.center, // Center align the legend
                    title: LegendTitle(
                      text: 'Top Sectors By Gainer',
                      textStyle: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: context.textColor,
                      ),
                      // Optional: You can set a title for the legend
                    ),
                  ),

                  series: <CartesianSeries>[
                    StackedColumnSeries<dynamic, String>(
                      dataSource: homeCon.chartData,
                      xValueMapper: (data, _) => data['sector'],
                      yValueMapper: (data, _) => data['up'],
                      color: hexToColor('#22C665'),
                      name: 'Up',
                      enableTooltip: true,
                      dataLabelSettings: const DataLabelSettings(),
                    ),
                    StackedColumnSeries<dynamic, String>(
                      dataSource: homeCon.chartData,
                      xValueMapper: (data, _) => data['sector'],
                      yValueMapper: (data, _) => data['down'],
                      color: hexToColor('#F54D64'), // Down
                      name: 'Down',
                      enableTooltip: true,
                      dataLabelSettings: const DataLabelSettings(),
                    ),
                    StackedColumnSeries<dynamic, String>(
                      dataSource: homeCon.chartData,
                      xValueMapper: (data, _) => data['sector'],
                      yValueMapper: (data, _) => data['equal'],
                      color: hexToColor('#177DFF'), // Equa
                      name: 'Equal',
                      enableTooltip: true,
                      dataLabelSettings: const DataLabelSettings(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
