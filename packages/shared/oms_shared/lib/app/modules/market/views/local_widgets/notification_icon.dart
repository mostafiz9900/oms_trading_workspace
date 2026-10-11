

import '/app/app_pkg.dart';
import 'package:flutter/material.dart';


class NotificationIcon extends StatelessWidget {
  final int notificationCount;
  final VoidCallback onTap;

  const NotificationIcon({super.key, required this.notificationCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 🔔 Notification Icon Button
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, size: 30, color: context.textColor),
          onPressed: onTap,
        ),

        // 🔴 Notification Count Badge
        if (notificationCount > 0)
          Positioned(
            right: 6,
            top: 4,
            child: Container(
              padding: const .all(2),
              decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$notificationCount',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
