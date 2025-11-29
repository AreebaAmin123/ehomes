class ConversationModel {
  final int id;
  final int userId;
  final int vendorId;
  final String? lastMessage;
  final String lastUpdated;
  final String userName;
  final String vendorName;

  ConversationModel({
    required this.id,
    required this.userId,
    required this.vendorId,
    this.lastMessage,
    required this.lastUpdated,
    required this.userName,
    required this.vendorName,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      userId: json['user_id'],
      vendorId: json['vendor_id'],
      lastMessage: json['last_message'],
      lastUpdated: json['last_updated'],
      userName: json['user_name'] ?? '',
      vendorName: json['vendor_name'] ?? '',
    );
  }
}
