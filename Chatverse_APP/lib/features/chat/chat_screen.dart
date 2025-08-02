import 'package:flutter/material.dart';
import '../media/attachment_picker.dart';
import '../media/media_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat.dart';
import '../auth/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String receiverId;
  final String chatId;
  final String contactName;
  final String contactAvatar;
  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.chatId,
    required this.contactName,
    required this.contactAvatar,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isTyping = false;
  bool _showEmojiPicker = false;
  bool _loading = false;
  MediaType? _selectedMediaType;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
  }

  void _onMessageChanged(String value) {
    setState(() {
      _isTyping = value.trim().isNotEmpty;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    await ref.read(chatProvider).sendMessage(
      chatId: widget.chatId,
      receiverId: widget.receiverId,
      text: _messageController.text.trim(),
      type: MessageType.text,
    );
    _messageController.clear();
    setState(() {
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      StreamProvider((_) => ref.read(chatProvider).messagesStream(widget.chatId)),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              backgroundImage: widget.contactAvatar.isNotEmpty ? NetworkImage(widget.contactAvatar) : null,
              child: widget.contactAvatar.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contactName, style: Theme.of(context).textTheme.titleMedium),
                Text('Online', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final showDate = index == messages.length - 1 ||
                        msg.timestamp.toDate().day != messages[index == messages.length - 1 ? index : index + 1].timestamp.toDate().day;
                    return Column(
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _formatDate(msg.timestamp.toDate()),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
                            ),
                          ),
                        Align(
                          alignment: msg.senderId == ref.read(authProvider)?.uid
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: _ChatBubbleFirestore(msg: msg),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  const CircleAvatar(radius: 12, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 14)),
                  const SizedBox(width: 8),
                  Text('Typing...', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: Center(child: Text('Emoji Picker (coming soon)')),
            ),
          if (_selectedMediaType != null && _selectedFileName != null)
            MediaPreview(
              type: _selectedMediaType!,
              fileName: _selectedFileName!,
              onRemove: () {
                setState(() {
                  _selectedMediaType = null;
                  _selectedFileName = null;
                });
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () async {
                    final type = await AttachmentPicker.show(context);
                    if (type != null) {
                      setState(() {
                        _selectedMediaType =
                          type == 'image' ? MediaType.image :
                          type == 'file' ? MediaType.file :
                          MediaType.audio;
                        _selectedFileName = 'sample_${type}_file';
                      });
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: _onMessageChanged,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide.none),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 4),
                _isTyping
                    ? FilledButton(
                        onPressed: _sendMessage,
                        style: FilledButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.send, size: 20),
                      )
                    : IconButton(
                        icon: const Icon(Icons.mic),
                        onPressed: () {
                          // TODO: Voice message
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format as Today, Yesterday, or dd MMM yyyy
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_monthName(date.month)} ${date.year}';
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

class _ChatBubbleFirestore extends StatelessWidget {
  final MessageModel msg;
  const _ChatBubbleFirestore({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isMe = msg.senderId == '';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.shade200,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(msg.text, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TimeOfDay.fromDateTime(msg.timestamp.toDate()).format(context),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(width: 4),
              if (isMe)
                Icon(
                  msg.status == MessageStatus.read
                      ? Icons.done_all
                      : msg.status == MessageStatus.delivered
                          ? Icons.done
                          : Icons.access_time,
                  size: 16,
                  color: msg.status == MessageStatus.read
                      ? Colors.blue
                      : Colors.grey,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

enum MessageStatus { sent, delivered, read }

class _Message {
  final String text;
  final bool sentByMe;
  final String time;
  final String date;
  final MessageStatus status;
  _Message({
    required this.text,
    required this.sentByMe,
    required this.time,
    required this.date,
    required this.status,
  });
} 