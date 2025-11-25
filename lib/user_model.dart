import './subscription_model.dart';

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
  SubscriptionModel? subscription;

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
    this.subscription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      username: json['username'],
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      email: json['email'],
      phone: json['phone'],
      playlistUrl: json['playlist_url'],
      token: json['token'],
      balance: double.parse(json['balance'].toString()),
      userstatus: json['userstatus'] != null ? int.parse(json['userstatus'].toString()) : 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      chatId: json['chat_id'] != null ? int.parse(json['chat_id'].toString()) : null,
      subscription: json['subscription'] != null ? SubscriptionModel.fromJson(json['subscription']) : null,
    );
  }

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    double? balance,
    SubscriptionModel? subscription,
    String? token,
  }) {
    return UserModel(
      id: id,
      username: username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      subscription: subscription ?? this.subscription,
      token: token ?? this.token,
      playlistUrl: playlistUrl,
      userstatus: userstatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      chatId: chatId,
    );
  }
}
