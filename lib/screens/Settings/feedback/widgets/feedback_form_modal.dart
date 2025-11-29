import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/constants/app_colors.dart';
import '../../../../Utils/helpers/feedback_text_field.dart';
import '../provider/feedback_provider.dart';
import '../../../Auth/email section/provider/email_authProvider.dart';
import '../../../../Utils/helpers/show_toast_dialouge.dart';

class FeedbackFormModal extends StatefulWidget {
  const FeedbackFormModal({super.key});

  @override
  State<FeedbackFormModal> createState() => _FeedbackFormModalState();
}

class _FeedbackFormModalState extends State<FeedbackFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _subject = 'Suggestion';
  final List<String> _subjects = ['Suggestion', 'Complaint', 'Query', 'Other'];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<EmailAuthProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final feedbackProvider =
        Provider.of<FeedbackProvider>(context, listen: false);
    final userProvider = Provider.of<EmailAuthProvider>(context, listen: false);
    final userId = userProvider.user?.id ?? 0;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subject;
    final message = _messageController.text.trim();
    final success = await feedbackProvider.submitFeedback(
      userId: userId,
      name: name,
      email: email,
      subject: subject,
      message: message,
    );
    if (!mounted) return;
    Navigator.pop(context);
    ShowToastDialog.show(
      context,
      feedbackProvider.submitResult ??
          (success ? 'Feedback submitted!' : 'Failed to submit feedback.'),
      type: success ? ToastType.success : ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedbackProvider = Provider.of<FeedbackProvider>(context);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Center(
                  child: Text('Submit Feedback',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                          color: AppColors.primaryColor)),
                ),
                SizedBox(height: 18.h),
                FeedBackTextField(
                  controller: _nameController,
                  label: 'Name',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                SizedBox(height: 12.h),
                FeedBackTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your email' : null,
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  value: _subject,
                  items: _subjects
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _subject = val ?? 'Suggestion'),
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: TextStyle(color: AppColors.primaryColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),
                FeedBackTextField(
                  controller: _messageController,
                  label: 'Message',
                  maxLines: 4,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter your message'
                      : null,
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: feedbackProvider.isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: feedbackProvider.isSubmitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CupertinoActivityIndicator(),
                          )
                        : Text('Submit',
                            style: TextStyle(
                                fontSize: 16.sp, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
