import 'package:hive/hive.dart';

part 'support_conversation_model.g.dart';

@HiveType(typeId: 20)
class SupportConversationModel extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String customerName;
  @HiveField(2)
  final String adminName;

  SupportConversationModel({
    required this.id,
    required this.customerName,
    required this.adminName,
  });

  factory SupportConversationModel.fromJson(Map<String, dynamic> json) {
    return SupportConversationModel(
      id: json['id'],
      customerName: json['customer_name'] ?? '',
      adminName: json['admin_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'admin_name': adminName,
    };
  }
}
