import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/utils/helpers/hex_color.dart';
import '../../../../core/values/colors.dart';
import '../../../../core/values/dimens.dart';
import '../../../../core/values/space.dart';
import '../../../../data/enums/app_enum.dart';
import '../../../../data/models/order_confirm_holder.dart';
import '../../../../global_widgets/custom_app_bar.dart';
import '../../../../global_widgets/custom_button.dart';
import '../../../home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TradeConfirmOrders extends StatelessWidget {
  const TradeConfirmOrders({super.key, required this.orderConfirm});
  final OrderConfirmHolder orderConfirm;

  @override
  Widget build(BuildContext context) {
    // 🚀 গ্লোবাল GetBuilder রিমুভ করে দেওয়া হয়েছে! পেজটি এখন 100% স্ট্যাটিক ও ফাস্ট রেন্ডার হবে।
    return Scaffold(
      appBar: CustomAppBar(
        backButtonOnClick: () {
          Get.back();
        },
        isBackButtonIcon: true,
        searchButtonOnClick: () {},
        right: const SizedBox.shrink(),
      ),
      body: Padding(
        padding: AppSpace.pagePadding,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.space25),
                height: AppDimens.space54,
                decoration: BoxDecoration(color: ColorConstants.blueColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Confirm Order",
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: ColorConstants.white,
                        fontSize: AppDimens.space16,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpace.spaceH10,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: orderConfirm.marketData?.shortName ?? '',
                              style: Get.textTheme.bodySmall?.copyWith(
                                fontSize: AppDimens.space17,
                                fontWeight: FontWeight.w700,
                                color: ColorConstants.success,
                              ),
                              children: [
                                TextSpan(
                                  text: ' ${orderConfirm.marketData?.marketType ?? ""}',
                                  style: Get.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppDimens.space12,
                                    color: context.textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            orderConfirm.marketData?.fullName ?? "",
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: context.textColor,
                              fontSize: AppDimens.space11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpace.spaceW16,
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Container(
                      height: 32,
                      width: AppDimens.space70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorConstants.blueColor,
                        borderRadius: BorderRadius.circular(AppDimens.space5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space5),
                      child: Text(
                        '${orderConfirm.sideType?.name}',
                        textAlign: TextAlign.center,
                        style: Get.textTheme.bodySmall?.copyWith(
                          fontSize: AppDimens.space17,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpace.spaceH10,
              Divider(height: 0.5, color: context.dividerColor),
              AppSpace.spaceH10,
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.space15),
                decoration: BoxDecoration(
                  color: context.isDark ? HexColor('#17192B') : HexColor('#F7FAFF'),
                  borderRadius: const BorderRadius.all(Radius.circular(AppDimens.space10)),
                ),
                child: Column(
                  children: [
                    _TitleAndValueRowWidget(title: "Price", value: '${orderConfirm.price ?? 0.0}'),
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: "Quantity", value: "${orderConfirm.qty ?? 0}"),
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: "Disclosed Qty", value: "${orderConfirm.disclosedQty ?? 0}"),
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: "Order Type", value: orderConfirm.orderType ?? ""),
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(title: "Validity", value: orderConfirm.validity ?? ""),
                    AppSpace.spaceH10,
                    _TitleAndValueRowWidget(
                      title: "Estimated Amount",
                      value: ((orderConfirm.price ?? 0) * (double.tryParse(orderConfirm.qty ?? '0') ?? 0))
                          .toStringAsFixed(2),
                    ),
                    AppSpace.spaceH10,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomButton(
                              onPressed: () {
                                Get.back();
                              },
                              title: "Cancel",
                              backgroundColor: ColorConstants.redColor,
                              height: AppDimens.space54,
                            ),
                          ),
                          AppSpace.spaceW10,
                          Expanded(
                            // 🚀 MAGIC FIX: শুধুমাত্র সাবমিট বাটনটি GetBuilder দিয়ে মোড়ানো হয়েছে!
                            child: GetBuilder<HomeController>(
                              id: 'order_confirm_btn',
                              builder: (homeCon) {
                                return CustomButton(
                                  isLoading: homeCon.isOrderConfirmLoading,
                                  onPressed: () {
                                    homeCon.orderConfirmSubmitted(orderConfirm.sideType!, ActionsType.ORDER);
                                  },
                                  title: "Confirm Order",
                                  backgroundColor: ColorConstants.blueColor,
                                  height: AppDimens.space54,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleAndValueRowWidget extends StatelessWidget {
  const _TitleAndValueRowWidget({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppDimens.space5),
      decoration: BoxDecoration(
        color: context.isDark ? HexColor('#17192B') : HexColor("#F7FAFF"),
        border: Border(bottom: BorderSide(width: 1, color: ColorConstants.gray.alphaSafe(0.2))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.space15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Get.textTheme.titleSmall?.copyWith(color: context.textColor, fontSize: AppDimens.space14),
            ),
            Text(
              value,
              style: Get.textTheme.titleMedium?.copyWith(
                color: context.textColor,
                fontWeight: FontWeight.w700,
                fontSize: AppDimens.space18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
