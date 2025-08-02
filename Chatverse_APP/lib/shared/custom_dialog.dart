import 'package:flutter/material.dart';

class CustomDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    required List<Widget> actions,
    IconData? icon,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            if (icon != null) Icon(icon, size: 28),
            if (icon != null) const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(content),
        actions: actions,
      ),
    );
  }
} 