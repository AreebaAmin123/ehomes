import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../Utils/constants/my_sharePrefs.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';

class EmailAuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final MySharedPrefs _sharedPrefs = MySharedPrefs();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  UserModel? _user;

  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  /// 🔹 **Toggle Password Visibility**
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// 🔹 **Toggle Confirm Password Visibility**
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  /// 🔹 **Set Loading State**
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 🔹 **Load User Session**
  Future<void> loadUserSession() async {
    String? userData = await _sharedPrefs.getUserData();
    if (userData != null) {
      _user = UserModel.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }

  /// 🔹 **User Login**
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final response = await _authService.signIn(email, password);

      if (response == null) {
        return {
          'success': false,
          'message': 'Connection error. Please check your internet connection.'
        };
      }

      if (response['success'] == true && response['user'] != null) {
        _user = UserModel.fromJson(response['user']);
        await _sharedPrefs.setUserData(jsonEncode(response['user']));
        notifyListeners();
        return response;
      }

      // Handle error key from API
      return {
        'success': false,
        'message': response['error'] ??
            response['message'] ??
            'Login failed. Please try again.'
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Connection error. Please check your internet connection.'
      };
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 **User Sign-up**
  Future<Map<String, dynamic>?> signUpUser({
    required String name,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    required String confirmPassword,
    required String deviceId,
    String? referralCode,
  }) async {
    _setLoading(true);
    try {
      final response = await _authService.signUp(
        name: name,
        email: email,
        phone: phone,
        countryCode: countryCode,
        password: password,
        confirmPassword: confirmPassword,
        deviceId: deviceId,
        referralCode: referralCode,
      );

      debugPrint('📥 Raw signup response: $response');

      if (response == null || response.isEmpty) {
        return {'success': false, 'message': "Invalid response from server"};
      }

      // Check if the response contains the success message
      if (response['success'] != null) {
        // If success is a string containing "User registered", treat it as success
        if (response['success'] is String &&
            response['success'].toString().contains('User registered')) {
          return {
            'success': true,
            'user_id': response['user_id'],
            'otp_id': response['otp_id'],
            'message': response['success'],
          };
        }
        // If success is a boolean true
        else if (response['success'] == true) {
          return {
            'success': true,
            'user_id': response['user_id'],
            'otp_id': response['otp_id'],
            'message': response['message'] ?? "User registered successfully!",
          };
        }
      }

      // Extract API error message if present
      final errorMessage =
          response['error'] ?? response['message'] ?? "Registration failed";
      return {'success': false, 'message': errorMessage};
    } catch (error) {
      debugPrint('❌ Signup error: $error');
      return {'success': false, 'message': error.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 **Request Sign-in OTP**
  Future<Map<String, dynamic>?> requestSignInOtp(String email) async {
    _setLoading(true);
    try {
      final response = await _authService.requestSignInOtp(email);

      if (response != null &&
          response.containsKey('success') &&
          (response['success'] == true ||
              response['success'] == "OTP sent to email")) {
        return response;
      }

      return {
        'success': false,
        'message': response?['message'] ?? "Unexpected response format"
      };
    } catch (error) {
      return {'success': false, 'message': error.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 **Verify OTP**
  Future<Map<String, dynamic>?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    try {
      final response = await _authService.verifyOtp(email, otp);
      return response;
    } catch (error) {
      return {'success': false, 'message': error.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 **User Logout**
  Future<void> logout() async {
    _setLoading(true);
    try {
      String? userData = await _sharedPrefs.getUserData();
      if (userData != null) {
        final userMap = jsonDecode(userData);
        String? token = userMap['token'];

        if (token != null) {
          await _authService.logout(token);
        }
      }

      await _sharedPrefs.clearUserSession();
      _user = null;
      notifyListeners();
    } catch (error) {
      debugPrint("Logout Error: $error");
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 **Request SMS OTP**
  Future<Map<String, dynamic>?> requestSmsOtp(String phone) async {
    _setLoading(true);
    try {
      final response = await _authService.requestSmsOtp(phone);

      if (response != null &&
          response.containsKey('success') &&
          (response['success'] == true ||
              response['success'] == "OTP sent to phone")) {
        return response;
      }

      return {
        'success': false,
        'message': response?['message'] ?? "Unexpected response format"
      };
    } catch (error) {
      return {'success': false, 'message': error.toString()};
    } finally {
      _setLoading(false);
    }
  }

  /// 🔹 **Verify SMS OTP**
  Future<Map<String, dynamic>?> verifySmsOtp({
    required String userId,
    required String otpId,
    required String otpCode,
    required String phone,
  }) async {
    _setLoading(true);
    try {
      final response = await _authService.verifySmsOtp(
        userId: userId,
        otpId: otpId,
        otpCode: otpCode,
        phone: phone,
      );
      return response;
    } catch (error) {
      return {'success': false, 'message': error.toString()};
    } finally {
      _setLoading(false);
    }
  }
}
