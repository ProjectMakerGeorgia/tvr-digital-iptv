
class UserModel {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? playlistUrl;
  final String? token;
  final double balance;
  final int userstatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? chatId;

  UserModel({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.playlistUrl,
    this.token,
    required this.balance,
    required this.userstatus,
    required this.createdAt,
    required this.updatedAt,
    this.chatId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      playlistUrl: json['playlist_url'],
      token: json['token'],
      balance: double.parse(json['balance'].toString()),
      userstatus: json['userstatus'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      chatId: json['chat_id'],
    );
  }
}
