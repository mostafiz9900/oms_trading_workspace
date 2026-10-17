
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';


class AppPopover {
  static void show({
    required BuildContext context,
    required String text,
    PopoverDirection direction = PopoverDirection.top,
    double radius = 10,
    Color backgroundColor = Colors.white,
    double arrowHeight = 10,
    double arrowWidth = 20,
    TextStyle? textStyle,
    List<BoxShadow>? shadow,
  }) {
    showPopover(
      context: context,
      direction: direction,
      radius: radius,
      backgroundColor: backgroundColor,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      arrowHeight: arrowHeight,
      arrowWidth: arrowWidth,
      shadow: shadow ?? const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      bodyBuilder: (context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text, style: textStyle ?? const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
      ),
    );
  }
}
