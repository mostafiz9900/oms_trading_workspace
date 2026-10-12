import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/utils/extensions/string_extensions.dart';
import '../../../../core/utils/helpers/hex_color.dart';
import '../../../../core/values/constants.dart';
import '../../../../core/values/dimens.dart';
import '../../../../core/values/space.dart';
import '../../../../data/enums/app_enum.dart';
import '../../../../data/models/response/user_order.dart';
import '../../../../global_widgets/custom_dropdown.dart';
import '../../../home/controllers/home_controller.dart';

// ----------------------------------------------------------------------
//  Restored Function: showOrderFormDialog
// ----------------------------------------------------------------------
void showOrderFormDialog(UserOrder order) {
  bool isBuy = order.side?.toUpperCase() == 'BUY';
  Color headerBgColor = isBuy ? HexColor("#22C665") : HexColor("#F70042");
  Color headerTextColor = Colors.white;

  Get.dialog(
    GetBuilder<HomeController>(
      id: AppConstants.orderList,
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final homeCon = Get.find<HomeController>();
          homeCon.selectOrderType = order.ordType?.toCapitalize();
          homeCon.disclosedQtyTextEditField.text = "${order.displayQty ?? ''}";
          homeCon.selectValidity = order.timeInForce?.toCapitalize();
          homeCon.qtyTextEditField.text = "${order.leavesQty ?? ''}";
          homeCon.minQtyTextEditField.text = "${order.minQty ?? ''}";
          homeCon.tradPriceTextEditField.text = "${order.limit ?? ''}";
          homeCon.update([AppConstants.orderList]);
        });
      },
      builder: (homeCon) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Builder(
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      alignment: Alignment.center,
                      height: AppDimens.space51,
                      decoration: BoxDecoration(
                        color: headerBgColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        "${order.side ?? 'ORDER'} MODIFY",
                        style: Get.textTheme.titleMedium?.copyWith(
                          color: headerTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: AppDimens.space17,
                        ),
                      ),
                    ),
                    AppSpace.spaceH10,

                    // Order Type & Type Dropdowns
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: OrderTypeDropdownListWidget(
                              valueChanged: (String? value) {
                                if (value != null) homeCon.changeOrderTypeOrderList(value);
                              },
                              selectedValueNotifier: ValueNotifier<String?>(homeCon.selectOrderType),
                            ),
                          ),
                          AppSpace.spaceW10,
                          Flexible(
                            child: Container(
                              height: AppDimens.space50,
                              decoration: BoxDecoration(color: context.tapBg, borderRadius: BorderRadius.circular(6)),
                              child: TypeDropdownListWidget(
                                valueChanged: (String? value) {
                                  if (value != null) homeCon.changeTypeOrderList(value);
                                },
                                value: homeCon.selectType,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpace.spaceH10,

                    // Disclosed Qty & Validity
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimens.space15),
                              alignment: Alignment.centerLeft,
                              height: AppDimens.space50,
                              decoration: BoxDecoration(color: context.tapBg, borderRadius: BorderRadius.circular(6)),
                              child: TextFormField(
                                controller: homeCon.disclosedQtyTextEditField,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: TextStyle(color: context.textColor),
                                decoration: InputDecoration(
                                  hintText: 'Disclosed Qty.',
                                  hintStyle: TextStyle(fontSize: 14.0, color: context.textColor.withAlpha(128)),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          AppSpace.spaceW10,
                          Expanded(
                            child: Container(
                              height: AppDimens.space50,
                              decoration: BoxDecoration(color: context.tapBg, borderRadius: BorderRadius.circular(6)),
                              child: ValidityDropdownListWidget(
                                valueChanged: (String? value) {
                                  if (value != null) homeCon.changeValidityOrderList(value);
                                },
                                value: homeCon.selectValidity,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpace.spaceH10,

                    // Qty & Min Qty
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimens.space15),
                              alignment: Alignment.centerLeft,
                              height: AppDimens.space50,
                              decoration: BoxDecoration(color: context.tapBg, borderRadius: BorderRadius.circular(6)),
                              child: TextFormField(
                                controller: homeCon.qtyTextEditField,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: TextStyle(color: context.textColor),
                                decoration: InputDecoration(
                                  hintText: 'Qty.',
                                  hintStyle: TextStyle(fontSize: 14.0, color: context.textColor.withAlpha(128)),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                          AppSpace.spaceW10,
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimens.space15),
                              alignment: Alignment.centerLeft,
                              height: AppDimens.space50,
                              decoration: BoxDecoration(color: context.tapBg, borderRadius: BorderRadius.circular(6)),
                              child: TextFormField(
                                controller: homeCon.minQtyTextEditField,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: TextStyle(color: context.textColor),
                                decoration: InputDecoration(
                                  hintText: 'Min Qty.',
                                  hintStyle: TextStyle(fontSize: 14.0, color: context.textColor.withAlpha(128)),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpace.spaceH10,

                    //  Trade Price with +/- 0.10 Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              height: AppDimens.space50,
                              decoration: BoxDecoration(
                                color: context.tapBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: context.textColor.withAlpha(26)),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      double currentVal = double.tryParse(homeCon.tradPriceTextEditField.text) ?? 0.0;
                                      if (currentVal > 0) {
                                        //  Math Fix: Floating point precision issue এড়াতে
                                        double newVal = double.parse((currentVal - 0.10).toStringAsFixed(2));
                                        if (newVal < 0) newVal = 0;

                                        String newText = newVal.toStringAsFixed(2);
                                        //  Cursor Fix: টেক্সট আপডেট হওয়ার পর কার্সারটি একদম শেষে রাখার লজিক
                                        homeCon.tradPriceTextEditField.value = TextEditingValue(
                                          text: newText,
                                          selection: TextSelection.collapsed(offset: newText.length),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(Icons.remove, color: context.textColor),
                                    ),
                                  ),

                                  // 💵 Price Input Field
                                  Expanded(
                                    child: TextFormField(
                                      controller: homeCon.tradPriceTextEditField,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        contentPadding: EdgeInsets.only(bottom: 11, top: 11),
                                        hintText: "0.00",
                                      ),
                                      style: Get.textTheme.titleLarge?.copyWith(
                                        fontSize: AppDimens.space19,
                                        fontWeight: FontWeight.w600,
                                        color: context.textColor,
                                      ),
                                    ),
                                  ),

                                  InkWell(
                                    onTap: () {
                                      double currentVal = double.tryParse(homeCon.tradPriceTextEditField.text) ?? 0.0;
                                      //  Math Fix
                                      double newVal = double.parse((currentVal + 0.10).toStringAsFixed(2));

                                      String newText = newVal.toStringAsFixed(2);
                                      //  Cursor Fix
                                      homeCon.tradPriceTextEditField.value = TextEditingValue(
                                        text: newText,
                                        selection: TextSelection.collapsed(offset: newText.length),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(Icons.add, color: context.textColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpace.spaceH10,

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Get.back();
                              homeCon.selectOrderType = null;
                              homeCon.disclosedQtyTextEditField.clear();
                              homeCon.selectValidity = null;
                              homeCon.qtyTextEditField.clear();
                              homeCon.minQtyTextEditField.clear();
                              homeCon.tradPriceTextEditField.clear();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: context.textColor.withAlpha(77)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text("Cancel", style: TextStyle(color: context.textColor)),
                          ),
                          AppSpace.spaceW10,
                          ElevatedButton(
                            onPressed: () {
                              var orderConfirm = isBuy ? SideType2.BUY : SideType2.SELL;
                              Get.back();
                              homeCon.orderConfirmSubmittedReplaceOrder(
                                orderConfirm,
                                ActionsType.REPLACE_ORDER,
                                order: order,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: headerBgColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                            child: const Text("Submit", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    ),
    barrierDismissible: false,
  );
}
