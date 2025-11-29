import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/chat/message_model.dart';
import 'chats_screen.dart';
import 'provider/chat_provider.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    /// Load messages immediately when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final conversation = chatProvider.conversation;
      if (conversation != null) {
        chatProvider.loadMessages(conversationId: conversation.id).then((_) {
          /// Scroll to bottom after messages are loaded
          _scrollToBottom();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Listen to messages changes and scroll to bottom when new messages arrive
    final chatProvider = Provider.of<ChatProvider>(context);
    if (chatProvider.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final conversation = chatProvider.conversation;

    return WillPopScope(
      onWillPop: () async {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatsScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.unselectedTabColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.whiteColor),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatsScreen(),
                ),
              );
            },
          ),
          title: conversation != null
              ? Text(
                  conversation.vendorName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                )
              : Text("Chat", style: TextStyle(color: AppColors.whiteColor)),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: chatProvider.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48.sp,
                            color: AppColors.unselectedTabColor,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "No messages yet",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Start the conversation!",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.unselectedTabColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: chatProvider.messages.length,
                      reverse: false,
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                      itemBuilder: (context, index) {
                        final msg = chatProvider.messages[index];
                        final isUser = msg.senderType == 'user';
                        final bgColor = isUser
                            ? AppColors.primaryColor.withOpacity(0.85)
                            : AppColors.blueColor.withOpacity(0.9);
                        final align = isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start;
                        final radius = isUser
                            ? BorderRadius.only(
                                topLeft: Radius.circular(0.r),
                                topRight: Radius.circular(16.r),
                                bottomLeft: Radius.circular(16.r),
                              )
                            : BorderRadius.only(
                                topLeft: Radius.circular(16.r),
                                topRight: Radius.circular(0.r),
                                bottomRight: Radius.circular(16.r),
                              );
                        // final textColor = isUser ? AppColors.whiteColor : AppColors.blackColor;
                        final time = _formatTime(msg.timestamp);
                        final date = _formatDate(msg.timestamp);

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 6.h),
                          child: Column(
                            crossAxisAlignment: align,
                            children: [
                              Row(
                                mainAxisAlignment: isUser
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.h, horizontal: 14.w),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: radius,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: align,
                                        children: [
                                          Text(
                                            msg.message,
                                            style: TextStyle(
                                              color: AppColors.whiteColor,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                time,
                                                style: TextStyle(
                                                  color: AppColors.unselectedTabColor,
                                                  fontSize: 11.sp,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                date,
                                                style: TextStyle(
                                                  color: AppColors.unselectedTabColor,
                                                  fontSize: 11.sp,
                                                ),
                                              ),
                                              if (isUser) ...[
                                                SizedBox(width: 4.w),
                                                Icon(
                                                  msg.id == -1
                                                      ? Icons.access_time
                                                      : Icons.done_all,
                                                  size: 14.sp,
                                                  color: msg.id == -1
                                                      ? AppColors.unselectedTabColor
                                                      : AppColors.whiteColor,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: isUser ? 0 : 8.w,
                                  right: isUser ? 8.w : 0,
                                  top: 2.h,
                                ),
                                child: Text(
                                  msg.senderName,
                                  style: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.primaryColor,
                        size: 24.sp,
                      ),
                      onPressed: () {
                        // Handle image attachment
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.unselectedTabColor,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color: AppColors.unselectedTabColor!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              cursorColor: AppColors.lightGreyColor,
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                hintStyle: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 14.sp,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.send_rounded,
                                color: AppColors.whiteColor,
                                size: 18.sp,
                              ),
                              onPressed: () => _sendMessage(chatProvider),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(ChatProvider chatProvider) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    /// Clear text field immediately for better UX
    _controller.clear();

    // Add message optimistically
    final now = DateTime.now();
    final optimisticMessage = MessageModel(
      id: -1,
      // Temporary ID
      conversationId: chatProvider.conversation!.id,
      senderId: -1,
      // Will be updated from server
      message: text,
      fileUrl: null,
      timestamp: now.toIso8601String(),
      senderType: 'user',
      senderName: 'You', // Temporary name
    );

    // Add message to list immediately
    chatProvider.addOptimisticMessage(optimisticMessage);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Send message to server
    try {
      final sent = await chatProvider.sendMessage(message: text);
      if (!sent) {
        // Handle send failure
        chatProvider.removeOptimisticMessage(optimisticMessage);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message. Please try again.'),
              backgroundColor: AppColors.redColor,
              action: SnackBarAction(
                label: 'Retry',
                textColor: AppColors.whiteColor,
                onPressed: () => _sendMessage(chatProvider),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Handle error
      chatProvider.removeOptimisticMessage(optimisticMessage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message. Please try again.'),
            backgroundColor: AppColors.redColor,
          ),
        );
      }
    }
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'pm' : 'am';
      return '$hour:$minute $ampm';
    } catch (_) {
      return '';
    }
  }

  String _formatDate(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final weekday =
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dt.weekday - 1];
      return '$weekday-${dt.day.toString().padLeft(2, '0')}-${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
