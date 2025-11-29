import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

enum ToastType { success, error, info, warning }

class ShowToastDialog {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onAction,
    EasyLoadingToastPosition position = EasyLoadingToastPosition.top,
  }) {
    // If action is provided, use SnackBar for action support, else use EasyLoading
    if (onAction != null && actionLabel != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _getColor(type),
          duration: duration,
          action: SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            onPressed: onAction,
          ),
        ),
      );
      return;
    }
    // Otherwise, use EasyLoading for simple toasts
    EasyLoading.instance.userInteractions = true;
    EasyLoading.showToast(
      message,
      toastPosition: position,
      duration: duration,
    );
  }

  static void showToast(String? errorMessage,
      {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) {
    String message = extractErrorMessage(errorMessage!);
    EasyLoading.instance.userInteractions = true;
    EasyLoading.showToast(
      message,
      toastPosition: position,
    );
  }

  static void showLoader(String message) {
    // EasyLoading.instance.userInteractions = false;
    EasyLoading.show(status: message);
  }

  static void closeLoader() {
    EasyLoading.dismiss();
  }

  static String extractErrorMessage(String error) {
    if (error.contains(']')) {
      return error.split(']').last.trim();
    }
    return error;
  }

  static Color _getColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
      default:
        return Colors.blue;
    }
  }
}
