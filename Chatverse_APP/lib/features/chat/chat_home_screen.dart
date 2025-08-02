import 'package:flutter/material.dart';
import '../auth/profile_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatverse/features/auth/auth_provider.dart';
import 'package:chatverse/features/chat/chat_screen.dart';

class ChatHomeScreen extends ConsumerStatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  ConsumerState<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends ConsumerState<ChatHomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        const _ChatsTab(),
        const _GroupsTab(),
        const _ProfileTab(),
      ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) {
      // Optionally, show a loading indicator or redirect to login
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatVerse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              // TODO: New chat
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selectedUser = await showDialog<UserModel?>(
            context: context,
            builder: (context) => _UserSearchDialog(currentUid: user.uid),
          );
          if (selectedUser != null) {
            final chatId = [user.uid, selectedUser.uid]..sort();
            final chatIdStr = chatId.join('_');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  receiverId: selectedUser.uid,
                  chatId: chatIdStr,
                  contactName: selectedUser.name,
                  contactAvatar: selectedUser.avatarUrl,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.edit),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ChatsTab extends ConsumerWidget {
  const _ChatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder chat list with mock data
    final user = ref.watch(authProvider);
    final List<Map<String, dynamic>> chats = List.generate(10, (index) => {
      'id': 'chat_${index + 1}',
      'otherId': 'user_${index + 100}',
      'contact': {
        'name': 'Contact ${index + 1}',
        'avatarUrl': '',
      },
    });
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chats.length,
      separatorBuilder: (_, __) => const Divider(indent: 72),
      itemBuilder: (context, index) {
        final chat = chats[index];
        final contact = chat['contact'];
        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 28),
          ),
          title: Text(contact['name']),
          subtitle: Text('Last message preview...'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('12:3$index'),
              if (index % 3 == 0)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  receiverId: chat['otherId'],
                  chatId: chat['id'],
                  contactName: contact['name'],
                  contactAvatar: contact['avatarUrl'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _GroupsTab extends StatelessWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context) {
    // Placeholder group list
    return Center(
      child: Text('Groups tab (coming soon)', style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    // Button to open profile screen
    return Center(
      child: FilledButton.icon(
        onPressed: () => Navigator.of(context).pushNamed('/profile'),
        icon: const Icon(Icons.person),
        label: const Text('Open Profile'),
      ),
    );
  }
}

class _UserSearchDialog extends StatefulWidget {
  final String currentUid;
  const _UserSearchDialog({required this.currentUid});

  @override
  State<_UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<_UserSearchDialog> {
  String _query = '';
  List<UserModel> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    setState(() => _loading = true);
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: _query)
        .where('name', isLessThanOrEqualTo: _query + '\uf8ff')
        .get();
    _results = snap.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((u) => u.uid != widget.currentUid)
        .toList();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Chat'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(hintText: 'Search by name'),
            onChanged: (v) => _query = v,
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          if (_loading) const CircularProgressIndicator(),
          if (!_loading)
            ..._results.map((user) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                    child: user.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () => Navigator.of(context).pop(user),
                )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
} 