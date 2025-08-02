import 'package:flutter/material.dart';

class AttachmentPicker {
  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Image'),
            onTap: () => Navigator.of(context).pop('image'),
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: const Text('File'),
            onTap: () => Navigator.of(context).pop('file'),
          ),
          ListTile(
            leading: const Icon(Icons.mic_none_outlined),
            title: const Text('Audio'),
            onTap: () => Navigator.of(context).pop('audio'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 