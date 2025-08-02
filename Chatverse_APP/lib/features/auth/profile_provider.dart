import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_model.dart';
import 'auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

final profileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (doc.exists) {
    return UserModel.fromMap(doc.data()!);
  }
  return null;
});

final profileControllerProvider = Provider((ref) => ProfileController(ref));

class ProfileController {
  final Ref ref;
  ProfileController(this.ref);

  Future<void> updateProfile({required String name, required String about, String? avatarUrl}) async {
    final user = ref.read(authProvider);
    if (user == null) return;
    final data = <String, dynamic>{
      'name': name,
      'about': about,
    };
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(data);
  }

  Future<String?> uploadAvatar() async {
    final user = ref.read(authProvider);
    if (user == null) return null;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return null;
    final storageRef = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');
    await storageRef.putData(await picked.readAsBytes());
    final url = await storageRef.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'avatarUrl': url});
    return url;
  }
} 