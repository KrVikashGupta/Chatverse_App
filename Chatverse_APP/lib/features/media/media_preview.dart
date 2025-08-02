import 'package:flutter/material.dart';

enum MediaType { image, file, audio }

class MediaPreview extends StatelessWidget {
  final MediaType type;
  final String fileName;
  final VoidCallback onRemove;
  const MediaPreview({
    super.key,
    required this.type,
    required this.fileName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    switch (type) {
      case MediaType.image:
        icon = Icons.image;
        label = 'Image';
        break;
      case MediaType.file:
        icon = Icons.insert_drive_file;
        label = 'File';
        break;
      case MediaType.audio:
        icon = Icons.audiotrack;
        label = 'Audio';
        break;
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 36),
        title: Text(label),
        subtitle: Text(fileName),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ),
    );
  }
} 