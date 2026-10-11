import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app_pkg.dart';
import '../../home/views/local_widgets/index_value_loader.dart';
import '../controllers/limit_request_controller.dart';

class LimitRequestView extends GetView<LimitRequestController> {
  const LimitRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Client Limit',
        isBackButtonIcon: true,
        backButtonOnClick: () => Get.back(),
        //  Custom Header Right Button for View Toggle
        right: GetBuilder<LimitRequestController>(
          builder: (cont) {
            return IconButton(
              splashRadius: 24,
              icon: Icon(
                cont.isShortView ? Icons.view_agenda_rounded : Icons.format_list_bulleted_rounded,
                color: context.buttonColor,
                size: 22,
              ),
              onPressed: cont.toggleViewMode,
            );
          },
        ),
      ),
      body: const _ClientLimitView(),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: context.buttonColor,
      //   onPressed: () => controller.openLimitRequestDialog(context),
      //   child: Icon(Icons.add, color: context.iconColor),
      // ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: context.buttonColor,
        onPressed: () => controller.openLimitRequestDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Request",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

//  Common Date Formatter
String formatDateTime(String rawDate) {
  try {
    final DateTime dateTime = DateTime.parse(rawDate);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  } catch (e) {
    return rawDate;
  }
}

class _ClientLimitView extends StatelessWidget {
  const _ClientLimitView();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LimitRequestController>(
      builder: (controller) {
        // Initial Loader
        if (controller.isLoading && controller.clientLimitList.isEmpty) {
          return const OrderListLoader();
        }
        if (!controller.isLoading && controller.clientLimitList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No client limits found', // আপনার পছন্দমত মেসেজ বা উইজেট দিন
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.builder(
          controller: controller.scrollController,
          itemCount: controller.clientLimitList.length + (controller.currentPage < controller.totalPages ? 1 : 0),
          itemBuilder: (context, index) {
            // Bottom loader for pagination
            if (index == controller.clientLimitList.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final item = controller.clientLimitList[index];

            //  Common Reusable Widget Call
            return CommonLimitItemWidget(item: item, isShortView: controller.isShortView);
          },
        );
      },
    );
  }
}

class CommonLimitItemWidget extends StatelessWidget {
  final dynamic item;
  final bool isShortView;

  const CommonLimitItemWidget({super.key, required this.item, required this.isShortView});

  @override
  Widget build(BuildContext context) {
    // 🎨 Status Color Logic
    String status = item['status']?.toString().toUpperCase() ?? 'PENDING';
    Color statusColor;

    if (status == 'APPROVED' || status == 'ACCEPTED') {
      statusColor = ColorConstants.success;
    } else if (status == 'REJECTED' || status == 'DECLINED' || status == 'CANCELLED') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return InkWell(
      onTap: () {
        // Handle Item Click
      },
      child: isShortView
          ? _buildShortView(context, status, statusColor)
          : _buildDetailedView(context, status, statusColor),
    );
  }

  // ==========================================
  // 🟢 ১. SHORT VIEW (Client Code Removed, Added Date Time)
  // ==========================================
  Widget _buildShortView(BuildContext context, String status, Color statusColor) {
    return Container(
      key: const ValueKey('short_view'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.dividerColor, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item['investor_name'] ?? 'Unknown',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: context.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['market'] ?? 'N/A',
                        style: const TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                //  ক্লায়েন্ট কোড সরিয়ে এখানে Date & Time দেওয়া হলো
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      formatDateTime(item['created_at']),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "৳ ${item['requested_amount']}",
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🟢 ২. ACCESSIBLE DETAIL VIEW (বয়স্ক ইউজারদের জন্য)
  // ==========================================
  Widget _buildDetailedView(BuildContext context, String status, Color statusColor) {
    return Container(
      key: const ValueKey('detail_view'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Get.theme.cardColor,
        color: context.isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Name & Status (বড় ফন্ট)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item['investor_name'] ?? 'Unknown Investor',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: context.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: context.dividerColor ?? Colors.grey.withOpacity(0.2)),
          ),

          _buildInfoRow(context, "Market Type:", item['market'] ?? 'N/A'),
          const SizedBox(height: 10),
          _buildInfoRow(context, "Request Date:", formatDateTime(item['created_at'])),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: context.dividerColor ?? Colors.grey.withOpacity(0.2)),
          ),

          //  Amount (সবচেয়ে হাইলাইটেড অংশ)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Requested Amount",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
              ),
              Text(
                "৳ ${item['requested_amount']}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blueAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //  Helper method for accessible info rows
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: Get.textTheme.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
      ],
    );
  }
}
