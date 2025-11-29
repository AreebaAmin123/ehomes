import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/chat/conversation_model.dart';
import 'inbox_screen.dart';
import 'provider/chat_provider.dart';

class ChatsScreen extends StatefulWidget {
  final int? vendorId;
  final int? userId;

  const ChatsScreen({super.key, this.vendorId, this.userId});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late BuildContext _stableContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stableContext = context;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final userId = widget.userId ?? await chatProvider.getUserIdFromPrefs();
      debugPrint("ChatsScreen - User ID: $userId");

      // Use only real vendor IDs that exist in your backend for now
      final vendorIds = [5]; // Update this list as more vendors are added

      if (userId != null) {
        await chatProvider.fetchAllUserConversations(userId, vendorIds);

        // If vendor ID is provided, navigate to that conversation
        if (widget.vendorId != null) {
          debugPrint(
              "ChatsScreen - Loading conversation with vendor: ${widget.vendorId}");
          await chatProvider.loadOrStartConversation(
            userId: userId,
            vendorId: widget.vendorId!,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: chatProvider,
                child: InboxScreen(),
              ),
            ),
          );
        }
      } else {
        debugPrint("ChatsScreen - No user ID available");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please log in to view conversations"),
            backgroundColor: AppColors.redColor,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.unselectedTabColor,
      appBar: AppBar(
        title: Text(
          'My Chats',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.whiteColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: chatProvider.isLoading

      /// shimmer loading effect
          ? ListView.builder(
              itemCount: 7,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackColor.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            color: AppColors.unselectedTabColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 120.w,
                                    height: 14.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.unselectedTabColor,
                                      borderRadius: BorderRadius.circular(7.r),
                                    ),
                                  ),
                                  Container(
                                    width: 50.w,
                                    height: 12.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.unselectedTabColor,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                width: 200.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: AppColors.unselectedTabColor,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )

      /// on error text
          : chatProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: AppColors.redColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        chatProvider.error!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.redColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () async {
                          final userId =
                              await chatProvider.getUserIdFromPrefs();
                          if (userId != null) {
                            await chatProvider
                                .fetchAllUserConversations(userId, [5]);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                        ),
                        child: Text(
                          "Retry",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                )
              : chatProvider.recentConversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64.sp,
                            color: AppColors.greyColor,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "No conversations yet",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Start chatting with vendors",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),
                    )

      /// fetch chats
                  : ListView.builder(
                      itemCount: chatProvider.recentConversations.length,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      itemBuilder: (context, index) {
                        final conv = chatProvider.recentConversations[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(15.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blackColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15.r),
                              onTap: () {
                                debugPrint("Tapped conversation: ${conv.id}");
                                _navigateToInbox(conv, chatProvider);
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16.r),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50.w,
                                      height: 50.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          conv.vendorName.isNotEmpty
                                              ? conv.vendorName[0].toUpperCase()
                                              : conv.userName[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                conv.vendorName.isNotEmpty
                                                    ? conv.vendorName
                                                    : conv.userName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.sp,
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                              Text(
                                                _getFormattedTime(
                                                    conv.lastUpdated),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: AppColors.greyColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            conv.lastMessage ??
                                                'No messages yet',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: AppColors.greyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Future<void> _navigateToInbox(ConversationModel conv, ChatProvider chatProvider) async {
    try {
      await chatProvider.loadOrStartConversation(
        userId: conv.userId,
        vendorId: conv.vendorId,
      );

      if (!mounted) return;

      // Navigate using stable context
      await Navigator.of(_stableContext).pushReplacement(
        MaterialPageRoute(
          builder: (context) => InboxScreen(),
        ),
      );
    } catch (e) {
      debugPrint("Error navigating to conversation: $e");
      if (!mounted) return;

      // Show error using stable context
      ScaffoldMessenger.of(_stableContext).showSnackBar(
        SnackBar(
          content: Text("Failed to open conversation. Please try again."),
          backgroundColor: AppColors.redColor,
        ),
      );
    }
  }

  String _getFormattedTime(String timestamp) {
    try {
      final now = DateTime.now();
      final dt = DateTime.parse(timestamp);
      final difference = now.difference(dt);

      if (difference.inDays > 7) {
        // More than a week ago, show date
        return '${dt.day}/${dt.month}/${dt.year}';
      } else if (difference.inDays > 0) {
        // Days ago
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        // Hours ago
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        // Minutes ago
        return '${difference.inMinutes}m ago';
      } else {
        // Just now
        return 'Just now';
      }
    } catch (_) {
      return '';
    }
  }
}
