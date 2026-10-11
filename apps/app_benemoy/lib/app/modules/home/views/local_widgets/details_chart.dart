import 'package:app_benemoy/app/app_pkg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DetailsChart extends StatelessWidget {
  const DetailsChart({Key? key}) : super(key: key);

  // Data read from the image (adjust as needed)
  final List<String> categories = const [
    '<-10%', // 0
    '-10~-7%', // 1
    '-7~-5%', // 2
    '-5~-2%', // 3
    '-2~0%', // 4
    '0', // 5
    '0-2%', // 6
    '2-5%', // 7
    '5-7%', // 8
    '7-10%', // 9
    '>10%', // 10
  ];

  // Values correspond to categories above
  final List<int> values = const [0, -1, 0, -5, 20, 24, 114, 130, 28, 40, 1];

  // Legend counts
  final int negCount = 26;
  final int ncCount = 24;
  final int posCount = 313;

  // Colors used in the image
  Color get negColor => const Color(0xFFe56666); // red-ish
  Color get ncColor => const Color(0xFF6e6e6e); // grey
  Color get posColor => const Color(0xFF18A588); // teal/green

  @override
  Widget build(BuildContext context) {
    final total = negCount + ncCount + posCount;
    return Card(
      margin: const .all(12),
      color: context.bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const .symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            // Title row (optional)
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                const Text('Distribution by % range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                // small legend summary
                // Row(
                //   children: [
                //     _legendItem(negColor, 'NEG: $negCount'),
                //     const SizedBox(width: 8),
                //     _legendItem(ncColor, 'NC: $ncCount'),
                //     const SizedBox(width: 8),
                //     _legendItem(posColor, 'POS: $posCount'),
                //   ],
                // )
              ],
            ),
            const SizedBox(height: 12),
            // The vertical bar chart area
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (values.reduce((a, b) => a > b ? a : b)).toDouble() + 20,
                  barGroups: _makeBarGroups(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 86,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          // value is index
                          final int i = value.toInt();
                          final label = (i >= 0 && i < categories.length) ? categories[i] : '';
                          return SideTitleWidget(
                            meta: meta,
                            child: Padding(
                              padding: const .only(top: 8.0),
                              child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
                            ),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawHorizontalLine: true),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // tooltipBgColor: Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final value = values[group.x.toInt()];
                        return BarTooltipItem('$value', const TextStyle(color: Colors.white));
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Values above the bars: show a small row of numbers above the bottom stacked area (optional)
            _buildBottomStack(total),
            const SizedBox(height: 6),
            // A horizontal representation (long green bar with colored segments)
            _stackedSummaryBar(total),
          ],
        ),
      ),
    );
  }

  // Build bar groups for fl_chart using the values list
  List<BarChartGroupData> _makeBarGroups() {
    final List<BarChartGroupData> groups = [];
    for (int i = 0; i < values.length; i++) {
      final val = values[i].toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 2,
          barRods: [
            BarChartRodData(
              toY: val,
              width: 14,
              borderRadius: BorderRadius.circular(6),
              color: val == 0 ? Colors.grey.shade300 : const Color(0xFF18A588),
              // show a gradient for positive-looking bars (optional)
            ),
          ],
        ),
      );
    }
    return groups;
  }

  // Legend small item
  Widget _legendItem(Color c, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Build the counts labels row that appear above the stacked bar for clarity
  Widget _buildBottomStack(int total) {
    // The same ordering as stacked bar: NEG, NC, POS
    final parts = [negCount, ncCount, posCount];
    final colors = [negColor, ncColor, posColor];

    return Row(
      mainAxisAlignment: .center,
      children: List.generate(parts.length, (i) {
        if (parts[i] == 0) return const SizedBox.shrink();
        return Padding(
          padding: const .symmetric(horizontal: 10),
          child: Column(
            children: [
              Text('${parts[i]}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: 42,
                height: 6,
                decoration: BoxDecoration(color: colors[i], borderRadius: BorderRadius.circular(3)),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Custom horizontal stacked bar widget
  Widget _stackedSummaryBar(int total) {
    final double negFraction = negCount / total;
    final double ncFraction = ncCount / total;
    final double posFraction = posCount / total;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        // Stacked bar itself
        Container(
          height: 28,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              // NEG
              if (negCount > 0)
                Flexible(
                  flex: (negFraction * 1000).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: negColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                ),
              // NC
              if (ncCount > 0)
                Flexible(
                  flex: (ncFraction * 1000).round(),
                  child: Container(color: ncColor),
                ),
              // POS
              if (posCount > 0)
                Flexible(
                  flex: (posFraction * 1000).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: posColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Legend row with exact counts (left aligned)
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            _legendItem(negColor, 'NEG: $negCount'),
            _legendItem(ncColor, 'NC: $ncCount'),
            _legendItem(posColor, 'POS: $posCount'),
          ],
        ),
      ],
    );
  }
}

////////////////////////////
class Stock {
  final String symbol;
  final double changePct;
  Stock(this.symbol, this.changePct);
}

class Bucket {
  final String label;
  final double min; // inclusive or -inf
  final double max; // exclusive or +inf
  final bool isCenter;
  Bucket(this.label, this.min, this.max, {this.isCenter = false});
}
