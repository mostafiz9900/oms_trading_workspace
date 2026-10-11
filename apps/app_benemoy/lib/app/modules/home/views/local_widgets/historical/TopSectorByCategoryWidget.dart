import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../app_pkg.dart';
import '../index_value_loader.dart';

class TopSectorByCategoryWidget extends StatelessWidget {
  const TopSectorByCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: "marketListByShareType",
      builder: (homeCon) {
        if (homeCon.chartDataShareType.isEmpty) {
          return const CartesianChartLoader(title: 'Top Sectors By Category');
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
                padding: const EdgeInsets.only(top: 1.0),
                child: SfCartesianChart(
                  // 🚀 FIX: ভেতরের চার্টের এরিয়া ব্যাকগ্রাউন্ড ও বর্ডার ট্রান্সপারেন্ট করা হয়েছে
                  plotAreaBorderWidth: 0,
                  backgroundColor: Colors.transparent,

                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    canShowMarker: true,
                  ),
                  crosshairBehavior: CrosshairBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    lineType: CrosshairLineType.both,
                  ),

                  primaryXAxis: CategoryAxis(
                    labelRotation: -90,
                    interval: 1,
                    minimum: -0.5,
                    maximum: homeCon.chartDataShareType.isNotEmpty ? homeCon.chartDataShareType.length - 0.5 : null,
                    // 🚀 FIX: X-অক্ষ বরাবর গ্রিড লাইন অন করা হয়েছে (width: 0.5)
                    majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey.withOpacity(0.3)),
                    labelPlacement: LabelPlacement.onTicks,
                    labelIntersectAction: AxisLabelIntersectAction.rotate90,
                    labelAlignment: LabelAlignment.center,
                  ),
                  zoomPanBehavior: ZoomPanBehavior(enablePanning: true, enablePinching: true, zoomMode: ZoomMode.xy),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    // 🚀 CRASH FIX: interval: 5 রিমুভ করা হয়েছে যাতে বড় ভ্যালুতে অ্যাপ ক্র্যাশ না করে
                    // 🚀 FIX: Y-অক্ষ বরাবর গ্রিড লাইন অন রাখা হয়েছে
                    majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey.withOpacity(0.3)),
                  ),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                    alignment: ChartAlignment.center,
                    title: LegendTitle(
                      text: 'Top Sectors By Category',
                      alignment: ChartAlignment.center,
                      textStyle: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Get.theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  series: <CartesianSeries>[
                    StackedColumnSeries<dynamic, String>(
                      dataSource: homeCon.chartDataShareType,
                      xValueMapper: (data, _) => data['sector'],
                      yValueMapper: (data, _) => data['A'],
                      color: hexToColor('#2BE070'),
                      name: 'A',
                      enableTooltip: true,
                    ),
                    StackedColumnSeries<dynamic, String>(
                      dataSource: homeCon.chartDataShareType,
                      xValueMapper: (data, _) => data['sector'],
                      yValueMapper: (data, _) => data['B'],
                      color: hexToColor('#6864FF'),
                      name: 'B',
                      enableTooltip: true,
                    ),
                    StackedColumnSeries<dynamic, String>(
                      dataSource: homeCon.chartDataShareType,
                      xValueMapper: (data, _) => data['sector'],
                      yValueMapper: (data, _) => data['N'],
                      color: hexToColor('#177DFF'),
                      name: 'N',
                      enableTooltip: true,
                    ),
                    StackedColumnSeries<dynamic, String>(
                      dataSource: homeCon.chartDataShareType,
                      xValueMapper: (data, _) => data['sector'],
                      yValueMapper: (data, _) => data['Z'],
                      color: hexToColor('#FF495B'),
                      name: 'Z',
                      enableTooltip: true,
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
