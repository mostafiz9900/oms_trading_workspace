import '../extensions/app_context.dart';
import '../../values/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumberFormatter {
  // NumberFormat parses its pattern on construction; these run for every
  // visible row on every live tick, so the instances are created once.
  static final _inr2 = NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2);
  static final _compact = NumberFormat.compact(locale: 'en');
  static final _us2 = NumberFormat('#,##0.00', 'en_US');
  static final _usUpTo2 = NumberFormat('#,##0.##', 'en_US');
  static final _bdInt = NumberFormat('#,##,##0', 'en_IN');
  static final Map<String, NumberFormat> _bdByPattern = {};
  static final Map<int, NumberFormat> _fixed2ByDecimal = {};

  static String formatDouble(double value) {
    return _inr2.format(value);
  }

  /// Format as Indian style: 1,22,333.90
  static String indianFormat(num value) {
    return _inr2.format(value);
  }

  /// Compact format: 1.2K, 3.4M
  static String compactFormat(num value) {
    return _compact.format(value);
  }

  static String millionFormat(num value) {
    final inMillion = value / 1000000; // 1M = 1,000,000
    return "${inMillion.toStringAsFixed(2)}M";
  }

  static String croreFormat(dynamic value) {
    try {
      if (value == null) return "0.0cr";

      double parsedValue = 0.0;

      if (value is num) {
        parsedValue = value.toDouble();
      } else if (value is String) {
        // কমা (,) থাকলে সেটি সরিয়ে পার্স করবে
        parsedValue = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
      }
      if (parsedValue.isNaN || parsedValue.isInfinite) {
        return "0.0cr";
      }
      final inCrore = parsedValue / 10000000;
      return "${_us2.format(inCrore)}cr";
    } catch (e) {
      return "0.0cr";
    }
  }

  static String smartMarketFormat(dynamic value) {
    try {
      if (value == null) return "0.00";

      double parsedValue = 0.0;

      if (value is num) {
        parsedValue = value.toDouble();
      } else if (value is String) {
        parsedValue = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
      }

      if (parsedValue.isNaN || parsedValue.isInfinite) return "0.00";

      final absValue = parsedValue.abs();
      final sign = parsedValue < 0 ? "-" : "";

      if (absValue >= 10000000) {
        final inCrore = absValue / 10000000;
        return "$sign${_us2.format(inCrore)} Cr";
      } else if (absValue >= 100000) {
        final inLakh = absValue / 100000;
        return "$sign${_us2.format(inLakh)} L";
      } else {
        // ছোট অ্যামাউন্ট হলে নরমাল কমা ফরম্যাট
        return "$sign${_usUpTo2.format(absValue)}";
      }
    } catch (e) {
      return "0.00";
    }
  }

  /// Fixed decimal format: 123.45
  static String fixedDecimal(num value, {int decimal = 2}) {
    return value.toStringAsFixed(decimal);
  }

  static String fixedDecimal2(num value, {int decimal = 2}) {
    final format = _fixed2ByDecimal.putIfAbsent(
      decimal,
      () => NumberFormat.currency(
        locale: "en_US",
        symbol: "", // no currency symbol
        decimalDigits: decimal,
        customPattern: '#,##,##0.00',
      ),
    );

    return format.format(value);
  }

  /// US style comma formatting
  static String usFormat(num value) {
    return _us2.format(value);
  }

  /// Bangladesh style comma formatting
  static String bdFormat(dynamic value, {int decimalPlaces = 2}) {
    int safeDecimal = decimalPlaces < 0 ? 0 : decimalPlaces;
    String fallbackValue = safeDecimal > 0 ? "0.${'0' * safeDecimal}" : "0";

    try {
      if (value == null) return fallbackValue;
      double parsedValue = 0.0;
      if (value is num) {
        parsedValue = value.toDouble();
      } else if (value is String) {
        parsedValue = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
      }
      if (parsedValue.isNaN || parsedValue.isInfinite) {
        return fallbackValue;
      }
      String pattern = safeDecimal > 0 ? '#,##,##0.${'0' * safeDecimal}' : '#,##,##0';
      // 'en_IN' বাংলাদেশের ১,০০,০০০ ফরম্যাটের জন্য কাজ করবে
      final formatter = _bdByPattern.putIfAbsent(pattern, () => NumberFormat(pattern, 'en_IN'));
      return formatter.format(parsedValue);
    } catch (e) {
      return fallbackValue;
    }
  }

  static String bdFormatInt(num value) {
    return _bdInt.format(value);
  }

  /// Currency format with symbol
  static String withCurrency(num value, {String symbol = '₹'}) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: symbol, decimalDigits: 2);
    return formatter.format(value);
  }

  static String formatAmount(String? value) {
    double doubleValue = double.tryParse(value ?? '0') ?? 0.0;

    if (doubleValue >= 1000000000000) {
      return '${(doubleValue / 1000000000000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}T';
    } else if (doubleValue >= 1000000000) {
      return '${(doubleValue / 1000000000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}B';
    } else if (doubleValue >= 10000000) {
      return '${(doubleValue / 10000000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}Cr';
    } else if (doubleValue >= 100000) {
      return '${(doubleValue / 100000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}L';
    } else if (doubleValue >= 1000) {
      return '${(doubleValue / 1000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}K';
    } else {
      return doubleValue.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
    }
  }

  static String calculateAndFormatSum(dynamic q1, dynamic q2, dynamic q3) {
    double v1 = double.tryParse(q1.toString()) ?? 0.0;
    double v2 = double.tryParse(q2.toString()) ?? 0.0;
    double v3 = double.tryParse(q3.toString()) ?? 0.0;

    double total = v1 + v2 + v3;

    // আগে তৈরি করা CurrencyFormatter ব্যবহার করে ফরম্যাট করা
    return formatAmount(total.toString());
  }
}

class NumberHelper {
  /// Format value with + or - sign
  static String formatSigned(num? value, {int decimals = 2}) {
    if (value == null) return "--";

    final v = double.tryParse(value.toString()) ?? 0.0;

    if (v > 0) return "+${v.toStringAsFixed(decimals)}";
    if (v < 0) return v.toStringAsFixed(decimals);

    return v.toStringAsFixed(decimals); // zero
  }

  static ({String text, Color color}) formatPriceChange(double? changeValue, BuildContext context) {
    final value = changeValue ?? 0.0;

    if (value > 0) {
      return (text: '+${value.toStringAsFixed(2)}', color: Colors.green);
    } else if (value < 0) {
      return (text: value.toStringAsFixed(2), color: Colors.red);
    } else {
      return (text: '0.00', color: context.textColor);
    }
  }

  /// Get color based on value
  static Color getColor(num? value) {
    if (value == null) return ColorConstants.unchangedColor;

    final v = double.tryParse(value.toString()) ?? 0.0;

    if (v > 0) return ColorConstants.upColor; // positive
    if (v < 0) return ColorConstants.downColor; // negative

    return ColorConstants.unchangedColor; // zero
  }

  /// Return arrow ↑ ↓ —
  static String arrow(num? value) {
    if (value == null) return "—";

    final v = double.tryParse(value.toString()) ?? 0.0;

    if (v > 0) return "↑";
    if (v < 0) return "↓";

    return "—";
  }
}
