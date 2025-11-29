import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_Home_app/screens/Auth/email%20section/provider/email_authProvider.dart';
import 'package:e_Home_app/models/profile/post_user_profile_data_model.dart';
import 'package:e_Home_app/services/profile_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import '../../../models/profile/user_data_model.dart';

class ProfileProvider with ChangeNotifier {
  final _profileService = ProfileService();

  UserDataModel? _userDataModel;
  UserDataModel? get userDataModel => _userDataModel;

  // UI State
  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;
  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  bool _obscureConfirmPassword = true;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  void setInitialized(bool value) {
    _isInitialized = value;
    notifyListeners();
  }

  Future<void> fetchUserData(context) async {
    final provider = Provider.of<EmailAuthProvider>(context, listen: false);
    await provider.loadUserSession();
    final userId = provider.user?.id;
    if (userId == null) {
      print("user id is  null");
      return;
    }
    try {
      print("hitting the api");
      UserDataModel response = await _profileService.fetchUserData(userId);
      if (response.profile != null && response.profile!.id != null) {
        _userDataModel = response;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  PostUserProfileDataModel? _postUserProfileDataModel;
  PostUserProfileDataModel? get postUserProfileDataModel =>
      _postUserProfileDataModel;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> postUserProfileData(
      context,
      String userName,
      String email,
      String phone,
      String address,
      String password,
      String confirmPassword,
      File image) async {
    final provider = Provider.of<EmailAuthProvider>(context, listen: false);
    await provider.loadUserSession();
    final userId = provider.user?.id;

    if (userId == null) {
      print("user id is null");
      return;
    }

    _loading = true;
    notifyListeners(); // Notify UI about loading start

    try {
      final formData = FormData.fromMap({
        "id": userId,
        "user_name": userName,
        "email": email,
        "phone": phone,
        "address": address,
        "password": password,
        "user_photo": await MultipartFile.fromFile(
          image.path,
          filename: basename(image.path),
        ),
      });

      PostUserProfileDataModel response =
          await _profileService.postUserProfileData(formData);

      if (response.success != null &&
          response.success == "Profile updated successfully") {
        _postUserProfileDataModel = response;
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
