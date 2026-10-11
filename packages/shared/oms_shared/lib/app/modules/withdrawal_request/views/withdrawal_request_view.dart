import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_pkg.dart';
import '../../home/views/local_widgets/index_value_loader.dart';
import '../controllers/withdrawal_request_controller.dart';
import '../../../data/models/response/withdraw_model.dart'; //  মডেল ইম্পোর্ট করা হলো

class WithdrawalRequestView extends GetView<WithdrawalRequestController> {
  const WithdrawalRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: CustomAppBar(
        titleText: 'Withdrawal Request',
        isBackButtonIcon: true,
        backButtonOnClick: () => Get.back(),
        right: const SizedBox.shrink(),
      ),

      // ==========================================
      //  1. FLOATING ACTION BUTTON
      // ==========================================
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: context.buttonColor,
        onPressed: () => _openWithdrawDialog(context, controller),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Request",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      // ==========================================
      //  2. WITHDRAW LIST VIEW
      // ==========================================
      body: GetBuilder<WithdrawalRequestController>(
        builder: (_) {
          if (controller.isFetching) {
            return const Center(child: OrderListLoader());
          }

          if (controller.withdrawList.isEmpty) {
            return Center(
              child: Text("No withdrawal requests found.", style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchWithdrawList(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80, left: 16, right: 16),
              itemCount: controller.withdrawList.length,
              itemBuilder: (context, index) {
                final item = controller.withdrawList[index];
                return _buildWithdrawItem(context, item, isDark);
              },
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // ==========================================
  Widget _buildWithdrawItem(BuildContext context, WithdrawModel item, bool isDark) {
    String status = item.status?.toUpperCase() ?? 'PENDING';
    Color statusColor = status == 'PENDING'
        ? Colors.orange
        : (status == 'APPROVED' ? ColorConstants.success : Colors.red);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.investorName ?? 'Unknown Investor',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(item.createdAt),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(item.createdAt),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                "৳ ${item.withdrawRequest ?? '0'}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.teal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  //  3. WITHDRAW DIALOG
  // ==========================================
  void _openWithdrawDialog(BuildContext context, WithdrawalRequestController controller) {
    controller.clearForm();

    // 🚀 Controller থেকে ডেটা নেওয়া হচ্ছে
    var investorCode = controller.homeController.userInfo.userDetail?.investorCode ?? 'N/A';
    double rawAvailableAmount = controller.userBalance?.amount ?? 0.0; // 🚀 ভ্যালিডেশনের জন্য রিয়েল ডাটা
    var formattedAvailableAmount = rawAvailableAmount.toStringAsFixed(2);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: context.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: GetBuilder<WithdrawalRequestController>(
            builder: (_) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Withdrawal Request",
                                style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Request for client withdrawal",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Get.back(),
                            child: Icon(Icons.close, color: context.textColor, size: 24),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Available (BDT)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    "৳ $formattedAvailableAmount",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      //  Withdraw Amount Input (🚀 Real-time Validation Added)
                      RichText(
                        text: TextSpan(
                          text: "Withdraw Amount (BDT) ",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                          children: const [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomEditTextFormField(
                        controller: controller.amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        hintText: "Enter amount",
                        onChanged: (value) {
                          // 🚀 ইউজার টাইপ করার সাথে সাথে চেক করবে
                          double enteredAmount = double.tryParse(value) ?? 0.0;

                          if (enteredAmount > rawAvailableAmount) {
                            // 🚀 বেশি দিলে অটোমেটিক ম্যাক্সিমাম অ্যামাউন্ট বসিয়ে দিবে এবং কার্সর শেষে নিয়ে যাবে
                            controller.amountController.text = rawAvailableAmount.toInt().toString();
                            controller.amountController.selection = TextSelection.fromPosition(
                              TextPosition(offset: controller.amountController.text.length),
                            );

                            // 🚀 ইউজারকে একটি ওয়ার্নিং দেখাবে
                            Helpers.snackbarForErorr2(
                              titleText: "Limit Exceeded",
                              bodyText: "You cannot withdraw more than your available balance.",
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      //  Narration Input
                      RichText(
                        text: TextSpan(
                          text: "Narration ",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                          children: const [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomEditTextFormField(
                        controller: controller.narrationController,
                        keyboardType: TextInputType.text,
                        hintText: "Write withdrawal narration...",
                        maxLine: 3,
                        minHeight: 80,
                        onChanged: (value) {},
                      ),

                      const SizedBox(height: 28),

                      //  Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: controller.isSubmitting ? null : () => controller.submitWithdrawRequest(context),
                          child: controller.isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text(
                                  "Submit Request",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '--';
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
  }
}
