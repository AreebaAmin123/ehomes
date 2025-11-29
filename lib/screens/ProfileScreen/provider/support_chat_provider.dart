import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../models/chat/support_conversation_model.dart';
import '../../../models/chat/support_message_model.dart';
import '../../../services/support_chat_service.dart';

class SupportChatProvider extends ChangeNotifier {
  final SupportChatService _supportChatService = SupportChatService();

  bool _isLoading = false;
  String? _error;
  SupportConversationModel? _conversation;
  List<SupportMessageModel> _messages = [];

  // Hive box names
  static const String conversationBox = 'support_conversation_box';
  static const String messagesBoxPrefix = 'support_messages_box_';

  bool get isLoading => _isLoading;
  String? get error => _error;
  SupportConversationModel? get conversation => _conversation;
  List<SupportMessageModel> get messages => _messages;

  // Optimistic message handling
  void addOptimisticMessage(SupportMessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  void removeOptimisticMessage(SupportMessageModel message) {
    _messages.removeWhere((m) => m.id == message.id);
    notifyListeners();
  }

  void updateOptimisticMessage(
      SupportMessageModel oldMessage, SupportMessageModel newMessage) {
    final index = _messages.indexWhere((m) => m.id == oldMessage.id);
    if (index != -1) {
      _messages[index] = newMessage;
      notifyListeners();
    }
  }

  // Clear messages
  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load or create a support conversation
  Future<void> loadOrCreateSupportConversation(int customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Try to load from Hive first
      final box = await Hive.openBox(conversationBox);
      final cached = box.get(customerId);
      if (cached != null) {
        _conversation = cached as SupportConversationModel;
      }
      // Always try to get latest from API
      final conv =
          await _supportChatService.createOrGetSupportConversation(customerId);
      if (conv != null) {
        _conversation = conv;
        box.put(customerId, conv);
      } else if (_conversation == null) {
        _error = 'Could not load support conversation.';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Load messages for a support conversation
  Future<void> loadSupportMessages(int conversationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Try to load from Hive first
      final box =
          await Hive.openBox(messagesBoxPrefix + conversationId.toString());
      final cached = box.values.cast<SupportMessageModel>().toList();
      if (cached.isNotEmpty) {
        _messages = cached;
      }
      // Always try to get latest from API
      final msgs = await _supportChatService.getSupportMessages(conversationId);
      if (msgs.isNotEmpty) {
        _messages = msgs;
        await box.clear();
        for (var msg in msgs) {
          await box.add(msg);
        }
      } else if (_messages.isEmpty) {
        _error = 'No messages found.';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Send a support message
  Future<bool> sendSupportMessage({
    required int senderId,
    required String message,
    String? filePath,
  }) async {
    if (_conversation == null) {
      _error = "No active conversation.";
      notifyListeners();
      return false;
    }
    if (message.trim().isEmpty) {
      _error = "Message cannot be empty.";
      notifyListeners();
      return false;
    }

    try {
      final response = await _supportChatService.sendSupportMessage(
        conversationId: _conversation!.id,
        senderId: senderId,
        senderType: 'customer',
        message: message,
        filePath: filePath,
      );

      if (response != null && response['success'] != null) {
        // Find and update the temporary message
        final messageId = response['message_id'] ?? 0;
        final index = _messages.indexWhere((m) => m.id == -1);

        if (index != -1) {
          // Replace temporary message with confirmed message
          final confirmed = SupportMessageModel(
            id: messageId,
            senderType: 'customer',
            senderId: senderId,
            message: message,
            fileUrl: null,
            createdAt: DateTime.now().toIso8601String(),
            senderName: 'You',
          );
          _messages[index] = confirmed;
          // Save to Hive
          final box = await Hive.openBox(
              messagesBoxPrefix + _conversation!.id.toString());
          await box.add(confirmed);
          notifyListeners();
        }
        return true;
      } else {
        _error = response?['error'] ?? "Failed to send message.";
        // Remove temporary message on failure
        _messages.removeWhere((m) => m.id == -1);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      // Remove temporary message on error
      _messages.removeWhere((m) => m.id == -1);
      notifyListeners();
      return false;
    }
  }
}
