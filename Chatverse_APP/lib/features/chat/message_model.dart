import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file, audio }
enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final MessageType type;
  final Timestamp timestamp;
  final MessageStatus status;
  final String mediaUrl;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timestamp,
    required this.status,
    required this.mediaUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.values[map['type'] ?? 0],
      timestamp: map['timestamp'] ?? Timestamp.now(),
      status: MessageStatus.values[map['status'] ?? 0],
      mediaUrl: map['mediaUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.index,
      'timestamp': timestamp,
      'status': status.index,
      'mediaUrl': mediaUrl,
    };
  }
} 