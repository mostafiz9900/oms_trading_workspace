import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/utils/extensions/app_context.dart';
import '../../../core/values/assets.dart';
import '../../../core/values/colors.dart';
import '../../../core/values/constants.dart';
import '../../../core/values/space.dart';
import '../../home/controllers/home_controller.dart';
import 'local_widgets/title_and_sub_title_column_widget.dart';
import 'local_widgets/order_history_widget.dart';

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
        const _ClientCodeWidget(),
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
//  Client Code & Instrument Dropdown
// ----------------------------------------------------------------------
class _ClientCodeWidget extends ConsumerWidget {
  const _ClientCodeWidget();

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
