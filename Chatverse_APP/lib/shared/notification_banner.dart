import 'package:flutter/material.dart';

class NotificationBanner {
  static void show(BuildContext context, String message, {IconData? icon, Color? color}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null)
            Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
          if (icon != null) const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 4,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
} 