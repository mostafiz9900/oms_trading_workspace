import '../../../../data/models/request/add_fav_item_request.dart' show AddFavItemRequest;


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app_pkg.dart';

// ==========================================
// 5. Global/Helper functions
// ==========================================
void favouriteBottomSheet(BuildContext ctx, MarketModel model) {
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
                return InkWell(
                  key: ValueKey(homeCont.favCatList.elementAt(index)),
                  onTap: () {
                    homeCont.changeFavCatId(
                      homeCont.favCatList.elementAt(index).id!,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          homeCont.selectFavCatId ==
                              homeCont.favCatList.elementAt(index).id
                          ? context.evenColor
                          : context.oddColor,
                    ),
                    child: Text(
                      '${homeCont.favCatList.elementAt(index).name}',
                      style: Get.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color:
                            homeCont.selectFavCatId ==
                                homeCont.favCatList.elementAt(index).id
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
      AppSpace.spaceH10,
      GetBuilder<HomeController>(
        builder: (homeCon) {
          return Container(
            padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
            child: homeCon.isAddFavCat
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(80, 40),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            textStyle: const TextStyle(fontSize: 15),
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
                      AppSpace.spaceW20,
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (homeCon.selectFavCatId == 0) {
                              Helpers.snackbarForErorr2(
                                bodyText: 'Please select name',
                              );
                            } else {
                              var requestData = AddFavItemRequest(
                                tableId: homeCon.selectFavCatId,
                                ticker: '${model.ticker}',
                                group: '${model.group}',
                                oderBook: model.orderBook!,
                              );
                              printLog('requestData ${requestData.toJson()}');
                              homeCon.addMarketDataToFav(requestData);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.greenColor,
                            minimumSize: const Size(80, 40),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            textStyle: const TextStyle(fontSize: 15),
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
      AppSpace.spaceH10,
    ],
  );
}
