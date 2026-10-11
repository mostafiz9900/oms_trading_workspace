import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app_pkg.dart';
import '../../../../global_widgets/empty_widget.dart';
import 'time_sales_charts_view.dart';
import '../../../../global_widgets/loaders/time_sales_list_loader.dart';

// =========================================================================
// =========================================================================
class TimeSalesTabWidget extends StatelessWidget {
  const TimeSalesTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return VisibleGetBuilder<HomeController>(
      id: 'timeAndSales',
      builder: (homeCon) {
        final sortedList = Helpers.sortByTstDesc([...homeCon.timeAndSales], (m) => m.tst ?? "");
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(children: [_OpenCloseBalanceWidget(homeCon: homeCon)]),
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _ToggleHeaderDelegate(
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Get.theme.scaffoldBackgroundColor, // ব্যাকগ্রাউন্ড কালার ঠিক রাখার জন্য
                    border: Border(bottom: BorderSide(color: context.dividerColor.withAlpha(50), width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        homeCon.isShowTimeSalesChart ? "Charts" : "List",
                        style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => homeCon.toggleTimeSalesChart(),
                        icon: Icon(
                          homeCon.isShowTimeSalesChart ? Icons.format_list_bulleted_rounded : Icons.bar_chart_rounded,
                          color: context.buttonColor,
                          size: 26,
                        ),
                        tooltip: 'Toggle View',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            homeCon.isLoadTimeSales
                ? TimeSalesListLoader()
                : homeCon.timeAndSales.isEmpty
                ? SliverToBoxAdapter(child: EmptyWidget())
                : homeCon.isShowTimeSalesChart
                ? SliverToBoxAdapter(child: TimeSalesChartsView(data: sortedList))
                : _StickyTapeListView(sortedList: sortedList),
          ],
        );
      },
    );
  }
}

// =========================================================================
// 🚀 2. Sticky Tape List View
// =========================================================================
class _StickyTapeListView extends StatelessWidget {
  final List<dynamic> sortedList;

  const _StickyTapeListView({required this.sortedList});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverHeaderDelegate(
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: context.tapBg),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 3, child: _TableTitleTextWidget(title: 'Time')),
                  Expanded(flex: 2, child: _TableTitleTextWidget(title: 'Price')),
                  Expanded(
                    flex: 2,
                    child: _TableTitleTextWidget(title: 'Volume', textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 2,
                    child: _TableTitleTextWidget(title: 'Side', textAlign: TextAlign.end),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final model = sortedList[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: index % 2 != 0 ? context.evenColor : context.oddColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 3, child: _TableTitleTextWidget(title: Helpers.formatTimeToString(model.tst ?? ''))),
                  Expanded(flex: 2, child: _TableTitleTextWidget(title: '${model.p ?? ''}')),
                  Expanded(
                    flex: 2,
                    child: _TableTitleTextWidget(title: '${model.v ?? ''}', textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 2,
                    child: _TableTitleTextWidget(
                      title: model.s ?? '',
                      textAlign: TextAlign.end,
                      textColor: model.s == 'BUY' ? ColorConstants.success : ColorConstants.error,
                    ),
                  ),
                ],
              ),
            );
          }, childCount: sortedList.length),
        ),
      ],
    );
  }
}

// 🚀 টগল বারের জন্য ডেলিগেট ক্লাস
class _ToggleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _ToggleHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  double get maxExtent => 45;

  @override
  double get minExtent => 45;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

// 🚀 টেবিল হেডারের জন্য ডেলিগেট ক্লাস
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  double get maxExtent => 35;

  @override
  double get minExtent => 35;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

// =========================================================================
// 🚀 3. Helper Widgets
// =========================================================================
class _TableTitleTextWidget extends StatelessWidget {
  const _TableTitleTextWidget({required this.title, this.textAlign, this.textColor});
  final String title;
  final TextAlign? textAlign;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      style: Get.textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor ?? context.textColor,
      ),
    );
  }
}

class _OpenCloseBalanceWidget extends StatelessWidget {
  const _OpenCloseBalanceWidget({required this.homeCon});
  final HomeController homeCon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.tapBg,
        border: Border.all(width: 1, color: context.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TitleValueColumnWidget(title: "Open", value: '${homeCon.marketData.open ?? '0.0'}'),
              _TitleValueColumnWidget(title: "High", value: '${homeCon.marketData.high ?? '0.0'}'),
              _TitleValueColumnWidget(
                title: "Low",
                value: '${homeCon.marketData.low ?? '0.0'}',
                valueColor: context.textColor,
              ),
            ],
          ),
          AppSpace.spaceH6,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TitleValueColumnWidget(
                title: "YCP",
                value: homeCon.marketData.reference?.toStringAsFixed(2) ?? '0.0',
                valueColor: ColorConstants.success,
              ),
              _TitleValueColumnWidget(
                title: "Volume",
                value: NumberFormatter.bdFormat(homeCon.marketData.volume ?? 0.0, decimalPlaces: 1),
                valueColor: context.buttonColor,
              ),
              _TitleValueColumnWidget(
                title: "Trades",
                value: '${homeCon.marketData.trades ?? '0.0'}',
                valueColor: context.buttonColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleValueColumnWidget extends StatelessWidget {
  const _TitleValueColumnWidget({required this.title, required this.value, this.valueColor});
  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, fontSize: 12)),
        Text(
          value,
          style: Get.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: valueColor ?? ColorConstants.success,
          ),
        ),
      ],
    );
  }
}
