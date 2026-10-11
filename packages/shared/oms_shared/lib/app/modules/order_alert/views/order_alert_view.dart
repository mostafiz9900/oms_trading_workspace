import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/values/constants.dart';
import '../../../global_widgets/custom_app_bar.dart';
import '../../../global_widgets/shared_market_components.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/models/response/order_alert_model.dart';
import '../../../global_widgets/loaders/order_list_loader.dart';

// আপনার কাস্টম উইজেটগুলো ইম্পোর্ট করে নিবেন

class OrderAlertView extends HookWidget {
  const OrderAlertView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dropdown এর জন্য অপশন লিস্ট
    final List<String> filterItems = [
      'All',
      'New',
      'Filled',
      'Partially Filled',
      'Replaced',
      'Pending',
      'Canceled',
      'Rejected',
    ];

    // Hook State: ড্রপডাউনের ভ্যালু ধরে রাখার জন্য
    final selectedFilter = useState<String>('All');

    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Alert Message',
        titleFontSize: 16,
        isBackButtonIcon: true,
        backButtonOnClick: () => Get.back(),
        right: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CommonMinimalDropdown(
              currentValue: selectedFilter.value,
              items: filterItems,
              onSelected: (String value) {
                selectedFilter.value = value; // Hook state update
              },
              widthDropdown: 150, // 'Partially Filled' টেক্সট ধরার জন্য একটু বড় রাখা হলো
            ),
          ),
        ),
      ),

      body: GetBuilder<HomeController>(
        id: AppConstants.orderAlertsUpdate, // আপনার নির্দিষ্ট ট্যাগ
        builder: (controller) {
          // হেল্পার: UI টেক্সট থেকে Backend Status Code এ কনভার্ট করার জন্য
          String getBackendStatus(String filterName) {
            switch (filterName) {
              case 'New':
                return 'NEW';
              case 'Filled':
                return 'FILLED';
              case 'Partially Filled':
                return 'PARTIALLY_FILLED';
              case 'Replaced':
                return 'REPLACED';
              case 'Pending':
                return 'Z';
              case 'Canceled':
                return 'CANCELED';
              case 'Rejected':
                return 'REJECTED';
              default:
                return ''; // 'All' এর ক্ষেত্রে ফাঁকা থাকবে
            }
          }

          // ফিল্টার লজিক অ্যাপ্লাই করা হচ্ছে
          List<OrderAlertModel> filteredAlerts = controller.orderAlertsList;
          final backendStatus = getBackendStatus(selectedFilter.value);

          if (backendStatus.isNotEmpty) {
            filteredAlerts = filteredAlerts.where((alert) {
              return alert.execType?.toUpperCase() == backendStatus;
            }).toList();
          }

          // ডেটা না থাকলে বা লোডিং অবস্থায় আপনার কাস্টম Loader দেখাবে
          if (controller.orderAlertsList.isEmpty) {
            return const OrderListLoader();
          }

          // ফিল্টার করার পর যদি কোনো ডেটা না থাকে
          if (filteredAlerts.isEmpty) {
            return const Center(
              child: Text(
                "No alerts found for this status",
                style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            );
          }

          return Column(
            children: [
              Container(
                color: const Color(0xFFE8F5E9), // Light Green Header
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text("Investor Timeline", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Exec Type",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              // List Data
              Expanded(
                child: ListView.separated(
                  itemCount: filteredAlerts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, index) {
                    final alert = filteredAlerts[index];

                    Color rowColor = index.isEven ? Colors.white : const Color(0xFFFAFAFA);
                    if (alert.execType?.toUpperCase() == 'TRADE' || alert.status?.toUpperCase() == 'FILLED') {
                      rowColor = const Color(0xFFE3F2FD); // Light Blue for Trade/Filled
                    }

                    return Container(
                      color: rowColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🕒 1. Time Column
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatTime(alert.transactTime),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 📝 2. Investor Timeline Column
                          Expanded(
                            flex: 5,
                            child: Text(
                              _buildTimelineText(alert),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ),

                          // 🏷️ 3. Exec Type Column
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                alert.execType ?? '--',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(alert.execType),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  // ========================================================================
  // Helper Methods
  // ========================================================================

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--:--';
    try {
      DateTime dt = DateTime.parse(timeStr);
      return DateFormat('HH:mm:ss').format(dt);
    } catch (e) {
      return timeStr.length >= 19 ? timeStr.substring(11, 19) : timeStr;
    }
  }

  String _buildTimelineText(OrderAlertModel alert) {
    final side = alert.side?.toUpperCase() ?? '';
    final qty = alert.qty?.toString() ?? '0';
    final symbol = alert.symbol ?? '';
    final client = alert.clientId ?? '';
    final status = alert.status?.toUpperCase() ?? '';

    return "$side $qty @$symbol @$client: $status";
  }

  Color _getStatusColor(String? status) {
    final st = status?.toUpperCase() ?? '';
    if (st == 'NEW') return Colors.blue.shade700;
    if (st == 'FILLED' || st == 'TRADE') return Colors.green.shade700;
    if (st == 'CANCELED' || st == 'REJECTED' || st == 'EXPIRED') return Colors.red.shade600;
    if (st == 'PARTIALLY_FILLED' || st == 'REPLACED') return Colors.orange.shade700;
    return Colors.black87;
  }
}
