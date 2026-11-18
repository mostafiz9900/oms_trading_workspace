import 'package:broker_config/broker_config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:getxify/getxify.dart';

import '../../core/utils/extensions/app_context.dart';
import '../../core/values/app_config.dart';
import '../../data/models/response/market_model.dart';
import '../../data/services/cse_market_service.dart';
import '../../data/services/exchange_service.dart';
import '../../data/services/market_listing_matcher.dart';
import '../../modules/home/controllers/home_controller.dart';

/// `DSE | CSE` toggle switch that picks the exchange whose market data is
/// shown. A highlight slides under the selected exchange; tapping either side
/// selects it.
///
/// Renders nothing unless the house trades on both DSE and CSE, so
/// single-exchange apps look exactly as before.
class ExchangeSwitcher extends StatelessWidget {
  const ExchangeSwitcher({
    super.key,
    this.padding = EdgeInsets.zero,
    this.scope = ExchangeScope.quoteTrade,
  });

  /// Space around the switch; applied only when the switch is shown, so
  /// single-exchange layouts are unchanged.
  final EdgeInsetsGeometry padding;
  final ExchangeScope scope;

  static const double _segmentWidth = 33;
  static const double _height = 22;
  static const double _padding = 0;
  static const Duration _slide = Duration(milliseconds: 200);
  static final Map<ExchangeScope, Rx<StockExchange?>> _pendingTarget = {
    for (final scope in ExchangeScope.values) scope: Rx<StockExchange?>(null),
  };

  static Future<void> _requestExchangeSwitch(
    ExchangeService exchangeService,
    StockExchange targetExchange,
    ExchangeScope scope,
  ) async {
    final selected = exchangeService.selection(scope);
    if (selected.value == targetExchange ||
        _pendingTarget[scope]!.value != null) {
      return;
    }

    _pendingTarget[scope]!.value = targetExchange;
    try {
      // Quote and Trade are attached to one selected instrument, so validate
      // its listing before changing their shared exchange. Independent pages
      // (market, watchlist, search, etc.) switch their own feed directly.
      if (scope != ExchangeScope.quoteTrade) {
        exchangeService.select(targetExchange, scope: scope);
        return;
      }

      if (!Get.isRegistered<HomeController>()) {
        await _showUnavailableDialog(targetExchange, 'the selected stock');
        return;
      }

      final home = Get.find<HomeController>();
      final source = home.marketData;
      if ((source.isinCode ?? '').trim().isEmpty ||
          (source.board ?? '').trim().isEmpty) {
        await _showUnavailableDialog(targetExchange, 'the selected stock');
        return;
      }

      final targetFeed = home.marketFeedForExchange(targetExchange);
      if (targetFeed == null) {
        await _showUnavailableDialog(
          targetExchange,
          source.shortName ?? source.ticker ?? 'the selected stock',
        );
        return;
      }
      bool isAvailable(MarketModel quote) =>
          MarketListingMatcher.isSameListing(source, quote);
      final bool found;
      if (targetExchange == StockExchange.cse) {
        found = await Get.find<CseMarketService>().hasQuoteForSwitch(
          isAvailable,
        );
      } else {
        // Read DSE's raw tick store, even while CSE is visible and before the
        // throttled UI list has flushed its latest update.
        found = home.dseStoreHasListing(source);
      }

      if (!found) {
        await _showUnavailableDialog(
          targetExchange,
          source.shortName ?? source.ticker ?? 'the selected stock',
        );
        return;
      }

      exchangeService.select(targetExchange, scope: scope);
    } finally {
      _pendingTarget[scope]!.value = null;
    }
  }

  static Future<void> _showUnavailableDialog(
    StockExchange exchange,
    String instrument,
  ) async {
    await Get.dialog<void>(
      Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colors = theme.colorScheme;
          return AlertDialog(
            backgroundColor: colors.surface,
            title: Text(
              'Same item not found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
              ),
            ),
            content: Text(
              'Could not find $instrument on ${label(exchange)} with the same '
              'ISIN code and board. You are still on the current exchange.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back<void>(),
                style: TextButton.styleFrom(foregroundColor: colors.primary),
                child: const Text('OK'),
              ),
            ],
          );
        },
      ),
      barrierDismissible: true,
    );
  }

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
      final selected = service.selection(scope).value;
      final pendingTarget = _pendingTarget[scope]!.value;
      final selectedIndex = exchanges.indexOf(selected);
      return Padding(
        padding: padding,
        child: Semantics(
          label: 'Exchange',
          value: label(selected),
          child: Container(
            key: const ValueKey('exchange_switcher'),
            width: _segmentWidth * exchanges.length + _padding * 2,
            height: _height,
            padding: const EdgeInsets.all(_padding),
            decoration: BoxDecoration(
              color: context.isDark
                  ? Colors.white.withAlpha(26)
                  : const Color(0xFFEDEDED),
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
                        loading: exchange == pendingTarget,
                        enabled: pendingTarget == null,
                        width: _segmentWidth,
                        duration: _slide,
                        progressColor: accent,
                        onTap: () =>
                            _requestExchangeSwitch(service, exchange, scope),
                      ),
                  ],
                ),
              ],
            ),
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
    required this.loading,
    required this.enabled,
    required this.width,
    required this.duration,
    required this.progressColor,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool loading;
  final bool enabled;
  final double width;
  final Duration duration;
  final Color progressColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: width,
        child: Center(
          child: Semantics(
            button: true,
            enabled: enabled,
            label: loading ? 'Checking $text availability' : 'Switch to $text',
            child: loading
                ? SizedBox(
                    key: ValueKey('exchange_loading_$text'),
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: selected ? Colors.white : progressColor,
                    ),
                  )
                : AnimatedDefaultTextStyle(
                    duration: duration,
                    // Start from the theme so the app's font family is kept.
                    style:
                        (Theme.of(context).textTheme.labelLarge ??
                                const TextStyle())
                            .copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                              color: selected
                                  ? Colors.white
                                  : context.textColor,
                            ),
                    child: Text(text),
                  ),
          ),
        ),
      ),
    );
  }
}
