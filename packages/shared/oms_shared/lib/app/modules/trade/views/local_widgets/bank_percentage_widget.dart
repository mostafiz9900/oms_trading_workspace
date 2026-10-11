import '/app/app_pkg.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


class BankPercentageWidget extends StatelessWidget {
  const BankPercentageWidget({super.key, required this.homeController});
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: InkWell(
              onTap: () async {
                final result = await SearchHelper.open();
                if (result != null &&
                    result.orderBook != null &&
                    result.shortName != null) {
                  homeController.goBottomNabBarPage(5, result.orderBook!);
                  homeController.tradPriceTextEditField.text =
                      (result.last?.toStringAsFixed(2) ?? '0.00');
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: homeController.marketData.fullName ?? "",
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.success,
                      ),
                      children: [
                        TextSpan(
                          text:
                              ' [${homeController.marketData.shareType ?? ""}]',
                          style: TextStyle(
                            fontSize: 10,
                            color: context.textColor,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' [${homeController.marketData.marketType ?? ""}]',
                          style: TextStyle(
                            fontSize: 10,
                            color: context.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text:
                          "Vol: ${NumberFormatter.croreFormat(homeController.marketData.val)},",
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: context.textColor,
                      ),
                      children: [
                        TextSpan(
                          text:
                              " Val: ${NumberFormatter.bdFormat(homeController.marketData.volume)},",
                        ),
                        TextSpan(
                          text: " Trd: ${homeController.marketData.trades} ",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpace.spaceW6,
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Open: ${homeController.marketData.open?.toStringAsFixed(1) ?? 0}",
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textColor,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "High:",
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textColor,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  ' ${homeController.marketData.high?.toStringAsFixed(1) ?? 0}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: ColorConstants.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Max:",
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textColor,
                          ),
                          children: [
                            // MAGIC FIX: 'dh?.toStringAsFixed(1)Ợ' এর টাইপো মুছে সেফ কোড বসানো হয়েছে
                            TextSpan(
                              text:
                                  ' ${homeController.marketData.dh?.toStringAsFixed(1) ?? 0}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: ColorConstants.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${(homeController.marketData.last ?? 0).toStringAsFixed(1)} :Close",
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textColor,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text:
                              "${homeController.marketData.low?.toStringAsFixed(1) ?? 0}",
                          style: TextStyle(
                            color: ColorConstants.error,
                            fontSize: 11,
                          ),
                          children: const [
                            TextSpan(
                              text: ' :Low',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text:
                              "${homeController.marketData.dl?.toStringAsFixed(1) ?? 0} ",
                          style: TextStyle(
                            color: ColorConstants.error,
                            fontSize: 11,
                          ),
                          children: const [
                            TextSpan(
                              text: ' :Min',
                              style: TextStyle(color: Colors.grey),
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
        ],
      ),
    );
  }
}
