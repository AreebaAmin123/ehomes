import 'package:hive/hive.dart';

part 'support_message_model.g.dart';

@HiveType(typeId: 21)
class SupportMessageModel extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String senderType;
  @HiveField(2)
  final int senderId;
  @HiveField(3)
  final String message;
  @HiveField(4)
  final String? fileUrl;
  @HiveField(5)
  final String createdAt;
  @HiveField(6)
  final String senderName;

  SupportMessageModel({
    required this.id,
    required this.senderType,
    required this.senderId,
    required this.message,
    this.fileUrl,
    required this.createdAt,
    required this.senderName,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'],
      senderType: json['sender_type'],
      senderId: json['sender_id'],
      message: json['message'],
      fileUrl: json['file_url'],
      createdAt: json['created_at'],
      senderName: json['sender_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_type': senderType,
      'sender_id': senderId,
      'message': message,
      'file_url': fileUrl,
      'created_at': createdAt,
      'sender_name': senderName,
    };
  }
}
