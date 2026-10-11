import 'package:oms_app/app/app_pkg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutAlertDialog extends StatelessWidget {
  const LogoutAlertDialog({super.key});

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
              color: Color(0xFFFC660F),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'log_out',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const .all(16),
            child: Text(
              'are_you_sure_you_want_to_log_out',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),

          // Actions
          Row(
            mainAxisAlignment: .spaceAround,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel', style: TextStyle(color: Colors.grey)),
              ),
              Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () {
                      // Perform logout action here
                      Navigator.pop(context);
                      // ref.read(authNotifierProvider.notifier).logout();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFC660F)),
                    child: Text('submit', style: context.textTheme.bodyLarge!.copyWith(color: Colors.white)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
