import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app_pkg.dart';

class OrderSummeryTabWidget extends StatelessWidget {
  const OrderSummeryTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderSummaryController>(
      init: OrderSummaryController(),
      builder: (controller) {
        // --- 1. Loading State ---
        if (controller.isLoading && controller.orderSummaryData == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        // --- 2. Error State ---
        if (controller.hasError && controller.orderSummaryData == null) {
          return _ErrorStateWidget(message: controller.errorMessage, onRetry: controller.refreshData);
        }

        final data = controller.orderSummaryData;
        final isSummaryEmpty = data?.summary?.isEmpty ?? true;
        final isOrdersEmpty = data?.clientOrders?.isEmpty ?? true;

        // --- 3. Empty State ---
        if (data == null || (isSummaryEmpty && isOrdersEmpty)) {
          return const _EmptyStateWidget();
        }

        // --- 4. Main Success UI ---
        return RefreshIndicator(
          color: Get.theme.primaryColor,
          onRefresh: () async => controller.refreshData(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // 📊 🚀 New Comparative Overall Summary Dashboard
              if (!isSummaryEmpty) SliverToBoxAdapter(child: _OverallSummarySection(summaries: data.summary!)),

              // 📋 Client Orders Header
              if (!isOrdersEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Text(
                      "Client Orders",
                      style: Get.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.3),
                    ),
                  ),
                ),

                // 📋 Client Orders List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final order = data.clientOrders![index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: _ClientOrderItemWidget(order: order),
                      );
                    }, childCount: data.clientOrders!.length),
                  ),
                ),
              ],

              // Bottom Spacing for smooth scroll
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// 🚀 Reusable UI Components (Premium Look)
// ==========================================
// ==========================================
// 🚀 Pro-Level: Overall Summary Section
// ==========================================

class _OverallSummarySection extends StatelessWidget {
  final List<Summary> summaries;
  const _OverallSummarySection({required this.summaries});

