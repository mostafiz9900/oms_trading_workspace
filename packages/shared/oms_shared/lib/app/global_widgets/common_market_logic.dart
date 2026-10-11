import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_pkg.dart';

import '../data/models/request/add_fav_item_request.dart' show AddFavItemRequest;

class SharedMarketLogic {
  /// 🚀 Common Text Highlighter
  static List<TextSpan> buildHighlightText(
    String text,
    String query,
    BuildContext context, {
    double fontSize = 14,
  }) {
    // 🚀 ১. ডিফল্ট টেক্সটের কালার
    final defaultStyle =
        Get.textTheme.titleMedium?.copyWith(
          color: context.textColor,
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
          letterSpacing: 0.5,
        ) ??
        const TextStyle();

    final highlightStyle = defaultStyle.copyWith(
      color: context.buttonColor,
      fontWeight: FontWeight.w900,
    );

    if (query.isEmpty) return [TextSpan(text: text, style: defaultStyle)];

    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    final int startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) return [TextSpan(text: text, style: defaultStyle)];

    return [
      TextSpan(text: text.substring(0, startIndex), style: defaultStyle),
      TextSpan(
        text: text.substring(startIndex, startIndex + query.length),
        style: highlightStyle,
      ),
      TextSpan(
        text: text.substring(startIndex + query.length),
        style: defaultStyle,
      ),
    ];
  }
}

class MarketDialogHelper {
  // 🚀 ১. Common Buy/Sell Dialog
  static void showBuySellDialog({
    required BuildContext context,
    required int orderBookId,
    required String shortName,
  }) {
    final homeCon = Get.find<HomeController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Action"),
        content: const Text("Do you want to Buy or Sell?"),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C665),
            ),
            onPressed: () {
              homeCon.goBottomNabBarPage(5, orderBookId);
              homeCon.setBuySellActive(SideType2.BUY);
              homeCon.loadComanyDividentEPS(shortName);
              Get.back();
            },
            child: Text(
              "Buy",
              style: Get.textTheme.bodyLarge!.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF70042),
            ),
            onPressed: () {
              homeCon.goBottomNabBarPage(5, orderBookId);
              homeCon.setBuySellActive(SideType2.SELL);
              homeCon.loadComanyDividentEPS(shortName);
              Get.back();
            },
            child: Text(
              "Sell",
              style: Get.textTheme.bodyLarge!.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 ২. Common Favourite Bottom Sheet
  static void showFavouriteBottomSheet(BuildContext ctx, MarketModel model) {
    final homeCon = Get.find<HomeController>();
    homeCon.changeShortName(model.shortName!);

    Helpers.customShowDialog(
      ctx,
      barrierDismissible: false,
      children: [
        Flexible(
          child: GetBuilder<HomeController>(
            builder: (homeCont) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: homeCont.favCatList.length,
                itemBuilder: (context, index) {
                  final favCat = homeCont.favCatList.elementAt(index);
                  final isSelected = homeCont.selectFavCatId == favCat.id;

                  return InkWell(
                    key: ValueKey(favCat),
                    onTap: () => homeCont.changeFavCatId(favCat.id!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.evenColor
                            : context.oddColor,
                      ),
                      child: Text(
                        '${favCat.name}',
                        style: Get.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          color: isSelected
                              ? ColorConstants.secondaryColorLight
                              : context.textColor,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        GetBuilder<HomeController>(
          builder: (homeLogic) {
            return Padding(
              padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: homeLogic.isAddFavCat
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(80, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22.0),
                              ),
                            ),
                            child: const Text(
                              "No",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (homeLogic.selectFavCatId == 0) {
                                Helpers.snackbarForErorr2(
                                  bodyText: 'Please select name',
                                );
                              } else {
                                var requestData = AddFavItemRequest(
                                  tableId: homeLogic.selectFavCatId,
                                  ticker: '${model.ticker}',
                                  group: '${model.group}',
                                  oderBook: model.orderBook!,
                                );
                                homeLogic.addMarketDataToFav(requestData);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstants.greenColor,
                              minimumSize: const Size(80, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22.0),
                              ),
                            ),
                            child: const Text(
                              "Save",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
