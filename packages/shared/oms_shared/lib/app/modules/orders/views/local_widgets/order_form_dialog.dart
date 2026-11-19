import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:getxify/getxify.dart';
import 'package:broker_config/broker_config.dart' show StockExchange;

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/utils/extensions/string_extensions.dart';
import '../../../../core/utils/helpers/hex_color.dart';
import '../../../../core/values/dimens.dart';
import '../../../../core/values/space.dart';
import '../../../../data/enums/app_enum.dart';
import '../../../../data/models/response/user_order.dart';
import '../../../../data/services/exchange_service.dart';
import '../../../../global_widgets/custom_dropdown.dart';
import '../../../home/controllers/home_controller.dart';

const _orderModifyDialogId = 'order_modify_dialog';

// ----------------------------------------------------------------------
//  Restored Function: showOrderFormDialog
// ----------------------------------------------------------------------
void showOrderFormDialog(
  UserOrder order, {
  ExchangeScope scope = ExchangeScope.quoteTrade,
}) {
  Get.dialog(
    _OrderModifyDialog(order: order, scope: scope),
    barrierDismissible: false,
  );
}

class _OrderModifyDialog extends StatefulWidget {
  const _OrderModifyDialog({
    required this.order,
    this.scope = ExchangeScope.quoteTrade,
  });

  final UserOrder order;
  final ExchangeScope scope;

  @override
  State<_OrderModifyDialog> createState() => _OrderModifyDialogState();
}

class _OrderModifyDialogState extends State<_OrderModifyDialog> {
  bool _hasQuantityError = false;
  late final TextEditingController _priceController;