  @override
  Widget build(BuildContext context) {
    // 🚀 Extract Buy and Sell summaries safely
    final buySummary = summaries.firstWhere(
      (e) => e.side?.toUpperCase() == 'BUY',
      orElse: () => Summary(side: 'BUY', orders: 0, quantity: 0, filled: 0, execVal: 0.0),
    );
    final sellSummary = summaries.firstWhere(
      (e) => e.side?.toUpperCase() == 'SELL',
      orElse: () => Summary(side: 'SELL', orders: 0, quantity: 0, filled: 0, execVal: 0.0),
    );

    // 🚀 Calculate Totals
    final double buyVal = buySummary.execVal ?? 0.0;
    final double sellVal = sellSummary.execVal ?? 0.0;
    final double totalVal = buyVal + sellVal;

    final int totalOrders = (buySummary.orders ?? 0) + (sellSummary.orders ?? 0);
    final int totalQty = (buySummary.quantity ?? 0) + (sellSummary.quantity ?? 0);
    final double totalFilled = (buySummary.filled ?? 0) + (sellSummary.filled ?? 0);

    // Dominance Calculation
    final double buyFlex = totalVal > 0 ? (buyVal / totalVal) * 100 : 50;
    final double sellFlex = totalVal > 0 ? (sellVal / totalVal) * 100 : 50;

    const Color buyColor = Color(0xFF00C076);
    const Color sellColor = Color(0xFFFF4D4F);
    final Color textColor = Get.theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 🚀 1. ULTIMATE PREMIUM TOTAL CARD ---
          Container(
            width: double.infinity, // 🚀 FIXED: ফোর্সভালি পুরো উইডথ নেওয়ার জন্য
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // 🚀 FIXED: থিমের ওপর ভরসা না করে সরাসরি প্রিমিয়াম ফিন্যান্সিয়াল গ্রেডিয়েন্ট
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E3A8A), // Premium Deep Blue
                  Color(0xFF3B82F6), // Vibrant Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFF1E3A8A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.show_chart_rounded, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Gross Turnover",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.account_balance_wallet_rounded, size: 28, color: Colors.white.withOpacity(0.15)),
                  ],
                ),
                const SizedBox(height: 8),

                // Huge Total Value (🚀 Align দিয়ে ফিক্স করা হয়েছে)
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "৳${NumberFormatter.formatAmount('$totalVal')}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🚀 Glassmorphism Inner Card for Stats
                Container(
                  width: double.infinity, // 🚀 FIXED
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPremiumStatItem("Orders", "$totalOrders"),
                      Container(height: 32, width: 1, color: Colors.white.withOpacity(0.25)), // Divider
                      _buildPremiumStatItem("Quantity", "$totalQty"),
                      Container(height: 32, width: 1, color: Colors.white.withOpacity(0.25)), // Divider
                      _buildPremiumStatItem("Filled", totalFilled.toStringAsFixed(0)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- 🚀 2. BUY vs SELL Breakdown CARD ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Get.theme.shadowColor.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: Get.theme.dividerColor.withOpacity(0.4), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "BUY (${buyFlex.toStringAsFixed(1)}%)",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: buyColor),
                    ),
                    Text(
                      "SELL (${sellFlex.toStringAsFixed(1)}%)",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: sellColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: buyFlex.toInt(),
                        child: Container(height: 6, color: totalVal > 0 ? buyColor : Get.theme.dividerColor),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: sellFlex.toInt(),
                        child: Container(height: 6, color: totalVal > 0 ? sellColor : Get.theme.dividerColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 🚀 Completely Separated Matrix Rows
                _buildMatrixRow(
                  label: "Value",
                  buyValue: "৳${NumberFormatter.croreFormat(buyVal.toStringAsFixed(2))}",
                  sellValue: "৳${NumberFormatter.croreFormat(sellVal.toStringAsFixed(2))}",
                  buyColor: buyColor,
                  sellColor: sellColor,
                  textColor: textColor,
                  isBold: true,
                ),
                const SizedBox(height: 16),
                _buildMatrixRow(
                  label: "Orders",
                  buyValue: "${buySummary.orders ?? 0}",
                  sellValue: "${sellSummary.orders ?? 0}",
                  buyColor: buyColor,
                  sellColor: sellColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _buildMatrixRow(
                  label: "Quantity",
                  buyValue: "${buySummary.quantity ?? 0}",
                  sellValue: "${sellSummary.quantity ?? 0}",
                  buyColor: buyColor,
                  sellColor: sellColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _buildMatrixRow(
                  label: "Filled",
                  buyValue: "${buySummary.filled?.toStringAsFixed(0) ?? 0}",
                  sellValue: "${sellSummary.filled?.toStringAsFixed(0) ?? 0}",
                  buyColor: buyColor,
                  sellColor: sellColor,
                  textColor: textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 Premium Helper for Top Total Card Stats
  Widget _buildPremiumStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 🚀 FIXED: ওভারফ্লো রোধ করতে
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.7)),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ],
    );
  }

  // Helper for Comparison Matrix
  Widget _buildMatrixRow({
    required String label,
    required String buyValue,
    required String sellValue,
    required Color buyColor,
    required Color sellColor,
    required Color textColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Align(
            // 🚀 FIXED: ফোর্সভালি এলাইনমেন্ট দেওয়া হলো
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                buyValue,
                style: TextStyle(
                  fontSize: isBold ? 14 : 13,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  color: isBold ? buyColor : textColor,
                ),
              ),
            ),
          ),
        ),

        Expanded(
          flex: 3,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor.withOpacity(0.4),
              letterSpacing: 0.5,
            ),
          ),
        ),

        Expanded(
          flex: 4,
          child: Align(
            // 🚀 FIXED
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                sellValue,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: isBold ? 14 : 13,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                  color: isBold ? sellColor : textColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClientOrderItemWidget extends StatelessWidget {
  final ClientOrder order;

  const _ClientOrderItemWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    final double netVal = order.netExecVal ?? 0.0;
    final Color netColor = netVal > 0
        ? const Color(0xFF00C076) // Modern Green
        : (netVal < 0 ? const Color(0xFFFF4D4F) : Get.theme.disabledColor); // Modern Red

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Get.theme.shadowColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Get.theme.dividerColor.withOpacity(0.4), width: 1),
      ),
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: netColor)),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- Header: Symbol & Net Value ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.symbol ?? "",
                            style: Get.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: netColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: .center,
                        children: [
                          Text(
                            "NET VALUE: ",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: netColor.withOpacity(0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "৳${NumberFormatter.croreFormat(netVal.toStringAsFixed(2))}",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: netColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Divider(color: Get.theme.dividerColor.withOpacity(0.5), height: 1),
                const SizedBox(height: 6),

                // 🚀 Centralized Label Architecture (No Duplicate Texts)
                Row(
                  children: [
                    // --- 1. BUY Side Data ---
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BUY",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF00C076)),
                          ),
                          const SizedBox(height: 8),
                          _buildValueText("${order.buyExecQty ?? 0}"),
                          const SizedBox(height: 6),
                          _buildValueText("৳${(order.buyAvgPx ?? 0.0).toStringAsFixed(2)}"),
                          const SizedBox(height: 6),
                          _buildValueText(
                            "৳${NumberFormatter.croreFormat((order.buyExecVal ?? 0.0).toStringAsFixed(2))}",
                            isBold: true,
                          ),
                        ],
                      ),
                    ),

                    // --- 2. Central Common Labels ---
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(" ", style: TextStyle(fontSize: 12)), // Spacer for header
                          const SizedBox(height: 8),
                          _buildLabelText("Qty"),
                          const SizedBox(height: 6),
                          _buildLabelText("Avg Px"),
                          const SizedBox(height: 6),
                          _buildLabelText("Value"),
                        ],
                      ),
                    ),

                    // --- 3. SELL Side Data ---
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "SELL",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFF4D4F)),
                          ),
                          const SizedBox(height: 8),
                          _buildValueText("${order.sellExecQty ?? 0}"),
                          const SizedBox(height: 6),
                          _buildValueText("৳${(order.sellAvgPx ?? 0.0).toStringAsFixed(2)}"),
                          const SizedBox(height: 6),
                          _buildValueText(
                            "৳${NumberFormatter.croreFormat((order.sellExecVal ?? 0.0).toStringAsFixed(2))}",
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper text generators for clean UI
  Widget _buildLabelText(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
      ),
    );
  }

  Widget _buildValueText(String value, {bool isBold = false}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          color: Get.theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}

// ==========================================
// 🚀 Status Widgets (Error & Empty)
// ==========================================

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Get.theme.colorScheme.error.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.cloud_off_rounded, size: 40, color: Get.theme.colorScheme.error),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Get.theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Get.theme.disabledColor.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_rounded, size: 48, color: Get.theme.disabledColor.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          Text(
            "No Orders Yet",
            style: Get.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text("Your order summary will appear here.", style: TextStyle(color: Get.theme.disabledColor, fontSize: 13)),
        ],
      ),
    );
  }
}
