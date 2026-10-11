import 'package:oms_shared/app/modules/home/views/order_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../app_pkg.dart';
import '../../../../global_widgets/confirm_dialog.dart' hide HexColor;
import 'index_value_loader.dart';
import 'title_and_sub_title_colum_widget.dart';

// ----------------------------------------------------------------------
//  Main Tab Widget (Stateful & KeepAlive to prevent view reset)
// ----------------------------------------------------------------------
class OrderListTabWidget extends StatefulWidget {
  const OrderListTabWidget({super.key});

  @override
  State<OrderListTabWidget> createState() => _OrderListTabWidgetState();
}

class _OrderListTabWidgetState extends State<OrderListTabWidget> with AutomaticKeepAliveClientMixin {
  bool isActionViewExpanded = true;

  @override
  bool get wantKeepAlive => true; // 👈 Prevents state reset when clicking Modify or switching tabs

  void toggleView() {
    setState(() {
      isActionViewExpanded = !isActionViewExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 👈 Required for KeepAlive
    return Column(
      children: [
        const _ClineCodeWidget(),
        AppSpace.spaceH8,

        //  Dynamic Title: Shows Original OR New Header based on state
        isActionViewExpanded ? const _NewItemTitleWidget() : const _OriginalItemTitleWidget(),

        Expanded(
          child: OrderHistoryWidget(isActionViewExpanded: isActionViewExpanded, onToggleView: toggleView),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
class _OriginalItemTitleWidget extends StatelessWidget {
  const _OriginalItemTitleWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: context.tapBg),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TitleAndSubTitleColumWidget(
            titleText: 'Symbol',
            subTitle: 'Time',
            subTitle2: 'Side',
            crossAxisAlignment: .start, // 👈 Start
          ),
          TitleAndSubTitleColumWidget(
            titleText: 'Quantity',
            subTitle: 'Price',
            subTitle2: 'Remaining Qty',
            crossAxisAlignment: .center, // 👈 Center
          ),
          TitleAndSubTitleColumWidget(
            titleText: 'Status',
            subTitle: 'Order Status',
            subTitle2: "",
            crossAxisAlignment: .end, // 👈 End
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
class _NewItemTitleWidget extends StatelessWidget {
  const _NewItemTitleWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: context.tapBg),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          const Expanded(
            flex: 4,
            child: TitleAndSubTitleColumWidget(
              titleText: 'Symbol',
              subTitle: 'Time',
              subTitle2: 'Side',
              crossAxisAlignment: .start, // 👈 Start
            ),
          ),
          AppSpace.spaceW6,
          const Expanded(
            flex: 3,
            child: TitleAndSubTitleColumWidget(
              titleText: 'Quantity',
              subTitle: 'Price',
              subTitle2: 'Remaining Qty',
              crossAxisAlignment: .center, // 👈 Center
            ),
          ),
          AppSpace.spaceW6,
          const Expanded(
            flex: 3,
            child: TitleAndSubTitleColumWidget(
              titleText: 'Status',
              subTitle: 'Order Status',
              subTitle2: "Execution%",
              crossAxisAlignment: .end, // 👈 End
            ),
          ),
        ],
      ),
    );
  }
}

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

// ----------------------------------------------------------------------
//  Client Code & Instrument Dropdown
// ----------------------------------------------------------------------
class _ClineCodeWidget extends ConsumerWidget {
  const _ClineCodeWidget();

  @override
  Widget build(BuildContext context, ref) {
    var userInfo = ref.watch(userInfoProvider);
    final HomeController homeCotByOrder = Get.find<HomeController>();

    BoxDecoration decoration = BoxDecoration(
      border: Border.all(width: 1, color: hexToColor("#DFDFDF")),
      borderRadius: BorderRadius.circular(4),
    );

    return Padding(
      padding: const .symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const .symmetric(vertical: 2, horizontal: 10),
              decoration: decoration,
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Client Code',
                    style: Get.textTheme.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    userInfo.userDetail?.investorCode ?? "",
                    style: Get.textTheme.titleLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          AppSpace.spaceW16,
          Expanded(
            child: GestureDetector(
              onTapDown: (TapDownDetails details) {
                final position = details.globalPosition;
                List<String> uniqueInstruments = ['All'];
                var allOrders = homeCotByOrder.userOrder.data ?? [];
                for (var order in allOrders) {
                  if (order.name != null && order.name!.isNotEmpty) {
                    if (!uniqueInstruments.contains(order.name)) {
                      uniqueInstruments.add(order.name!);
                    }
                  }
                }
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(position.dx, position.dy + 30, position.dx, 0),
                  color: ColorConstants.primaryColor,
                  items: uniqueInstruments.map((instrumentName) {
                    return PopupMenuItem<String>(
                      value: instrumentName,
                      child: Text(
                        instrumentName,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: homeCotByOrder.selectedInstrument == instrumentName
                              ? ColorConstants.success
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => homeCotByOrder.changeInstrument(instrumentName),
                    );
                  }).toList(),
                );
              },
              child: Container(
                padding: const .symmetric(vertical: 2, horizontal: 10),
                decoration: decoration,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Instrument',
                      style: Get.textTheme.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GetBuilder<HomeController>(
                            id: AppConstants.orderList,
                            builder: (controller) {
                              return Text(
                                controller.selectedInstrument,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Get.textTheme.titleLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                              );
                            },
                          ),
                        ),
                        SvgPicture.asset(
                          AssetsConstants.dropManuIconSvg,
                          colorFilter: ColorFilter.mode(
                            context.isDarkMode ? ColorConstants.white : hexToColor('#988181'),
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                                  hintStyle: TextStyle(fontSize: 14.0, color: context.textColor.withOpacity(0.5)),
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
                                  hintStyle: TextStyle(fontSize: 14.0, color: context.textColor.withOpacity(0.5)),
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
                                  hintStyle: TextStyle(fontSize: 14.0, color: context.textColor.withOpacity(0.5)),
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
                                border: Border.all(color: context.textColor.withOpacity(0.1)),
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
                              side: BorderSide(color: context.textColor.withOpacity(0.3)),
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
