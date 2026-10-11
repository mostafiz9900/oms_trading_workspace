import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../app_pkg.dart';
import '../../../controllers/live_index_controller.dart';

class _ChartData {
  final String label;
  final int value;
  _ChartData(this.label, this.value);
}

class HomePieChart extends StatelessWidget {
  const HomePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LiveIndexController>(
      builder: (homeCon) {
        final IndexModel? model = homeCon.newArr;

        // null or no-data handling
        if (model == null) {
          return const Center(child: Text('No data available'));
        }

        final data = [
          _ChartData('Up', model.u ?? 0),
          _ChartData('Down', model.d ?? 0),
          _ChartData('Unchanged', model.uc ?? 0),
        ];

        final total = data.fold<int>(0, (s, e) => s + e.value);
        if (total == 0) {
          return const Center(child: Text('No values to display'));
        }

        return Container(
          margin: const .all(10),
          padding: const .symmetric(horizontal: 2, vertical: 6),
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
          height: 260,
          child: SfCircularChart(
            title: ChartTitle(text: 'Market Movement'),
            legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x : point.y'),
            series: <PieSeries<_ChartData, String>>[
              PieSeries<_ChartData, String>(
                dataSource: data,
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.value,
                explode: true,
                pointColorMapper: (d, _) {
                  if (d.label == 'Up') return hexToColor('#22C665');
                  if (d.label == 'Down') return hexToColor('#F54D64');
                  return hexToColor('#177DFF');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
