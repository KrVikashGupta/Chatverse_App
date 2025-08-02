class UserModel {
  final String uid;
  final String name;
  final String email;
  final String about;
  final String avatarUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.about,
    required this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      about: map['about'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'about': about,
      'avatarUrl': avatarUrl,
    };
  }
} 