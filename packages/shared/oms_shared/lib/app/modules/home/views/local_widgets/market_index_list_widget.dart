import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app_pkg.dart';
import '../../controllers/live_index_controller.dart';
import 'index_value_loader.dart';

class MarketIndexListWidget extends StatelessWidget {
  const MarketIndexListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat("MMM d, y 'at' h:mm a");

    // 🚀 GetBuilder এখন LiveIndexController কে পয়েন্ট করবে
    return GetBuilder<LiveIndexController>(
      // init: LiveIndexController(), // যদি আগে put করা না থাকে
      id: "index_list",
      builder: (indexCon) {
        if (indexCon.indexList.isEmpty) {
          return const IndexListLoader();
        }
        final DateTime updateTime = indexCon.lastIndexUpdateTime ?? DateTime.now();
        final visibleIndices = indexCon.visibleIndexList;

        return Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: const Border(bottom: BorderSide(color: Colors.black26)),
                  color: context.isDark ? hexToColor('#161A33') : ColorConstants.yaleBlue,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Last update on ${formatter.format(updateTime)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleIndices.length,
                itemBuilder: (context, index) {
                  IndexModel model = visibleIndices[index];
                  final bool isSelected = indexCon.newArr?.sn == model.sn;

                  var style = Get.textTheme.titleMedium?.copyWith(
                    fontSize: AppDimens.space14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  );

                  return Container(
                    key: ValueKey(model.sn),
                    decoration: BoxDecoration(
                      color: context.isDark ? hexToColor('#161A33') : null,
                      border: Border(bottom: BorderSide(color: context.borderSideColor, width: 1)),
                    ),
                    child: InkWell(
                      onTap: () {
                        indexCon.getSumOfAllIndex(model);
                        // 🚀 MarketIndexController আগের মতোই কাজ করবে
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: context.isDark ? null : ColorConstants.yaleBlue),
                                child: Text(
                                  model.sn ?? "",
                                  style: Get.textTheme.titleMedium?.copyWith(
                                    fontSize: AppDimens.space16,
                                    color: context.isDark ? ColorConstants.secondaryColorDark : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: context.isDark ? null : const Color(0xFFF8F9FA)),
                                child: Center(child: Text(NumberFormatter.bdFormat(model.civ ?? 0), style: style)),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  model.ivd?.toDouble().toStringAsFixed(2) ?? "",
                                  style: Get.textTheme.titleMedium?.copyWith(
                                    fontSize: AppDimens.space14,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    color: model.ivd?.isNegative == true ? Colors.redAccent : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: context.isDark ? null : ColorConstants.unselectedItemColorLight,
                                ),
                                child: Center(
                                  child: Text(
                                    '${model.ip?.toDouble().toStringAsFixed(2) ?? ""}%',
                                    style: Get.textTheme.titleMedium?.copyWith(
                                      fontSize: AppDimens.space14,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: model.ip?.isNegative == true ? Colors.redAccent : Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Icon(
                                model.ip?.isNegative == true
                                    ? Icons.keyboard_double_arrow_down
                                    : Icons.keyboard_double_arrow_up,
                                color: model.ip?.isNegative == true ? Colors.redAccent : Colors.green,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class TradeSummaryGridWidget extends StatelessWidget {
  const TradeSummaryGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 GetBuilder এখন LiveIndexController কে পয়েন্ট করবে
    return VisibleGetBuilder<LiveIndexController>(
      id: "index_list",
      builder: (indexCon) {
        if (indexCon.indexList.isEmpty) {
          return const IndexValueLoader();
        }

        final newArr = indexCon.newArr;

        return GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          childAspectRatio: 2.1,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          children: [
            _CustomCardWidget(
              color: ColorConstants.yaleBlue,
              title: "TRADE",
              subtitle: NumberFormatter.bdFormat(newArr?.tds ?? 0),
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Trade'),
            ),
            _CustomCardWidget(
              color: ColorConstants.lightBlue,
              title: "VOLUME",
              subtitle: NumberFormatter.croreFormat(newArr?.v ?? 0.0),
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Volume'),
            ),
            _CustomCardWidget(
              color: ColorConstants.goldenYellow,
              title: "VALUE",
              subtitle: NumberFormatter.croreFormat(newArr?.vl ?? 0.0),
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Value'),
            ),
            _CustomCardWidget(
              color: ColorConstants.forestGreen,
              title: "ADVANCED",
              subtitle: "${newArr?.u ?? 0}",
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Gainer'),
            ),
            _CustomCardWidget(
              color: ColorConstants.coralRed,
              title: "DECLINE",
              subtitle: "${newArr?.d ?? 0}",
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Loser'),
            ),
            _CustomCardWidget(
              color: ColorConstants.brightBlue,
              title: "UNCHANGED",
              subtitle: "${newArr?.uc ?? 0}",
              onClick: () => Get.toNamed(Routes.TOP_SHARE, arguments: 'Unchanged'),
            ),
          ],
        );
      },
    );
  }
}

class _CustomCardWidget extends StatelessWidget {
  const _CustomCardWidget({
    required this.color,
    required this.title,
    required this.subtitle,
    this.onClick,
  }) : active = null;

  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onClick;
  final bool? active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          children: [
            Text(title, style: Get.textTheme.labelLarge?.copyWith(color: ColorConstants.white)),
            Text(subtitle, style: Get.textTheme.labelLarge?.copyWith(color: ColorConstants.white)),
          ],
        ),
      ),
    );
  }
}