  // The dialog's own fields: the Trade page (kept mounted under the dialog)
  // uses HomeController's fields, and two live inputs on one controller made
  // typing here also change the Trade page. Copied to HomeController on
  // Submit, which reads them.
  late final TextEditingController _disclosedQtyController;
  late final TextEditingController _qtyController;
  late final TextEditingController _minQtyController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: (widget.order.limit ?? 0).toString(),
    );
    _disclosedQtyController = TextEditingController(
      text: "${widget.order.displayQty ?? ''}",
    );
    _qtyController = TextEditingController(
      text: "${widget.order.leavesQty ?? ''}",
    );
    _minQtyController = TextEditingController(
      text: "${widget.order.minQty ?? ''}",
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _disclosedQtyController.dispose();
    _qtyController.dispose();
    _minQtyController.dispose();
    super.dispose();
  }

  String? get _quantityErrorMessage {
    if (ExchangeService.currentFor(widget.scope) != StockExchange.cse) {
      return null;
    }
    final disclosedQty = int.tryParse(_disclosedQtyController.text) ?? 0;
    if (disclosedQty <= 0) return null;

    final quantity = int.tryParse(_qtyController.text);
    if (quantity == null || quantity < disclosedQty) {
      return 'Qty. cannot be less than Disclosed Qty. ($disclosedQty)';
    }
    return null;
  }

  void _clearQuantityError() {
    if (_hasQuantityError) setState(() => _hasQuantityError = false);
  }

  void _showQuantityError(String message) {
    setState(() => _hasQuantityError = true);
    Get.snackbar(
      'Invalid Quantity',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isBuy = order.side?.toUpperCase() == 'BUY';
    final headerBgColor = isBuy ? HexColor("#22C665") : HexColor("#F70042");
    const headerTextColor = Colors.white;

    return GetBuilder<HomeController>(
      // Keep dialog form updates scoped to the overlay. Rebuilding the order
      // list underneath an open dialog can detach its sliver/render children.
      id: _orderModifyDialogId,
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final homeCon = Get.find<HomeController>();
          homeCon.selectOrderType = order.ordType?.toCapitalize();
          homeCon.selectValidity = order.timeInForce?.toCapitalize();
          homeCon.update([_orderModifyDialogId]);
        });
      },
      builder: (homeCon) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                        style: Get.context!.textTheme.titleMedium?.copyWith(
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
                                if (value != null) {
                                  homeCon.selectOrderType = value;
                                  homeCon.update([_orderModifyDialogId]);
                                }
                              },
                              selectedValueNotifier: ValueNotifier<String?>(
                                homeCon.selectOrderType,
                              ),
                            ),
                          ),
                          AppSpace.spaceW10,
                          Flexible(
                            child: Container(
                              height: AppDimens.space50,
                              decoration: BoxDecoration(
                                color: context.tapBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TypeDropdownListWidget(
                                valueChanged: (String? value) {
                                  if (value != null) {
                                    homeCon.selectType = value;
                                    homeCon.update([_orderModifyDialogId]);
                                  }
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.space15,
                              ),
                              alignment: Alignment.centerLeft,
                              height: AppDimens.space50,
                              decoration: BoxDecoration(
                                color: context.tapBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TextFormField(
                                controller: _disclosedQtyController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _clearQuantityError(),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(color: context.textColor),
                                decoration: InputDecoration(
                                  hintText: 'Disclosed Qty.',
                                  hintStyle: TextStyle(
                                    fontSize: 14.0,
                                    color: context.textColor.withAlpha(128),
                                  ),
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
                              decoration: BoxDecoration(
                                color: context.tapBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ValidityDropdownListWidget(
                                valueChanged: (String? value) {
                                  if (value != null) {
                                    homeCon.selectValidity = value;
                                    homeCon.update([_orderModifyDialogId]);
                                  }
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.space15,
                              ),
                              alignment: Alignment.centerLeft,
                              height: AppDimens.space50,
                              decoration: BoxDecoration(
                                color: context.tapBg,
                                borderRadius: BorderRadius.circular(6),
                                border: _hasQuantityError
                                    ? Border.all(color: Colors.red)
                                    : null,
                              ),
                              child: TextFormField(
                                controller: _qtyController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _clearQuantityError(),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(color: context.textColor),
                                decoration: InputDecoration(
                                  hintText: 'Qty.',
                                  hintStyle: TextStyle(
                                    fontSize: 14.0,
                                    color: context.textColor.withAlpha(128),
                                  ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.space15,
                              ),
                              alignment: Alignment.centerLeft,
                              height: AppDimens.space50,
                              decoration: BoxDecoration(
                                color: context.tapBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TextFormField(
                                controller: _minQtyController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(color: context.textColor),
                                decoration: InputDecoration(
                                  hintText: 'Min Qty.',
                                  hintStyle: TextStyle(
                                    fontSize: 14.0,
                                    color: context.textColor.withAlpha(128),
                                  ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              alignment: Alignment.center,
                              height: AppDimens.space50,
                              decoration: BoxDecoration(
                                color: context.tapBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: context.textColor.withAlpha(26),
                                ),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      double currentVal =
                                          double.tryParse(
                                            _priceController.text,
                                          ) ??
                                          0.0;
                                      if (currentVal > 0) {
                                        //  Math Fix: Floating point precision issue এড়াতে
                                        double newVal = double.parse(
                                          (currentVal - 0.10).toStringAsFixed(
                                            2,
                                          ),
                                        );
                                        if (newVal < 0) newVal = 0;

                                        String newText = newVal.toStringAsFixed(
                                          2,
                                        );
                                        //  Cursor Fix: টেক্সট আপডেট হওয়ার পর কার্সারটি একদম শেষে রাখার লজিক
                                        _priceController
                                            .value = TextEditingValue(
                                          text: newText,
                                          selection: TextSelection.collapsed(
                                            offset: newText.length,
                                          ),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.remove,
                                        color: context.textColor,
                                      ),
                                    ),
                                  ),

                                  // 💵 Price Input Field
                                  Expanded(
                                    child: TextFormField(
                                      controller: _priceController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d{0,2}'),
                                        ),
                                      ],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        contentPadding: EdgeInsets.only(
                                          bottom: 11,
                                          top: 11,
                                        ),
                                        hintText: "0.00",
                                      ),
                                      style: Get.context!.textTheme.titleLarge
                                          ?.copyWith(
                                            fontSize: AppDimens.space19,
                                            fontWeight: FontWeight.w600,
                                            color: context.textColor,
                                          ),
                                    ),
                                  ),

                                  InkWell(
                                    onTap: () {
                                      double currentVal =
                                          double.tryParse(
                                            _priceController.text,
                                          ) ??
                                          0.0;
                                      //  Math Fix
                                      double newVal = double.parse(
                                        (currentVal + 0.10).toStringAsFixed(2),
                                      );

                                      String newText = newVal.toStringAsFixed(
                                        2,
                                      );
                                      //  Cursor Fix
                                      _priceController.value = TextEditingValue(
                                        text: newText,
                                        selection: TextSelection.collapsed(
                                          offset: newText.length,
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.add,
                                        color: context.textColor,
                                      ),
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
                              side: BorderSide(
                                color: context.textColor.withAlpha(77),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: context.textColor),
                            ),
                          ),
                          AppSpace.spaceW10,
                          ElevatedButton(
                            onPressed: () {
                              final quantityError = _quantityErrorMessage;
                              if (quantityError != null) {
                                _showQuantityError(quantityError);
                                return;
                              }
                              _clearQuantityError();

                              var orderConfirm = isBuy
                                  ? SideType2.BUY
                                  : SideType2.SELL;
                              homeCon.disclosedQtyTextEditField.text =
                                  _disclosedQtyController.text;
                              homeCon.qtyTextEditField.text =
                                  _qtyController.text;
                              homeCon.minQtyTextEditField.text =
                                  _minQtyController.text;
                              homeCon.tradPriceTextEditField.text =
                                  _priceController.text;
                              Get.back();
                              homeCon.orderConfirmSubmittedReplaceOrder(
                                orderConfirm,
                                ActionsType.REPLACE_ORDER,
                                order: order,
                                scope: widget.scope,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: headerBgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(color: Colors.white),
                            ),
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
    );
  }
}
