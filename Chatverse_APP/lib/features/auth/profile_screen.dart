import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth.dart';
import '../../shared/custom_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _uploadAvatar(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await ref.read(profileControllerProvider).uploadAvatar();
      ref.refresh(profileProvider);
    } finally {
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  void _editProfile(BuildContext context, WidgetRef ref, UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final aboutController = TextEditingController(text: user.about);
    final result = await CustomDialog.show(
      context: context,
      title: 'Edit Profile',
      content: '',
      icon: Icons.edit,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await ref.read(profileControllerProvider).updateProfile(
              name: nameController.text.trim(),
              about: aboutController.text.trim(),
            );
            if (context.mounted) Navigator.of(context).pop(true);
          },
          child: const Text('Save'),
        ),
      ],
      // Custom content for dialog
    );
    // ignore: use_build_context_synchronously
    if (result == true) {
      ref.refresh(profileProvider);
    }
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No profile found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                        child: user.avatarUrl.isEmpty ? const Icon(Icons.person, size: 48) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: Theme.of(context).colorScheme.primary,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                            onPressed: () => _uploadAvatar(context, ref),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(user.about, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Dark Mode'),
                    Switch(
                      value: isDark,
                      onChanged: (val) {
                        // TODO: Implement theme toggle
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _openSettings(context),
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 