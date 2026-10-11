import 'package:oms_shared/app/app_pkg.dart';
import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onTap;

  const SuccessDialog({super.key, required this.title, required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: .zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const .all(16),
            decoration: BoxDecoration(
              color: Colors.green, // Use green for success
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const .all(16),
            child: Text(message, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ),

          // Action
          Padding(
            padding: const .symmetric(vertical: 8, horizontal: 20),
            child: Row(
              mainAxisAlignment: .end,
              children: [
                ElevatedButton(
                  onPressed: onTap ?? () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Consistent success color
                  ),
                  child: Text('ok', style: context.textTheme.bodyLarge!.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
