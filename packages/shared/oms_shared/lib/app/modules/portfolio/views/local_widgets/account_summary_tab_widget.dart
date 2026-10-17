import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/extensions/app_context.dart';
import '../../../../core/utils/helpers/formatter_helper.dart';
import '../../../../core/values/colors.dart';
import '../../../../global_widgets/visible_get_builder.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../../global_widgets/loaders/order_list_loader.dart';
import '../../controllers/position_controller.dart';

class AccountSummaryTabWidget extends StatelessWidget {
  const AccountSummaryTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Same registration as the Position tab (shared controller).
    if (!Get.isRegistered<PositionController>()) Get.put(PositionController());

    return GetBuilder<HomeController>(
      id: 'user_balance_update',
      builder: (homeCont) {
        if (homeCont.userBalanceData == null) {
          return const OrderListLoader();
        }

        final user = homeCont.userBalanceData;
        final bool hasWib = user?.canUsedIntradayAmount == true;
        final String clientCode = user?.clientCode ?? '';

        return RefreshIndicator(
          onRefresh: () async {
            Get.find<PositionController>().initializePosition();
            homeCont.userBalance();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            child: Center(
              // Readable width on tablets / web; full width on phones.
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    _BalanceCard(
                      amount: user?.amount ?? 0,
                      intradayAmount: user?.intradayAmount ?? 0,
                      clientCode: clientCode,
                      hasWib: hasWib,
                    ),
                    // Live: rebuilds on position updates and on price ticks
                    // ('marketList', already throttled), only while visible.
                    VisibleGetBuilder<HomeController>(
                      id: 'marketList',
                      builder: (_) => VisibleGetBuilder<PositionController>(
                        builder: (positionCont) =>
                            _PortfolioCard(positionCont: positionCont),
                      ),
                    ),
                    _AccountDetailsCard(homeCont: homeCont, hasWib: hasWib),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
//  Shared building blocks
// ----------------------------------------------------------------------
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title, this.icon});

  final String? title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSideColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            if (title != null)
              Row(
                spacing: 8,
                children: [
                  Icon(icon, size: 18, color: ColorConstants.unchangedColor),
                  Expanded(
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Get.textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textColor,
                      ),
                    ),
                  ),
                ],
              ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Amount with a small "BDT" suffix; scales down rather than overflowing.
class _Amount extends StatelessWidget {
  const _Amount({
    required this.value,
    required this.fontSize,
    this.color,
    this.prefix = '',
    this.alignEnd = false,
    this.showCurrency = true,
  });

  final double value;
  final double fontSize;
  final Color? color;
  final String prefix;
  final bool alignEnd;
  final bool showCurrency;

  @override
  Widget build(BuildContext context) {
    final Color muted = context.textColor.withValues(alpha: 0.55);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: 4,
        children: [
          Text(
            '$prefix${NumberFormatter.bdFormat(value)}',
            style: Get.textTheme.titleMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color ?? context.textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (showCurrency)
            Text(
              'BDT',
              style: Get.textTheme.bodySmall?.copyWith(
                fontSize: (fontSize * 0.45).clamp(10, 14),
                fontWeight: FontWeight.w600,
                color: muted,
              ),
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Get.textTheme.bodySmall?.copyWith(
        fontSize: 12,
        color: context.textColor.withValues(alpha: 0.6),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
//  1. Cash balance
// ----------------------------------------------------------------------
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.amount,
    required this.intradayAmount,
    required this.clientCode,
    required this.hasWib,
  });

  final double amount;
  final double intradayAmount;
  final String clientCode;
  final bool hasWib;

  @override
  Widget build(BuildContext context) {
    final Color accent = ColorConstants.unchangedColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: context.isDark ? 0.28 : 0.14),
            context.cardColor,
          ],
        ),
        border: Border.all(color: context.borderSideColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                  color: accent,
                ),
                const Expanded(child: _Label('Available Cash Balance')),
                if (hasWib) _Pill(text: 'WIB', color: ColorConstants.success),
              ],
            ),
            _Amount(value: amount, fontSize: 30),
            const SizedBox(height: 8),
            Divider(height: 1, color: context.dividerColor),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const _Label('Intraday Limit'),
                      _Amount(
                        value: intradayAmount,
                        fontSize: 16,
                        color: hasWib ? ColorConstants.success : null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 4,
                    children: [
                      const _Label('Client ID'),
                      Text(
                        clientCode.isNotEmpty ? clientCode : 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
//  2. Portfolio snapshot (same figures as the Position tab)
// ----------------------------------------------------------------------
class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.positionCont});

  final PositionController positionCont;

  @override
  Widget build(BuildContext context) {
    final double invested = positionCont.totalInvestment;
    final double marketValue = positionCont.currentPortfolioValue;
    final double pnl = positionCont.totalUnrealizedPnL;
    final double pnlPct = positionCont.totalUnrealizedPnLPercentage;
    final Color pnlColor = pnl >= 0
        ? ColorConstants.upColor
        : ColorConstants.downColor;
    final String sign = pnl > 0 ? '+' : '';

    return _SectionCard(
      title: 'Portfolio Snapshot',
      icon: Icons.pie_chart_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const _Label('Investment'),
                    _Amount(value: invested, fontSize: 16, showCurrency: false),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 4,
                  children: [
                    const _Label('Market Value'),
                    _Amount(
                      value: marketValue,
                      fontSize: 16,
                      alignEnd: true,
                      showCurrency: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Gain / loss: label + amount on the left, % chip on the right,
          // both vertically centred.
          DecoratedBox(
            decoration: BoxDecoration(
              color: pnlColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: pnlColor.withValues(alpha: 0.25)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  spacing: 12,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: pnlColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          pnl >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 20,
                          color: pnlColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          const _Label('Gain / Loss'),
                          _Amount(
                            value: pnl,
                            prefix: sign,
                            fontSize: 18,
                            color: pnlColor,
                            showCurrency: false,
                          ),
                        ],
                      ),
                    ),
                    // Natural width at the end; capped so tiny screens shrink
                    // it instead of overflowing.
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.35,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: pnlColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Text(
                              '$sign${pnlPct.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ),
                      ),
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
//  3. Account details
// ----------------------------------------------------------------------
class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({required this.homeCont, required this.hasWib});

  final HomeController homeCont;
  final bool hasWib;

  @override
  Widget build(BuildContext context) {
    final profile = homeCont.userInfo;
    final detail = profile.userDetail;

    final rows = <(IconData, String, String?)>[
      (Icons.person_rounded, 'Investor Name', detail?.investorName),
      (Icons.badge_rounded, 'Investor Code', detail?.investorCode),
      (Icons.account_tree_rounded, 'BO ID', detail?.boId),
      (Icons.support_agent_rounded, 'Trader', detail?.traderCode),
      (Icons.email_rounded, 'Email', profile.email),
      (Icons.phone_rounded, 'Mobile', profile.mobile),
    ].where((r) => (r.$3 ?? '').trim().isNotEmpty).toList();

    return _SectionCard(
      title: 'Account Details',
      icon: Icons.manage_accounts_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in rows)
            _DetailRow(icon: r.$1, label: r.$2, value: r.$3!),
          _DetailRow(
            icon: Icons.currency_exchange_rounded,
            label: 'Currency',
            value: 'BDT',
          ),
          _DetailRow(
            icon: Icons.bolt_rounded,
            label: 'Intraday (WIB)',
            trailing: _Pill(
              text: hasWib ? 'Enabled' : 'Disabled',
              color: hasWib ? ColorConstants.success : ColorConstants.gray,
            ),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final Color muted = context.textColor.withValues(alpha: 0.55);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: context.dividerColor))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        // Label keeps its natural width (capped at half the row so tiny
        // screens never overflow); the value fills the rest, right-aligned.
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            spacing: 10,
            children: [
              Icon(icon, size: 18, color: muted),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.5,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: muted,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child:
                      trailing ??
                      Text(
                        value ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textColor,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
