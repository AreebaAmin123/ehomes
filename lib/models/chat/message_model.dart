class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String message;
  final String? fileUrl;
  final String timestamp;
  final String senderType;
  final String senderName;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    this.fileUrl,
    required this.timestamp,
    required this.senderType,
    required this.senderName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      message: json['message'] ?? '',
      fileUrl: json['file_url'],
      timestamp: json['created_at'] ?? '',
      senderType: json['sender_type'] ?? '',
      senderName: json['sender_name'] ?? '',
    );
  }
}
