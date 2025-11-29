import 'package:e_Home_app/screens/Auth/email section/provider/email_authProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../provider/support_chat_provider.dart';
import '../../../Utils/constants/app_colors.dart';
import '../../../models/chat/support_message_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({Key? key}) : super(key: key);

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _customerId;
  String? _customerName;
  bool _isInitialLoading = true;
  bool _isSendingMessage = false;
  File? _selectedFile;
  bool _isUploadingFile = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider =
          Provider.of<EmailAuthProvider>(context, listen: false);
      await authProvider.loadUserSession();
      _customerId = authProvider.user?.id;
      _customerName = authProvider.user?.name ?? "You";

      if (_customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Please log in to use support chat"),
              backgroundColor: AppColors.redColor),
        );
        Navigator.pop(context);
        return;
      }

      final provider = Provider.of<SupportChatProvider>(context, listen: false);
      await provider.loadOrCreateSupportConversation(_customerId!);
      if (provider.conversation != null) {
        await provider.loadSupportMessages(provider.conversation!.id);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
      setState(() {
        _isInitialLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to message changes and scroll to bottom when new messages arrive
    final provider = Provider.of<SupportChatProvider>(context);
    if (provider.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(SupportChatProvider provider) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _customerId == null) return;

    setState(() {
      _isSendingMessage = true;
    });

    // Clear text field immediately for better UX
    _controller.clear();

    /// Add message optimistically
    final now = DateTime.now();
    final optimisticMessage = SupportMessageModel(
      id: -1,

      /// Temporary ID
      senderType: 'customer',
      senderId: _customerId!,
      message: text,
      fileUrl: null,
      createdAt: now.toIso8601String(),
      senderName: _customerName ?? 'You',
    );

    // Add message to list immediately
    provider.addOptimisticMessage(optimisticMessage);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Send message to server
    try {
      final sent = await provider.sendSupportMessage(
        senderId: _customerId!,
        message: text,
      );
      if (!sent) {
        // Handle send failure
        provider.removeOptimisticMessage(optimisticMessage);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message. Please try again.'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _sendMessage(provider),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Handle error
      provider.removeOptimisticMessage(optimisticMessage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  Future<void> _pickFileAndSend(SupportChatProvider provider) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _isUploadingFile = true;
      });
      // Optionally show a preview dialog before sending
      final shouldSend = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Send this file?'),
            content: _selectedFile != null && _isImage(_selectedFile!)
                ? Image.file(_selectedFile!, height: 120)
                : Text(_selectedFile!.path.split('/').last),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Send')),
            ],
          );
        },
      );
      if (shouldSend == true) {
        // Add an optimistic message for the file upload
        final now = DateTime.now();
        final optimisticMessage = SupportMessageModel(
          id: -1, // Temporary ID
          senderType: 'customer',
          senderId: _customerId!,
          message: '',
          fileUrl: _selectedFile!.path, // Use local path temporarily
          createdAt: now.toIso8601String(),
          senderName: _customerName ?? 'You',
        );
        provider.addOptimisticMessage(optimisticMessage);
        // Scroll to bottom immediately
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        // Send the file to the server
        await provider.sendSupportMessage(
          senderId: _customerId!,
          message: '',
          filePath: _selectedFile!.path,
        );
        setState(() {
          _selectedFile = null;
          _isUploadingFile = false;
        });
        // Ensure the UI is refreshed and scrolled to the bottom after sending
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
          provider.loadSupportMessages(provider.conversation!.id);
        });
      } else {
        setState(() {
          _isUploadingFile = false;
        });
      }
    }
  }

  bool _isImage(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  bool _isImageUrl(String url) {
    final ext = url.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldColor,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.whiteColor),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text('Customer Support',
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp)),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divider(
                  height: 1, thickness: 0.5, color: AppColors.greyColor),
            ),
          ),
          body: _isInitialLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: 16.h),
                      Text('Loading conversation...',
                          style: TextStyle(
                              color: AppColors.greyColor, fontSize: 14.sp)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Quick reply chips
                    if (!provider.isLoading && provider.messages.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        child: Wrap(
                          spacing: 8.w,
                          children: [
                            ActionChip(
                              label: Text('Thank you!',
                                  style:
                                      TextStyle(color: AppColors.primaryColor)),
                              onPressed: () => _controller.text = 'Thank you!',
                              backgroundColor: AppColors.lightGreenColor,
                            ),
                            ActionChip(
                              label: Text('Can you help me?',
                                  style:
                                      TextStyle(color: AppColors.primaryColor)),
                              onPressed: () =>
                                  _controller.text = 'Can you help me?',
                              backgroundColor: AppColors.lightGreenColor,
                            ),
                            ActionChip(
                              label: Text('I have an issue',
                                  style:
                                      TextStyle(color: AppColors.primaryColor)),
                              onPressed: () =>
                                  _controller.text = 'I have an issue',
                              backgroundColor: AppColors.lightGreenColor,
                            ),
                          ],
                        ),
                      ),
                    // Typing indicator (static for now)
                    if (!provider.isLoading && provider.messages.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: 16.w, bottom: 2.h),
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 10,
                                backgroundColor: AppColors.primaryColor,
                                child: Icon(Icons.support_agent,
                                    color: AppColors.whiteColor, size: 14)),
                            SizedBox(width: 8.w),
                            Text('Hi! How can we help you today?',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    // Chat list with sticky date headers and animated bubbles
                    Expanded(
                      child: provider.isLoading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CupertinoActivityIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text('Loading messages...',
                                      style: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 14.sp)),
                                ],
                              ),
                            )
                          : provider.messages.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_bubble_outline_rounded,
                                          size: 48.sp,
                                          color: AppColors.unselectedTabColor),
                                      SizedBox(height: 12.h),
                                      Text("No messages yet",
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color:
                                                  AppColors.unselectedTabColor,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(height: 8.h),
                                      Text("Start the conversation!",
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: AppColors
                                                  .unselectedTabColor)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  itemCount: provider.messages.length,
                                  reverse: false,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.h, horizontal: 8.w),
                                  itemBuilder: (context, index) {
                                    final msg = provider.messages[index];
                                    final isUser =
                                        msg.senderType == 'customer' &&
                                            msg.senderId == _customerId;
                                    final bgColor = isUser
                                        ? AppColors.primaryColor
                                            .withOpacity(0.85)
                                        : AppColors.blueColor.withOpacity(0.9);
                                    final align = isUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start;
                                    final radius = isUser
                                        ? BorderRadius.only(
                                            topLeft: Radius.circular(0.r),
                                            topRight: Radius.circular(16.r),
                                            bottomLeft: Radius.circular(16.r))
                                        : BorderRadius.only(
                                            topLeft: Radius.circular(16.r),
                                            topRight: Radius.circular(0.r),
                                            bottomRight: Radius.circular(16.r));
                                    final textColor =
                                        isUser ? Colors.white : Colors.black87;
                                    final time = _formatTime(msg.createdAt);
                                    final date = _formatDate(msg.createdAt);
                                    // Sticky date header
                                    final showDateHeader = index == 0 ||
                                        _formatDate(msg.createdAt) !=
                                            _formatDate(provider
                                                .messages[index - 1].createdAt);
                                    return Column(
                                      crossAxisAlignment: align,
                                      children: [
                                        if (showDateHeader)
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.h),
                                            child: Center(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 4.h),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryColor
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                ),
                                                child: Text(date,
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .primaryColor,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                            ),
                                          ),
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 350),
                                          curve: Curves.easeInOut,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6.h),
                                          child: Row(
                                            mainAxisAlignment: isUser
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              if (!isUser)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 8.w),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: Icon(
                                                        Icons.support_agent,
                                                        color: AppColors
                                                            .primaryColor),
                                                  ),
                                                ),
                                              // Chat bubble with tail
                                              Stack(
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10.h,
                                                            horizontal: 14.w),
                                                    decoration: BoxDecoration(
                                                      color: bgColor,
                                                      borderRadius: radius,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.05),
                                                          blurRadius: 5,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: align,
                                                      children: [
                                                        if (msg.fileUrl !=
                                                                null &&
                                                            msg.fileUrl!
                                                                .isNotEmpty)
                                                          _isImageUrl(
                                                                  msg.fileUrl!)
                                                              ? GestureDetector(
                                                                  onTap: () =>
                                                                      _showImagePreview(
                                                                          msg.fileUrl!),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.r),
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          msg.fileUrl!,
                                                                      height:
                                                                          120,
                                                                      width:
                                                                          120,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      placeholder: (context,
                                                                              url) =>
                                                                          const Center(
                                                                              child: CircularProgressIndicator(strokeWidth: 2)),
                                                                      errorWidget: (context, url, error) => Icon(
                                                                          Icons
                                                                              .broken_image,
                                                                          size:
                                                                              48,
                                                                          color:
                                                                              AppColors.greyColor),
                                                                    ),
                                                                  ),
                                                                )
                                                              : GestureDetector(
                                                                  onTap: () =>
                                                                      OpenFile.open(
                                                                          msg.fileUrl!),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .insert_drive_file,
                                                                          color:
                                                                              AppColors.primaryColor),
                                                                      SizedBox(
                                                                          width:
                                                                              6.w),
                                                                      Flexible(
                                                                        child:
                                                                            Text(
                                                                          msg.fileUrl!
                                                                              .split('/')
                                                                              .last,
                                                                          style: TextStyle(
                                                                              color: textColor,
                                                                              decoration: TextDecoration.underline),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                        if (msg
                                                            .message.isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 4.h),
                                                            child: Text(
                                                                msg.message,
                                                                style: TextStyle(
                                                                    color:
                                                                        textColor,
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                          ),
                                                        SizedBox(height: 4.h),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(time,
                                                                style: TextStyle(
                                                                    color: textColor
                                                                        .withOpacity(
                                                                            0.8),
                                                                    fontSize:
                                                                        11.sp)),
                                                            SizedBox(
                                                                width: 8.w),
                                                            if (isUser &&
                                                                msg.id == -1)
                                                              Tooltip(
                                                                message:
                                                                    'Sending...',
                                                                child: Icon(
                                                                    Icons
                                                                        .access_time,
                                                                    size: 14.sp,
                                                                    color: Colors
                                                                            .grey[
                                                                        400]),
                                                              ),
                                                            if (isUser &&
                                                                msg.id != -1)
                                                              Tooltip(
                                                                message:
                                                                    'Delivered',
                                                                child: Icon(
                                                                    Icons
                                                                        .done_all,
                                                                    size: 14.sp,
                                                                    color: textColor
                                                                        .withOpacity(
                                                                            0.8)),
                                                              ),
                                                            if (!isUser &&
                                                                msg.id == -2)
                                                              Tooltip(
                                                                message:
                                                                    'Failed to send',
                                                                child: Icon(
                                                                    Icons
                                                                        .error_outline,
                                                                    size: 14.sp,
                                                                    color: AppColors
                                                                        .redColor),
                                                              ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Bubble tail
                                                  Positioned(
                                                    bottom: 0,
                                                    left: isUser ? null : 8.w,
                                                    right: isUser ? 8.w : null,
                                                    child: CustomPaint(
                                                      painter:
                                                          _BubbleTailPainter(
                                                        color: bgColor,
                                                        isUser: isUser,
                                                      ),
                                                      size: Size(12, 8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (isUser)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.w),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        AppColors.primaryColor,
                                                    child: Text(
                                                        _customerName != null &&
                                                                _customerName!
                                                                    .isNotEmpty
                                                            ? _customerName![0]
                                                            : 'Y',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: isUser ? 0 : 8.w,
                                              right: isUser ? 8.w : 0,
                                              top: 2.h),
                                          child: Text(msg.senderName,
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                    ),
                    // Floating input bar with attach
                    Container(
                      margin: EdgeInsets.only(
                          bottom: 8.h, left: 8.w, right: 8.w, top: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blackColor.withOpacity(0.08),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
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
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              cursorColor: AppColors.greyColor,
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                hintStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 14.sp),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 10.h),
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: _isSendingMessage
                                ? Padding(
                                    padding: EdgeInsets.all(8.w),
                                    child: SizedBox(
                                      // width: 20.w,
                                      // height: 20.h,
                                      child: CupertinoActivityIndicator(
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(Icons.send_rounded,
                                        color: AppColors.whiteColor,
                                        size: 18.sp,
                                        semanticLabel: 'Send'),
                                    onPressed: () => _sendMessage(provider),
                                  ),
                          ),
                          if (_isUploadingFile)
                            Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CupertinoActivityIndicator(
                                      color: AppColors.primaryColor)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
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

// Add a custom painter for chat bubble tails
class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isUser;
  _BubbleTailPainter({required this.color, required this.isUser});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (isUser) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
