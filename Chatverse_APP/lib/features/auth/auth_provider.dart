import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

final authProvider = StateNotifierProvider<AuthController, User?>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthController() : super(FirebaseAuth.instance.currentUser) {
    _auth.authStateChanges().listen((user) => state = user);
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password, {String? name}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (name != null) {
      final user = cred.user;
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          name: name,
          email: user.email ?? '',
          about: 'Hey there! I am using ChatVerse.',
          avatarUrl: '',
        );
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = null;
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In failed: $e');
    }
  }

  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
}
