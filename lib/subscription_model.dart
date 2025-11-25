class SubscriptionModel {
  final String packageName;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String status;

  SubscriptionModel({
    required this.packageName,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.status,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      packageName: json['packageName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      price: (json['price'] as num).toDouble(), // Handle both int and double
      status: json['status'],
    );
  }
}
