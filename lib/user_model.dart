class User {
  final String userId;
  final String username;
  final String email;
  final String token;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
    );
  }
}
