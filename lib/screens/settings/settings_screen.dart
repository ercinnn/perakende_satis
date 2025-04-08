class UserModel {
  final String id;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromSupabase(Map<String, dynamic> user) {
    return UserModel(
      id: user['id'],
      email: user['email'],
      createdAt: DateTime.parse(user['created_at']),
    );
  }
}