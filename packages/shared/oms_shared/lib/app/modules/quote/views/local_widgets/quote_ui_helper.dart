
import '../../../../global_widgets/info_tooltip_icon.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app_pkg.dart';

// ==========================================
// ==========================================
class QuoteUIHelper {
  static Widget buildSingleItem(
    BuildContext context,
    String period,
    String value,
    Color? color,
  ) {
    return SizedBox(
      width: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(period, style: Get.textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Get.textTheme.bodySmall?.copyWith(
              color: color ?? context.textColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPerformanceItem(
    BuildContext context,
    String period,
    String value, {
    double width = 62,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(period, style: Get.textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: Get.textTheme.bodySmall?.copyWith(color: context.textColor),
          ),
        ],
      ),
    );
  }

  static Widget buildPerformanceItemWithTooltip(
    BuildContext context,
    String period,
    String value, {
    double width = 62,
    required bool showInfo,
    required String infoText,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: Get.textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  NumberFormatter.croreFormat(value),
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: context.textColor,
                  ),
                ),
              ),
              if (showInfo) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InfoTooltipIcon(
                    infoText: infoText,
                    size: 13,
                    color: Colors.blue,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Widget build4Item(
    BuildContext context,
    String period,
    String value,
    String value2,
  ) {
    return SizedBox(
      width: 62,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              color: HexColor('#9C9FA4'),
            ),
          ),
          AppSpace.spaceH2,
          Text(
            value,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          AppSpace.spaceH2,
          Text(
            value2,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
