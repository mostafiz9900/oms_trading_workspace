import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

import '../core/core.dart';

class InfoTooltipIcon2 extends StatelessWidget {
  final String infoText;
  final double size;
  final Color color;

  const InfoTooltipIcon2({super.key, required this.infoText, this.size = 16.0, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext localContext) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              showPopover(
                context: localContext,
                bodyBuilder: (context) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(infoText, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
                ),
                direction: PopoverDirection.top,
                // width: 220,
                radius: 10,
                backgroundColor: Colors.white,
                barrierColor: Colors.black.withValues(alpha: 0.1),
                arrowHeight: 10,
                arrowWidth: 20,
                shadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              );
            },
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.2),
              ),
              child: Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: color,
                    fontSize: (size * 0.55), // সাইজের সাথে টেক্সট অ্যাডজাস্ট হবে
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class InfoTooltipIcon extends StatelessWidget {
  const InfoTooltipIcon({super.key, required this.infoText, this.size = 15.0, this.color = Colors.blue});

  final String infoText;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          AppPopover.show(context: context, text: infoText);
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(color: color, fontSize: size * 0.60, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
