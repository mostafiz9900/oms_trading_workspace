import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/extensions/app_context.dart';
import '../../core/values/app_config.dart';
import '../../data/services/exchange_service.dart';

/// "DSE ▾" chip that picks the exchange whose market data is shown.
///
/// Renders nothing unless the house trades on both DSE and CSE, so
/// single-exchange apps look exactly as before.
class ExchangeSwitcher extends StatelessWidget {
  const ExchangeSwitcher({super.key});

  static String label(StockExchange exchange) => switch (exchange) {
    StockExchange.dse => 'DSE',
    StockExchange.cse => 'CSE',
  };

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasBothExchanges || !Get.isRegistered<ExchangeService>()) {
      return const SizedBox.shrink();
    }
    final service = Get.find<ExchangeService>();
    return Obx(() {
      final selected = service.selected.value;
      return PopupMenuButton<StockExchange>(
        key: const ValueKey('exchange_switcher'),
        tooltip: 'Exchange',
        initialValue: selected,
        position: PopupMenuPosition.under,
        onSelected: service.select,
        itemBuilder: (_) => [
          for (final exchange in service.available)
            CheckedPopupMenuItem<StockExchange>(
              value: exchange,
              checked: exchange == selected,
              child: Text(label(exchange)),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: context.buttonColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label(selected),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.buttonColor,
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: context.buttonColor,
              ),
            ],
          ),
        ),
      );
    });
  }
}
