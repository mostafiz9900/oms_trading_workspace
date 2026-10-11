import '../../../core/utils/extensions/app_context.dart';
import '../../../core/utils/helpers/log_helper.dart';
import '../../../core/values/assets.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/space.dart';
import '../../../data/models/response/market_model.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../../global_widgets/custom_button.dart';
import '../../../global_widgets/custom_edit_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_watch_list_controller.dart';

class SearchWatchListView extends GetView<SearchWatchListController> {
  const SearchWatchListView({super.key});

  @override
  Widget build(BuildContext context) {
    printLog(controller.hashCode);
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Watch List Search',
        isBackButtonIcon: true,
        backButtonOnClick: Get.back,
        right: SizedBox(),
      ),
      body: GetBuilder<SearchWatchListController>(
        builder: (searchCont) {
          return Column(
            children: [
              AppSpace.spaceH2,
              SizedBox(
                height: 30,
                child: searchCont.homeController.filtersSectorList == []
                    ? SizedBox()
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: searchCont.homeController.filtersSectorList.length,
                        padding: .only(left: 6),
                        itemBuilder: (context, sectionIndex) {
                          var model = searchCont.homeController.filtersSectorList.elementAt(sectionIndex);
                          return InkWell(
                            onTap: () {
                              controller.searchSector(model);
                              controller.textController.clear();
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              padding: .only(left: 5, right: 5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: model == searchCont.selectSector ? Colors.grey.shade300 : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$model   ',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: ColorConstants.textColorLight),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const .all(8.0),
                child: Row(
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: CustomEditTextFormField(
                          controller: controller.textController,
                          autoFocus: true,
                          cursorHeight: 15,
                          cursorWidth: 1.5,
                          prefixIcon: AssetsConstants.searchIconSvg,
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          onChanged: (String value) {},
                        ),
                      ),
                    ),
                    AppSpace.spaceW10,
                    SizedBox(
                      width: 80,
                      height: 43,
                      child: CustomButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          controller.textController.text.isNotEmpty ? controller.textController.clear() : null;
                        },
                        title: 'Cancel',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.filteredItems.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: controller.filteredItems.length,
                        itemBuilder: (_, index) {
                          return InkWell(
                            onTap: () {
                              controller.homeController.goBottomNabBarPage(
                                0,
                                controller.filteredItems.elementAt(index).orderBook!,
                              );
                              Get.back();
                            },
                            child: _WitchListItemWidget(model: controller.filteredItems.elementAt(index)),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WitchListItemWidget extends StatelessWidget {
  const _WitchListItemWidget({required this.model});
  final MarketModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(bottom: 10.0, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: model.shortName ?? "",
                        style: Get.textTheme.titleLarge?.copyWith(
                          color: context.textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: ' [${model.shareType}]',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                          fontFeatures: [const FontFeature.superscripts()],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Vol: ${model.volume ?? "0"}, Val: ${model.val ?? "0"}, Trd: ${model.trades ?? "0"}',
                  style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .start,
              children: [
                Text(
                  "${model.last ?? "0.0"}",
                  style: Get.textTheme.bodyLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  model.marketType ?? "",
                  maxLines: 2,
                  style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, fontSize: 10),
                ),
              ],
            ),
          ),
          AppSpace.spaceW6,
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: .center,
              mainAxisAlignment: .center,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const .symmetric(horizontal: 4),
                  height: 24,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: model.chg! > 0
                        ? ColorConstants.greenColor
                        : model.chg! < 0
                        ? ColorConstants.redColor
                        : ColorConstants.blueColor,
                  ),
                  child: Text(
                    '${model.chg}%',
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: ColorConstants.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${model.d}',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: model.d! > 0
                        ? ColorConstants.greenColor
                        : model.d! < 0
                        ? ColorConstants.redColor
                        : ColorConstants.blueColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
