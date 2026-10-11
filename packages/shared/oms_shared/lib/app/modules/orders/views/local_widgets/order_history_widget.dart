import 'package:oms_shared/app/modules/orders/views/order_details_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../../../core/values/colors.dart';
import '../../../../core/values/constants.dart';
import '../../../../core/values/space.dart';
import '../../../../data/enums/app_enum.dart';
import '../../../../data/models/response/user_order.dart';
import '../../../../global_widgets/custom_container.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../../global_widgets/confirm_dialog.dart' hide HexColor;
import 'order_form_dialog.dart';
import '../../../../global_widgets/loaders/order_list_loader.dart';

// ----------------------------------------------------------------------
//  ৩. Main Order History Widget
// ----------------------------------------------------------------------
class OrderHistoryWidget extends StatelessWidget {
  final bool isActionViewExpanded;
  final VoidCallback onToggleView;

  const OrderHistoryWidget({super.key, required this.isActionViewExpanded, required this.onToggleView});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      id: AppConstants.orderList,
      builder: (homeCotByOrder) {
        if (homeCotByOrder.isLoadingUserOrder) {
          return const OrderListLoader();
        }

        List<UserOrder?> orders = List.from(homeCotByOrder.userOrder.data ?? []);

        if (homeCotByOrder.selectedInstrument != 'All') {
          orders = orders.where((o) => o?.name == homeCotByOrder.selectedInstrument).toList();
        }

        bool isAsc = homeCotByOrder.isAscendingOrderList;
        orders.sort((a, b) {
          String timeA = a?.transactTime ?? '';
          String timeB = b?.transactTime ?? '';
          return isAsc ? timeA.compareTo(timeB) : timeB.compareTo(timeA);
        });

        return Column(
          children: [
            //  Sorting & View Toggle Header
            Padding(
              padding: const .symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Orders: ${orders.length}',
                    style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      // 👈 View Toggle Button
                      InkWell(
                        onTap: onToggleView,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const .symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: hexToColor("#DFDFDF")),
                            borderRadius: BorderRadius.circular(6),
                            color: isActionViewExpanded ? context.buttonColor.withOpacity(0.1) : Colors.transparent,
                          ),
                          child: Icon(
                            isActionViewExpanded ? Icons.splitscreen : Icons.menu_open,
                            size: 16,
                            color: isActionViewExpanded ? context.buttonColor : context.textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 👈 Sort Button
                      InkWell(
                        onTap: () {
                          homeCotByOrder.isAscendingOrderList = !(homeCotByOrder.isAscendingOrderList);
                          homeCotByOrder.update([AppConstants.orderList]);
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const .symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: hexToColor("#DFDFDF")),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.sort, size: 14, color: context.textColor),
                              const SizedBox(width: 4),
                              Text(
                                isAsc ? 'Asc' : 'Des',
                                style: Get.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //  Main ListView
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text('No orders found'))
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        UserOrder? order = orders[index];
                        if (order == null) return const SizedBox();

                        double total = (order.sentQty ?? 0) * (order.limit ?? 0).toDouble();
                        String totalFormatted = total.toStringAsFixed(1);

                        //  Render Original OR New Row based on state
                        if (!isActionViewExpanded) {
                          return _buildOriginalRow(context, order, homeCotByOrder, totalFormatted);
                        } else {
                          return _buildNewRow(context, order, homeCotByOrder, totalFormatted);
                        }
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  //  Original Row Widget (Flex 4, 2, 4 with 3-Dots)
  // ----------------------------------------------------------------------
  Widget _buildOriginalRow(
    BuildContext context,
    UserOrder order,
    HomeController homeCotByOrder,
    String totalFormatted,
  ) {
    bool isExpired = order.status?.trim().toLowerCase() == 'expired';

    return CustomContainerWidget(
      backgroundColor: context.tapBg,
      margin: const .symmetric(vertical: 3, horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: .start,
        children: [
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: () => Get.to(() => OrderDetailsView(userOrder: order)),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    order.name ?? "",
                    maxLines: 1,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: context.textColor,
                    ),
                  ),
                  Text(
                    Helpers.convertTimestampToLocalTime(order.transactTime) ?? '',
                    style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, fontSize: 12),
                  ),
                  RichText(
                    text: TextSpan(
                      text: order.side ?? "",
                      style: Get.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: order.side == "BUY" ? ColorConstants.success : ColorConstants.error,
                      ),
                      children: [
                        TextSpan(
                          text: order.ordType == null ? "" : ' (${order.ordType ?? ""})',
                          style: Get.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: context.textColor,
                          ),
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
            flex: 2,
            child: Column(
              crossAxisAlignment: .center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${order.sentQty ?? ""}',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: context.buttonColor,
                  ),
                ),
                Text(
                  '${order.limit ?? ""}',
                  style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                Text(
                  '${order.remainingQty ?? ""}',
                  style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ],
            ),
          ),
          AppSpace.spaceW6,
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: .end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const .symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: ColorConstants.error, borderRadius: BorderRadius.circular(7)),
                  child: Text(
                    order.status ?? "",
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: ColorConstants.white,
                    ),
                  ),
                ),
                AppSpace.spaceH8,
                Container(
                  padding: const .symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: ColorConstants.success, borderRadius: BorderRadius.circular(7)),
                  child: Text(
                    order.orderStatus ?? "",
                    maxLines: 2,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: ColorConstants.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpace.spaceW8,
          isExpired
              ? const SizedBox(width: 28)
              : SizedBox(
                  width: 28,
                  child: _Original3DotMenu(order: order, homeCotByOrder: homeCotByOrder),
                ),
          AppSpace.spaceW4,
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  //  New Row Widget (Flex 4, 3, 3 with Status Check & Action Wrap)[cite: 9]
  // ----------------------------------------------------------------------
  Widget _buildNewRow(BuildContext context, UserOrder order, HomeController homeCotByOrder, String totalFormatted) {
    bool isExpired = order.status?.trim().toLowerCase() == 'expired';

    return Container(
      margin: const .symmetric(vertical: 4, horizontal: 4),
      padding: const .symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: order.side == "BUY" ? Colors.greenAccent.withAlpha(10) : Colors.redAccent.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderSideColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          InkWell(
            onTap: () => Get.to(() => OrderDetailsView(userOrder: order)),
            child: Row(
              crossAxisAlignment: .center,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        order.name ?? "",
                        maxLines: 1,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: context.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Helpers.convertTimestampToLocalTime(order.transactTime) ?? '',
                        style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          text: order.side ?? "",
                          style: Get.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: order.side == "BUY" ? ColorConstants.success : ColorConstants.error,
                          ),
                          children: [
                            TextSpan(
                              text: order.ordType == null ? "" : ' (${order.ordType ?? ""})',
                              style: Get.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: context.textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpace.spaceW6,

                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: .center,
                    children: [
                      Text(
                        '${order.sentQty ?? ""}', //exequite qty = cumQty, price =limit,terget qty = sentQty,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: context.buttonColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.limit ?? ""}',
                        style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${order.remainingQty}",
                        style: Get.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: context.textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpace.spaceW6,

                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: .end,
                    children: [
                      Text(
                        order.status ?? "",
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: ColorConstants.error, // 👈 Old UI Error/Status Color
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.orderStatus ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.right,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: ColorConstants.success, // 👈 Old UI Success/Status Color
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.execution ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.right,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: order.side == "BUY" ? ColorConstants.success : ColorConstants.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (!isExpired) ...[
            const Padding(padding: .symmetric(vertical: 8), child: Divider(height: 1, thickness: 0.6)),
            SizedBox(
              width: double.infinity,
              child: _OrderActionWrapWidget(order: order, homeCotByOrder: homeCotByOrder),
            ),
          ],
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
//  3-Dot Menu Logic
// ----------------------------------------------------------------------
class _Original3DotMenu extends StatelessWidget {
  final UserOrder order;
  final HomeController homeCotByOrder;

  const _Original3DotMenu({required this.order, required this.homeCotByOrder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        final position = details.globalPosition;
        var status = order.status ?? '';
        var orderStatus = order.orderStatus ?? '';
        final bool isDuplicateDisabled =
            status == 'Expired' ||
            orderStatus == 'REJECTED' ||
            orderStatus == 'REPLACED' ||
            (orderStatus == 'Z' && status == 'Working') ||
            status == 'Terminated';

        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(position.dx + 20, position.dy + 20, 0, 0),
          shadowColor: Colors.red,
          color: ColorConstants.primaryColor,
          items: [
            if (!status.contains('Terminated') && !status.contains('Done')) ...[
              _buildMenuItem(0, Icons.edit, 'Modify', () {
                if (order.side == 'BUY' || order.side == 'SELL') {
                  Get.back();
                  showOrderFormDialog(order);
                }
              }),
              if (!orderStatus.contains('CANCELED'))
                _buildMenuItem(2, Icons.cancel, 'Cancel Order', () {
                  Get.back();
                  Helpers.showCustomDialog(
                    context,
                    child: ConfirmDialog(
                      title: 'Cancel Order',
                      message: 'Are you sure you want to cancel this order?',
                      onConfirm: () {
                        homeCotByOrder.orderCancelSubmitted('ORDER_CANCEL_REQUEST', order);
                      },
                    ),
                  );
                }),
            ],
            if (!isDuplicateDisabled) ...[
              _buildMenuItem(1, Icons.copy, 'Duplicate', () {
                Helpers.showCustomDialog(
                  context,
                  child: ConfirmDialog(
                    title: 'Duplicate Confirmation',
                    message: 'Are you sure?',
                    onConfirm: () {
                      Get.back();
                      homeCotByOrder.orderDuplicateSubmitted(ActionsType.ORDER, order: order);
                    },
                  ),
                );
              }),
            ],
            _buildMenuItem(5, Icons.list_alt, 'Order Status', () {
              Get.back();
              Helpers.showCustomDialog(
                context,
                child: ConfirmDialog(
                  title: 'Order Status',
                  message:
                      'Are you sure you want to proceed with this order?\n\n'
                      'Total Qty : ${order.sentQty ?? 0}\n'
                      'Executed Qty : ${order.cumQty ?? 0}\n'
                      'Remaining Qty : ${order.leavesQty ?? 0}\n'
                      'Price : ৳${order.limit ?? 0.0}',
                  onConfirm: () {
                    Get.back();
                    homeCotByOrder.orderStatusChangeConfirmSubmitted(ActionsType.ORDER_STATUS, order);
                  },
                ),
              );
            }),
            _buildMenuItem(6, Icons.info_outline, 'Order Details', () {
              Get.back();
              Get.to(() => OrderDetailsView(userOrder: order));
            }),
            _buildMenuItem(7, Icons.close, 'Close', () {}),
          ],
        );
      },
      child: Icon(Icons.more_vert, color: context.textColor, size: 28),
    );
  }

  PopupMenuItem<int> _buildMenuItem(int value, IconData icon, String text, VoidCallback onTap) {
    return PopupMenuItem<int>(
      value: value,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Text(text, style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
//  Extended Wrap Actions
// ----------------------------------------------------------------------
class _OrderActionWrapWidget extends StatelessWidget {
  final UserOrder order;
  final HomeController homeCotByOrder;

  const _OrderActionWrapWidget({required this.order, required this.homeCotByOrder});

  @override
  Widget build(BuildContext context) {
    var status = order.status ?? "";
    var orderStatus = order.orderStatus ?? "";

    final bool isDuplicateDisabled =
        status == 'Expired' ||
        orderStatus == 'REJECTED' ||
        orderStatus == 'REPLACED' ||
        (orderStatus == 'Z' && status == 'Working') ||
        status == 'Terminated';

    bool canModify = !status.contains('Terminated') && !status.contains('Done');
    bool canCancel = canModify && !orderStatus.contains('CANCELED');

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.end,
      children: [
        if (canModify)
          _ActionChip(
            icon: Icons.edit_rounded,
            label: 'Modify',
            color: Colors.blueAccent,
            onTap: () {
              if (order.side == 'BUY' || order.side == 'SELL') {
                showOrderFormDialog(order);
              }
            },
          ),

        if (canCancel)
          _ActionChip(
            icon: Icons.cancel_outlined,
            label: 'Cancel',
            color: Colors.redAccent,
            onTap: () {
              Helpers.showCustomDialog(
                context,
                child: ConfirmDialog(
                  title: 'Cancel Order',
                  message: 'Are you sure you want to cancel this order?',
                  onConfirm: () => homeCotByOrder.orderCancelSubmitted('ORDER_CANCEL_REQUEST', order),
                ),
              );
            },
          ),

        if (!isDuplicateDisabled)
          _ActionChip(
            icon: Icons.copy_rounded,
            label: 'Duplicate',
            color: Colors.orangeAccent,
            onTap: () {
              Helpers.showCustomDialog(
                context,
                child: ConfirmDialog(
                  title: 'Duplicate Confirmation',
                  message: 'Are you sure you want to duplicate?',
                  onConfirm: () {
                    Get.back();
                    homeCotByOrder.orderDuplicateSubmitted(ActionsType.ORDER, order: order);
                  },
                ),
              );
            },
          ),

        _ActionChip(
          icon: Icons.list_alt_rounded,
          label: 'Status',
          color: Colors.teal,
          onTap: () {
            Helpers.showCustomDialog(
              context,
              child: ConfirmDialog(
                title: 'Order Status',
                message:
                    'Are you sure you want to proceed with this order?\n\n'
                    'Total Qty : ${order.sentQty ?? 0}\n'
                    'Executed Qty : ${order.cumQty ?? 0}\n'
                    'Remaining Qty : ${order.leavesQty ?? 0}\n'
                    'Price : ৳${order.limit ?? 0.0}',
                onConfirm: () {
                  Get.back();
                  homeCotByOrder.orderStatusChangeConfirmSubmitted(ActionsType.ORDER_STATUS, order);
                },
              ),
            );
          },
        ),

        _ActionChip(
          icon: Icons.info_outline_rounded,
          label: 'Details',
          color: context.textColor.withOpacity(0.6),
          onTap: () {
            Get.to(() => OrderDetailsView(userOrder: order));
          },
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        padding: const .symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
