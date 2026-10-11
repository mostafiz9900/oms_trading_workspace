import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData icon;

  const EmptyWidget({super.key, this.title, this.subtitle, this.icon = Icons.hourglass_disabled});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Text(title ?? "Nothing here yet", style: TextStyle(fontSize: 18, color: context.textColor)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: TextStyle(fontSize: 14, color: context.textColor)),
          ],
        ],
      ),
    );
  }
}

