import 'package:flutter/foundation.dart';
import 'client/api_client.dart';
import '../models/chat/conversation_model.dart';
import '../models/chat/message_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

/// 🔹 **Chat Service**
class ChatService {
  final ApiClient _apiClient = ApiClient();

  /// 🔹 **Get Conversation**
  Future<ConversationModel?> getConversation(int userId, int vendorId) async {
    try {
      debugPrint(
          "Fetching conversation for user: $userId and vendor: $vendorId");
      final response = await _apiClient.get(
        '/chat/get_conversation.php',
        queryParams: {
          'user_id': userId.toString(),
          'vendor_id': vendorId.toString(),
        },
      );
      debugPrint("Get Conversation Response: ${response.toString()}");

      if (response != null && response['success'] == true) {
        if (response['conversation'] != null) {
          return ConversationModel.fromJson(response['conversation']);
        } else {
          debugPrint("No conversation found in response");
          return null;
        }
      } else {
        final errorMessage = response?['error'] ?? 'Unknown error';
        debugPrint("API call unsuccessful: $errorMessage");
        return null;
      }
    } catch (e) {
      debugPrint("Error getting conversation: $e");
      return null;
    }
  }

  /// 🔹 **Start Conversation**
  Future<ConversationModel?> startConversation(int userId, int vendorId) async {
    try {
      debugPrint(
          "Starting conversation for user: $userId and vendor: $vendorId");
      final response = await _apiClient.post('/chat/start_conversation.php', {
        'user_id': userId.toString(),
        'vendor_id': vendorId.toString(),
      });
      debugPrint("Start Conversation Response: ${response.toString()}");

      if (response != null && response['success'] == true) {
        if (response['conversation_id'] != null) {
          // After starting, fetch the conversation details
          return await getConversation(userId, vendorId);
        } else {
          debugPrint("No conversation ID in response");
          return null;
        }
      } else {
        final errorMessage = response?['error'] ?? 'Unknown error';
        debugPrint("API call unsuccessful: $errorMessage");
        return null;
      }
    } catch (e) {
      debugPrint("Error starting conversation: $e");
      return null;
    }
  }

  /// 🔹 **Get Messages**
  Future<List<MessageModel>> getMessages({
    required int conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      List<MessageModel> allMessages = [];
      bool hasMoreMessages = true;
      int currentOffset = offset;
      int retryCount = 0;
      final maxRetries = 3;

      while (hasMoreMessages && retryCount < maxRetries) {
        final response = await _apiClient.get(
          '/chat/get_messages.php',
          queryParams: {
            'conversation_id': conversationId.toString(),
            'limit': limit.toString(),
            'offset': currentOffset.toString(),
            'order': 'desc', // Get newest messages first
          },
        );

        debugPrint("Get Messages Response: ${response.toString()}");

        if (response != null &&
            response['success'] == true &&
            response['messages'] != null) {
          final messages = (response['messages'] as List)
              .map((msg) => MessageModel.fromJson(msg))
              .toList();

          // Check if we got complete data
          if (messages.isNotEmpty && messages.last.senderName != null) {
            allMessages.addAll(messages);

            // If we got fewer messages than the limit, we've reached the end
            if (messages.length < limit) {
              hasMoreMessages = false;
            } else {
              currentOffset += limit;
            }
            retryCount = 0; // Reset retry count on success
          } else {
            // If data is incomplete, retry
            retryCount++;
            await Future.delayed(Duration(milliseconds: 500));
          }
        } else {
          retryCount++;
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      // Sort messages by timestamp in ascending order for display
      allMessages.sort((a, b) =>
          DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

      return allMessages;
    } catch (e) {
      debugPrint("Error getting messages: $e");
      return [];
    }
  }

  /// Send Message (multipart/form-data, file optional)
  Future<Map<String, dynamic>?> sendMessage({
    required int conversationId,
    required int senderId,
    required String message,
    String senderType = 'user', // default to 'user' for user messages
    String? filePath, // optional, local file path
  }) async {
    try {
      debugPrint("Sending message in conversation: $conversationId");

      // Create form data
      final formData = FormData.fromMap({
        'conversation_id': conversationId.toString(),
        'sender_id': senderId.toString(),
        'sender_type': senderType,
        'message': message,
      });

      // Add file if provided
      if (filePath != null && filePath.isNotEmpty) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(filePath),
        ));
      }

      final response = await _apiClient.post(
        '/chat/send_message.php',
        formData,
      );

      debugPrint("Send message API response: ${response.toString()}");

      // Check for success message in the response
      if (response != null && response['success'] == 'Message sent') {
        return {'success': true, 'message': 'Message sent successfully'};
      } else {
        return {'error': response?['error'] ?? 'Failed to send message'};
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
      return {'error': e.toString()};
    }
  }

  /// Fetch all recent conversations for a user
  Future<List<ConversationModel>> getConversations(int userId,
      {int? vendorId}) async {
    try {
      final Map<String, String> queryParams = {
        'user_id': userId.toString(),
      };

      // Add vendor_id if provided
      if (vendorId != null) {
        queryParams['vendor_id'] = vendorId.toString();
      }

      debugPrint("Making API call with params: $queryParams");

      final response = await _apiClient.get(
        '/chat/get_conversations.php',
        queryParams: queryParams,
      );
      debugPrint("Get Conversations Response: ${response.toString()}");

      if (response != null && response['success'] == true) {
        if (response['conversations'] != null &&
            response['conversations'] is List) {
          final List<dynamic> conversationsList = response['conversations'];
          debugPrint("Found ${conversationsList.length} conversations");

          final conversations = conversationsList
              .map((conversation) {
                try {
                  return ConversationModel.fromJson(conversation);
                } catch (e) {
                  debugPrint("Error parsing conversation: $e");
                  debugPrint("Problematic conversation data: $conversation");
                  return null;
                }
              })
              .whereType<ConversationModel>()
              .toList();

          // Sort conversations by last updated time
          conversations.sort((a, b) => DateTime.parse(b.lastUpdated)
              .compareTo(DateTime.parse(a.lastUpdated)));

          return conversations;
        } else {
          debugPrint("No conversations found in response");
          return [];
        }
      } else {
        final errorMessage = response?['error'] ?? 'Unknown error';
        debugPrint("API call unsuccessful: $errorMessage");
        throw Exception(errorMessage);
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint("API endpoint not found. Please check the endpoint URL.");
        throw Exception(
            "Chat service is currently unavailable. Please try again later.");
      }
      debugPrint("Dio error getting conversations: ${e.message}");
      throw Exception(
          "Failed to load conversations. Please check your internet connection.");
    } catch (e) {
      debugPrint("Error getting conversations: $e");
      throw Exception("An unexpected error occurred. Please try again.");
    }
  }

  /// Fetch all conversations for a user by iterating over vendor IDs
  Future<List<ConversationModel>> getAllUserConversations(
      int userId, List<int> vendorIds) async {
    List<ConversationModel> conversations = [];
    for (final vendorId in vendorIds) {
      final conv = await getConversation(userId, vendorId);
      if (conv != null) {
        conversations.add(conv);
      }
    }
    // Sort by last_updated descending
    conversations.sort((a, b) =>
        DateTime.parse(b.lastUpdated).compareTo(DateTime.parse(a.lastUpdated)));
    return conversations;
  }
}
