import 'package:flutter/material.dart';

import '../core/core.dart';

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
