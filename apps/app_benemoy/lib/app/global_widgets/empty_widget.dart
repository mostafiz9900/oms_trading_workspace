import 'package:app_benemoy/app/app_pkg.dart';
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
          // Icon(icon, size: 48, color: context.textColor),
          // const SizedBox(height: 12),
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

class EmptyWidget2 extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyWidget2({super.key, required this.message, this.buttonText, this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.list_alt, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onButtonPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
