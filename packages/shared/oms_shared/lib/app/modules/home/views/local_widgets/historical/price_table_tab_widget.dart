// lib/screens/price_table_screen.dart
import 'package:oms_shared/app/core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import '../../../../../app_pkg.dart';
import '../../../controllers/historical_volume_controller.dart';
import '../index_value_loader.dart';

class PriceTableTabWidget extends StatelessWidget {
  const PriceTableTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      HistoricalVolumeController(repository: Get.find<HomeRepository>()),
    );
    // printLog('build :::::volume controller:::::${controller.homeController.marketData.shortName}');
    return GetBuilder<HistoricalVolumeController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const PriceTableLoader();
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildDaysSelector(controller, context),
                  const SizedBox(height: 10),
                  _buildStatsGrid(controller, context),
                  // const SizedBox(height: 10),
                ],
              ),
            ),
            // এখানে টেবিলটি বসবে
            SliverFillRemaining(
              hasScrollBody: true,
              child: _buildDataTable(context, controller),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDaysSelector(
    HistoricalVolumeController controller,
    BuildContext ctx,
  ) {
    return Row(
      mainAxisAlignment: .start,
      children: [
        AppSpace.spaceW20,
        const Text("Last  "),
        Container(
          height: 30,
          width: 90, // আপনার ড্রপডাউনের নির্দিষ্ট সাইজ
          decoration: BoxDecoration(
            color: Colors.transparent, // অথবা context.tapBg
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton2<int>(
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: Text(
              controller.selectedDays.toString(),
              style: const TextStyle(fontSize: 14),
            ),
            // সিলেক্টেড আইটেমের ভিউ
            selectedItemBuilder: (context) {
              return controller.daysOptions.map((item) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    item.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList();
            },
            // লিস্ট আইটেমসমূহ
            items: controller.daysOptions.map((item) {
              final isSelected = controller.selectedDays == item;
              return DropdownItem<int>(
                value: item,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "$item",
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.blue : ctx.textColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 18,
                      ),
                  ],
                ),
              );
            }).toList(),
            valueListenable: controller.daysNotifier,
            // valueListenable: ValueNotifier<int?>(controller.selectedDays),
            onChanged: (val) {
              if (val != null) {
                controller.setDaysFilter(val);
              }
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 8),
              height: 30,
              width: double.infinity,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: Get.height * 0.8,
              decoration: BoxDecoration(
                color: ctx.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              overlayColor: WidgetStateProperty.all(
                Colors.blue.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
        const Text("  working days"),
      ],
    );
  }

  Widget _buildStatsGrid(
    HistoricalVolumeController controller,
    BuildContext ctx,
  ) {
    final stats = [
      {
        'label': 'Avg Price',
        'value': NumberFormatter.bdFormat(
          controller.avgPrice,
          decimalPlaces: 1,
        ),
        'color': ctx.textColor,
      },
      {
        'label': 'Max Price',
        'value': NumberFormatter.bdFormat(
          controller.maxPrice,
          decimalPlaces: 1,
        ),
        'color': ctx.textColor,
      },
      {
        'label': 'Min Price',
        'value': NumberFormatter.bdFormat(
          controller.minPriceValue,
          decimalPlaces: 1,
        ),
        'color': ctx.textColor,
      },
      {
        'label': 'Change',
        'value': controller.priceChange.toStringAsFixed(1),
        'color': controller.isPricePositive ? Colors.green : Colors.red,
      },
      {
        'label': 'Avg Volume',
        'value': NumberFormatter.bdFormat(
          controller.avgVolume,
          decimalPlaces: 0,
        ),
        'color': ctx.textColor,
      },
      {
        'label': 'Max Volume',
        'value': NumberFormatter.bdFormat(
          controller.maxVolume,
          decimalPlaces: 0,
        ),
        'color': ctx.textColor,
      },
      {
        'label': 'Min Volume',
        'value': NumberFormatter.bdFormat(
          controller.minVolume,
          decimalPlaces: 0,
        ),
        'color': ctx.textColor,
      },
      {
        'label': 'Change(%)',
        'value': '${controller.priceChangePercent.toStringAsFixed(1)}%',
        'color': controller.isPricePositive ? Colors.green : Colors.red,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.0,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => Column(
        children: [
          Text(
            stats[i]['label'] as String,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            stats[i]['value'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: stats[i]['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    HistoricalVolumeController controller,
  ) {
    double colW = ((Get.width - 100) / 5).clamp(50.0, 100.0);
    return HorizontalDataTable(
      leftHandSideColumnWidth: 100,
      rightHandSideColumnWidth: colW * 5,
      isFixedHeader: true,

      headerWidgets: _buildHeaders(context, colW, controller),
      leftSideItemBuilder: _generateFirstColumnRow,
      rightSideItemBuilder: (ctx, index) =>
          _generateRightHandSideRow(ctx, index, colW),
      itemCount: controller.filteredData.length,
      rowSeparatorWidget: Divider(
        color: Theme.of(context).dividerColor,
        height: 1.0,
      ),
      leftHandSideColBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      rightHandSideColBackgroundColor: Theme.of(context)
          .scaffoldBackgroundColor,
    );
  }

  List<Widget> _buildHeaders(
    BuildContext context,
    double w,
    HistoricalVolumeController controller,
  ) {
    return [
      _buildHeaderCell('Date', 100, context, controller),
      _buildHeaderCell('Open', w, context, controller),
      _buildHeaderCell('High', w, context, controller),
      _buildHeaderCell('Low', w, context, controller),
      _buildHeaderCell('Close', w, context, controller),
      _buildHeaderCell('Volume', w, context, controller),
      // _buildHeaderCell('Change', w, context, controller),
      // _buildHeaderCell('Ch(%)', w, context, controller),
    ];
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    var item = Get.find<HistoricalVolumeController>().filteredData[index];
    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        Get.find<HistoricalVolumeController>().formatDate(item.date),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Get.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _generateRightHandSideRow(BuildContext context, int index, double w) {
    var item = Get.find<HistoricalVolumeController>().filteredData[index];
    final color = item.priceChange == 0
        ? Theme.of(context).textTheme.bodyMedium?.color
        : (item.isPositive ? Colors.green : Colors.red);
    final ctrl = Get.find<HistoricalVolumeController>();

    return Row(
      children: [
        _buildCell(NumberFormatter.bdFormat(item.open), color, w),
        _buildCell(NumberFormatter.bdFormat(item.high), color, w),
        _buildCell(NumberFormatter.bdFormat(item.low), color, w),
        _buildCell(NumberFormatter.bdFormat(item.close), color, w),
        _buildCell(NumberFormatter.croreFormat('${item.volume}'), color, w),
        // _buildCell(item.priceChange.toStringAsFixed(2), color, w),
        // _buildCell('${item.priceChangePercent.toStringAsFixed(2)}%', color, w),
      ],
    );
  }

  Widget _buildCell(String text, Color? color, double width) {
    return SizedBox(
      width: width,
      height: 40,
      child: Center(
        child: Text(text, style: TextStyle(color: color, fontSize: 12)),
      ),
    );
  }

  Widget _buildHeaderCell(
    String label,
    double width,
    BuildContext context,
    HistoricalVolumeController controller,
  ) {
    bool isSelected = controller.sortBy == label;

    return InkWell(
      onTap: () => controller.setSortBy(label),
      child: Container(
        width: width,
        height: 40,
        alignment: Alignment.center,
        color: context.tapBg,
        margin: .only(top: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected
                    ? Colors.blue
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (isSelected)
              Icon(
                controller.sortAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 12,
                color: Colors.blue,
              )
            else
              const Icon(Icons.sort, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
/*
// lib/screens/price_table_screen.dart
import 'package:oms_shared/app/core/core.dart';
import 'package:oms_shared/app/core/utils/helpers/formatter_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import '../../../../../app_pkg.dart';
import '../../../controllers/historical_volume_controller.dart';

class PriceTableTabWidget extends StatelessWidget {
  const PriceTableTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      HistoricalVolumeController(repository: Get.find<HomeRepository>()),
    );
    
    return GetBuilder<HistoricalVolumeController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 👈 FIX 1: টেবিলের মোট হাইট ডায়নামিক ভাবে হিসাব করা হলো
        // হেডার হাইট: 46 (40 + 6 margin)
        // প্রতিটি রো হাইট: 41 (40 + 1 divider)
        double tableHeight = 46.0 + (controller.filteredData.length * 41.0) + 20.0; // 20.0 বাফার সাইজ

        return CustomScrollView(
          // 👈 FIX 2: BouncingScrollPhysics দেওয়া হলো যেন স্ক্রলিং ন্যাচারাল হয়
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildDaysSelector(controller, context),
                  const SizedBox(height: 10),
                  _buildStatsGrid(controller, context),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            // 👈 FIX 3: SliverFillRemaining এর বদলে SliverToBoxAdapter ও SizedBox ব্যবহার করা হলো
            SliverToBoxAdapter(
              child: SizedBox(
                height: tableHeight, 
                child: _buildDataTable(context, controller),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDaysSelector(HistoricalVolumeController controller, BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AppSpace.spaceW20,
        const Text("Last  "),
        Container(
          height: 30,
          width: 90, 
          decoration: BoxDecoration(
            color: Colors.transparent, 
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton2<int>(
            isExpanded: true,
            underline: const SizedBox.shrink(),
            hint: Text(controller.selectedDays.toString(), style: const TextStyle(fontSize: 14)),
            selectedItemBuilder: (context) {
              return controller.daysOptions.map((item) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(item.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                );
              }).toList();
            },
            items: controller.daysOptions.map((item) {
              final isSelected = controller.selectedDays == item;
              return DropdownItem<int>(
                value: item,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "$item",
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.blue : ctx.textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle, color: Colors.blue, size: 18),
                  ],
                ),
              );
            }).toList(),
            valueListenable: controller.daysNotifier,
            onChanged: (val) {
              if (val != null) {
                controller.setDaysFilter(val);
              }
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 8),
              height: 30,
              width: double.infinity,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: Get.height * 0.8,
              decoration: BoxDecoration(color: ctx.cardColor, borderRadius: BorderRadius.circular(8)),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              overlayColor: WidgetStateProperty.all(Colors.blue.withValues(alpha: 0.1)),
            ),
          ),
        ),
        const Text("  working days"),
      ],
    );
  }

  Widget _buildStatsGrid(HistoricalVolumeController controller, BuildContext ctx) {
    final stats = [
      {
        'label': 'Avg Price',
        'value': NumberFormatter.bdFormat(controller.avgPrice, decimalPlaces: 1),
        'color': ctx.textColor,
      },
      {
        'label': 'Max Price',
        'value': NumberFormatter.bdFormat(controller.maxPrice, decimalPlaces: 1),
        'color': ctx.textColor,
      },
      {
        'label': 'Min Price',
        'value': NumberFormatter.bdFormat(controller.minPriceValue, decimalPlaces: 1),
        'color': ctx.textColor,
      },
      {
        'label': 'Avg Volume',
        'value': NumberFormatter.bdFormat(controller.avgVolume, decimalPlaces: 0),
        'color': ctx.textColor,
      },
      {
        'label': 'Max Volume',
        'value': NumberFormatter.bdFormat(controller.maxVolume, decimalPlaces: 0),
        'color': ctx.textColor,
      },
      {
        'label': 'Min Volume',
        'value': NumberFormatter.bdFormat(controller.minVolume, decimalPlaces: 0),
        'color': ctx.textColor,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 2.0),
      itemCount: stats.length,
      itemBuilder: (_, i) => Column(
        children: [
          Text(stats[i]['label'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            stats[i]['value'] as String,
            style: TextStyle(fontWeight: FontWeight.bold, color: stats[i]['color'] as Color),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, HistoricalVolumeController controller) {
    const double colW = 90.0;

    return HorizontalDataTable(
      leftHandSideColumnWidth: 100,
      rightHandSideColumnWidth: colW * 5,
      isFixedHeader: true,
      
      // 👈 FIX 4: ভেতরের স্ক্রল অফ করা হলো যেন বাইরের স্ক্রল পারফেক্টলি কাজ করে
      scrollPhysics: const NeverScrollableScrollPhysics(), 

      headerWidgets: _buildHeaders(context, colW, controller),
      leftSideItemBuilder: _generateFirstColumnRow,
      rightSideItemBuilder: (ctx, index) => _generateRightHandSideRow(ctx, index, colW),
      itemCount: controller.filteredData.length,
      rowSeparatorWidget: Divider(color: Theme.of(context).dividerColor, height: 1.0),
      leftHandSideColBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      rightHandSideColBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  List<Widget> _buildHeaders(BuildContext context, double w, HistoricalVolumeController controller) {
    return [
      _buildHeaderCell('Date', 100, context, controller),
      _buildHeaderCell('Open', w, context, controller),
      _buildHeaderCell('High', w, context, controller),
      _buildHeaderCell('Low', w, context, controller),
      _buildHeaderCell('Close', w, context, controller),
      _buildHeaderCell('Volume', w, context, controller),
    ];
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    var item = Get.find<HistoricalVolumeController>().filteredData[index];
    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        Get.find<HistoricalVolumeController>().formatDate(item.date),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Get.textTheme.bodyMedium?.color),
      ),
    );
  }

  Widget _generateRightHandSideRow(BuildContext context, int index, double w) {
    var item = Get.find<HistoricalVolumeController>().filteredData[index];
    final color = item.priceChange == 0
        ? Theme.of(context).textTheme.bodyMedium?.color
        : (item.isPositive ? Colors.green : Colors.red);

    return Row(
      children: [
        _buildCell(NumberFormatter.bdFormat(item.open), color, w),
        _buildCell(NumberFormatter.bdFormat(item.high), color, w),
        _buildCell(NumberFormatter.bdFormat(item.low), color, w),
        _buildCell(NumberFormatter.bdFormat(item.close), color, w),
        _buildCell(NumberFormatter.formatAmount('${item.volume}'), color, w),
      ],
    );
  }

  Widget _buildCell(String text, Color? color, double width) {
    return SizedBox(
      width: width,
      height: 40,
      child: Center(
        child: Text(text, style: TextStyle(color: color, fontSize: 12)),
      ),
    );
  }

  Widget _buildHeaderCell(String label, double width, BuildContext context, HistoricalVolumeController controller) {
    bool isSelected = controller.sortBy == label;

    return InkWell(
      onTap: () => controller.setSortBy(label),
      child: Container(
        width: width,
        height: 40,
        alignment: Alignment.center,
        color: context.tapBg,
        margin: const EdgeInsets.only(top: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? Colors.blue : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (isSelected)
              Icon(controller.sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: Colors.blue)
            else
              const Icon(Icons.sort, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
*/
