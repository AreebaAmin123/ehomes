import 'package:dio/dio.dart';
import '../models/chat/support_conversation_model.dart';
import '../models/chat/support_message_model.dart';
import 'client/api_client.dart';

class SupportChatService {
  final ApiClient _apiClient = ApiClient();

  /// Create or get a support conversation
  Future<SupportConversationModel?> createOrGetSupportConversation(
      int customerId) async {
    try {
      final response = await _apiClient.get(
        '/chat/create_or_get_support_conversation.php',
        queryParams: {'customer_id': customerId.toString()},
      );
      if (response != null &&
          response['success'] == true &&
          response['conversation'] != null) {
        return SupportConversationModel.fromJson(response['conversation']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get support messages for a conversation
  Future<List<SupportMessageModel>> getSupportMessages(
      int conversationId) async {
    try {
      final response = await _apiClient.get(
        '/chat/get_support_messages.php',
        queryParams: {'conversation_id': conversationId.toString()},
      );
      if (response != null &&
          response['success'] == true &&
          response['messages'] != null) {
        return (response['messages'] as List)
            .map((msg) => SupportMessageModel.fromJson(msg))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Send a support message (file optional)
  Future<Map<String, dynamic>?> sendSupportMessage({
    required int conversationId,
    required int senderId,
    required String message,
    String senderType = 'customer',
    String? filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'conversation_id': conversationId.toString(),
        'sender_id': senderId.toString(),
        'sender_type': senderType,
        'message': message,
      });
      if (filePath != null && filePath.isNotEmpty) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(filePath),
        ));
      }
      final response = await _apiClient.post(
        '/chat/send_support_message.php',
        formData,
      );
      return response;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
