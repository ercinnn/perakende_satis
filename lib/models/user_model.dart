// lib/models/user_model.dart

class UserModel {
  final String id;
  final String email;

  UserModel({
    required this.id,
    required this.email,
  });

  factory UserModel.fromSupabase(dynamic user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
    );
  }
}
