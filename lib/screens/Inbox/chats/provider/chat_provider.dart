import 'package:flutter/material.dart';
import 'package:e_Home_app/services/chat_service.dart';
import 'package:e_Home_app/models/chat/conversation_model.dart';
import 'package:e_Home_app/models/chat/message_model.dart';
import 'package:e_Home_app/Utils/constants/my_sharePrefs.dart';
import 'dart:convert';
import 'package:e_Home_app/models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  bool _isLoading = false;
  String? _error;
  ConversationModel? _conversation;
  List<MessageModel> _messages = [];
  List<ConversationModel> _recentConversations = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ConversationModel? get conversation => _conversation;
  List<MessageModel> get messages => _messages;
  List<ConversationModel> get recentConversations => _recentConversations;

  Future<int?> getUserIdFromPrefs() async {
    final prefs = MySharedPrefs();
    String? userData = await prefs.getUserData();
    if (userData != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userData));
        print('Fetched user id from prefs: \\${user.id}');
        return user.id;
      } catch (e) {
        print('Error parsing user data: \\${e.toString()}');
        return null;
      }
    }
    print('No user data found in prefs');
    return null;
  }

  /// Add or update a conversation in the recent conversations list
  void addOrUpdateConversation(ConversationModel conversation) {
    // Remove any existing conversation with the same ID
    _recentConversations.removeWhere((c) => c.id == conversation.id);
    // Add the new/updated conversation at the top
    _recentConversations.insert(0, conversation);
    notifyListeners();
  }

  /// Start or load a conversation, and load messages if exists
  Future<void> loadOrStartConversation({
    required int userId,
    required int vendorId,
  }) async {
    _isLoading = true;
    _error = null;
    _conversation = null;
    _messages = [];
    notifyListeners();

    if (userId <= 0 || vendorId <= 0) {
      _error = "Invalid user or vendor information.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      debugPrint(
          "Loading/Starting conversation for user: $userId and vendor: $vendorId");
      // Try to get existing conversation
      final conv = await _chatService.getConversation(userId, vendorId);
      if (conv != null) {
        debugPrint("Found existing conversation: ${conv.id}");
        addOrUpdateConversation(conv);
        _conversation = conv;
        await loadMessages(conversationId: conv.id);
      } else {
        debugPrint("No existing conversation found, starting new one");
        // Start a new conversation
        final newConv = await _chatService.startConversation(userId, vendorId);
        if (newConv != null) {
          debugPrint("Started new conversation: ${newConv.id}");
          addOrUpdateConversation(newConv);
          _conversation = newConv;
          _messages = [];
        } else {
          _error = "Could not start a new conversation.";
        }
      }
    } catch (e) {
      debugPrint("Error in loadOrStartConversation: $e");
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Load messages for a conversation
  Future<void> loadMessages({
    required int conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("Loading messages for conversation: $conversationId");

      // Try multiple times with a small delay to ensure we get the latest message
      int retryCount = 0;
      List<MessageModel> msgs = [];

      while (retryCount < 2) {
        msgs = await _chatService.getMessages(
          conversationId: conversationId,
          limit: limit,
          offset: offset,
        );

        // If we got messages and the latest message matches what we expect, break
        if (msgs.isNotEmpty &&
            _conversation != null &&
            msgs.any((msg) => msg.message == _conversation!.lastMessage)) {
          break;
        }

        // Wait a short moment before retrying
        await Future.delayed(Duration(milliseconds: 500));
        retryCount++;
      }

      debugPrint("Loaded ${msgs.length} messages");
      // Sort messages by timestamp to ensure correct order
      msgs.sort((a, b) =>
          DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));
      _messages = msgs;
    } catch (e) {
      debugPrint("Error loading messages: $e");
      _error = e.toString();
      _messages = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Send a message (sender_id always from shared prefs)
  Future<bool> sendMessage({
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

    final senderId = await getUserIdFromPrefs();
    UserModel? user;
    final prefs = MySharedPrefs();
    String? userData = await prefs.getUserData();
    if (userData != null) {
      try {
        user = UserModel.fromJson(jsonDecode(userData));
      } catch (_) {}
    }
    if (senderId == null || user == null) {
      _error = "User not logged in. Please log in again.";
      print('Cannot send message: senderId is null');
      notifyListeners();
      return false;
    }

    // Create optimistic message with pending state
    final optimisticMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch *
          -1, // Unique temporary negative ID
      conversationId: _conversation!.id,
      senderId: senderId,
      message: message,
      fileUrl: null,
      timestamp: DateTime.now().toIso8601String(),
      senderType: 'user',
      senderName: user.name,
    );

    try {
      // Replace any existing optimistic messages for this text to prevent duplicates
      _messages =
          _messages.where((m) => m.id >= 0 || m.message != message).toList();
      // Add the new optimistic message
      _messages = [..._messages, optimisticMessage];
      notifyListeners();

      // Send message to server
      final response = await _chatService.sendMessage(
        conversationId: _conversation!.id,
        senderId: senderId,
        senderType: 'user',
        message: message,
        filePath: filePath,
      );
      print('Send message API response: ${response.toString()}');

      if (response != null && response['success'] != null) {
        // Fetch updated conversation to get new last_message and last_updated
        final updatedConv = await _chatService.getConversation(
          _conversation!.userId,
          _conversation!.vendorId,
        );

        if (updatedConv != null) {
          _conversation = updatedConv;

          // Update in recent conversations list, preventing duplicates
          final existingIndex =
              _recentConversations.indexWhere((c) => c.id == updatedConv.id);
          if (existingIndex != -1) {
            _recentConversations.removeAt(existingIndex);
          }
          _recentConversations.insert(0, updatedConv);
        }

        // Refresh messages with a delay to ensure server sync
        await Future.delayed(Duration(milliseconds: 500));

        // Load new messages
        final serverMessages = await _chatService.getMessages(
          conversationId: _conversation!.id,
          limit: 50,
          offset: 0,
        );

        // Remove any optimistic messages that have been confirmed
        final confirmedMessageTexts =
            serverMessages.map((m) => m.message).toSet();
        _messages = [
          ...serverMessages,
          ..._messages.where((m) =>
                  m.id < 0 && // Only keep optimistic messages
                  !confirmedMessageTexts
                      .contains(m.message) // That haven't been confirmed
              ),
        ];

        // Ensure no duplicates by message content and timestamp
        final seen = <String>{};
        _messages = _messages.where((message) {
          final key = '${message.message}_${message.timestamp}';
          final isUnique = !seen.contains(key);
          seen.add(key);
          return isUnique;
        }).toList();

        // Sort messages to ensure correct order
        _messages.sort((a, b) =>
            DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

        notifyListeners();
        return true;
      } else {
        _error = response?['error'] ?? "Failed to send message.";
        // Remove failed optimistic message
        _messages =
            _messages.where((m) => m.id != optimisticMessage.id).toList();
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      // Remove failed optimistic message
      _messages = _messages.where((m) => m.id != optimisticMessage.id).toList();
      notifyListeners();
      return false;
    }
  }

  /// Clear chat state
  void clearChat() {
    _conversation = null;
    _error = null;
    _messages = [];
    _isLoading = false;
    notifyListeners();
  }

  void setConversation(ConversationModel conversation) {
    // Remove any existing conversation with the same ID
    _recentConversations.removeWhere((c) => c.id == conversation.id);
    // Add/update the conversation
    _conversation = conversation;
    _recentConversations.insert(0, conversation);
    notifyListeners();
  }

  /// Fetch recent conversations for the user
  Future<void> fetchRecentConversations(int userId, {int? vendorId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint(
          "Fetching conversations for user: $userId${vendorId != null ? " and vendor: $vendorId" : ""}");
      final conversations =
          await _chatService.getConversations(userId, vendorId: vendorId);
      debugPrint("Received ${conversations.length} conversations");

      if (conversations.isEmpty) {
        _error = "No conversations found";
      } else {
        _recentConversations = conversations;
      }
    } catch (e) {
      debugPrint("Error in fetchRecentConversations: $e");
      _error = e.toString().replaceAll('Exception: ', '');
      _recentConversations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all conversations for a user by iterating over vendor IDs
  Future<void> fetchAllUserConversations(
      int userId, List<int> vendorIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final conversations =
          await _chatService.getAllUserConversations(userId, vendorIds);
      _recentConversations = conversations;
    } catch (e) {
      _error = e.toString();
      _recentConversations = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // Optimistic message handling
  void addOptimisticMessage(MessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  void removeOptimisticMessage(MessageModel message) {
    _messages.removeWhere((m) => m.id == message.id);
    notifyListeners();
  }

  void updateOptimisticMessage(
      MessageModel oldMessage, MessageModel newMessage) {
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
}
