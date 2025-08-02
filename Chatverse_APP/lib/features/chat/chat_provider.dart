import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_provider.dart';
import 'message_model.dart';
import '../auth/user_model.dart';

final chatProvider = Provider((ref) => ChatController(ref));

class ChatController {
  final Ref ref;
  ChatController(this.ref);

  Stream<List<MessageModel>> messagesStream(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
    MessageType type = MessageType.text,
    String mediaUrl = '',
  }) async {
    final user = ref.read(authProvider);
    if (user == null) return;
    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatSnapshot = await chatDoc.get();
    if (!chatSnapshot.exists) {
      await chatDoc.set({
        'id': chatId,
        'participants': [user.uid, receiverId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
    final msg = MessageModel(
      id: '',
      chatId: chatId,
      senderId: user.uid,
      receiverId: receiverId,
      text: text,
      type: type,
      timestamp: Timestamp.now(),
      status: MessageStatus.sent,
      mediaUrl: mediaUrl,
    );
    await chatDoc.collection('messages').add(msg.toMap());
    await chatDoc.update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> recentChatsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
} 