import 'package:broker_config/broker_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/extensions/app_context.dart';
import '../../core/values/app_config.dart';
import '../../data/services/exchange_service.dart';

/// `DSE | CSE` toggle switch that picks the exchange whose market data is
/// shown. A highlight slides under the selected exchange; tapping either side
/// selects it.
///
/// Renders nothing unless the house trades on both DSE and CSE, so
/// single-exchange apps look exactly as before.
class ExchangeSwitcher extends StatelessWidget {
  const ExchangeSwitcher({super.key});

  static const double _segmentWidth = 36;
  static const double _height = 26;
  static const double _padding = 2;
  static const Duration _slide = Duration(milliseconds: 200);

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
    final exchanges = service.available;
    final accent = context.buttonColor;

    return Obx(() {
      final selected = service.selected.value;
      final selectedIndex = exchanges.indexOf(selected);
      return Semantics(
        label: 'Exchange',
        value: label(selected),
        child: Container(
          key: const ValueKey('exchange_switcher'),
          width: _segmentWidth * exchanges.length + _padding * 2,
          height: _height,
          padding: const EdgeInsets.all(_padding),
          decoration: BoxDecoration(
            color: accent.withAlpha(26),
            borderRadius: BorderRadius.circular(_height / 2),
          ),
          child: Stack(
            children: [
              // Sliding highlight under the selected exchange.
              AnimatedAlign(
                duration: _slide,
                curve: Curves.easeOutCubic,
                alignment: exchanges.length < 2
                    ? Alignment.center
                    : Alignment(
                        -1 + 2 * selectedIndex / (exchanges.length - 1),
                        0,
                      ),
                child: Container(
                  width: _segmentWidth,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(_height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withAlpha(77),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final exchange in exchanges)
                    _Segment(
                      key: ValueKey('exchange_${exchange.name}'),
                      text: label(exchange),
                      selected: exchange == selected,
                      width: _segmentWidth,
                      duration: _slide,
                      onTap: () => service.select(exchange),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    super.key,
    required this.text,
    required this.selected,
    required this.width,
    required this.duration,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final double width;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: duration,
            // Start from the theme so the app's font family is kept.
            style: (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
                .copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: selected
                      ? Colors.white
                      : context.textColor.withAlpha(166),
                ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
