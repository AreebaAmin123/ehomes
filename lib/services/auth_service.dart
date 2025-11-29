import 'client/api_client.dart';

/// 🔹 **Authentication Service**
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// 🔹 **Sign In**
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    return _apiClient.post('/signin.php', {
      "email": email,
      "password": password,
    });
  }

  /// 🔹 **Sign Up**
  Future<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    required String confirmPassword,
    required String deviceId,
    String? referralCode,
  }) async {
    return _apiClient.post('/signup.php', {
      "user_name": name,
      "email": email,
      "phone": phone,
      "country_code": countryCode,
      "password": password,
      "confirm_password": confirmPassword,
      "device_id": deviceId,
      "referral_code": referralCode ?? "",
    });
  }

  /// 🔹 **Request Sign-in OTP**
  Future<Map<String, dynamic>?> requestSignInOtp(String email) async {
    return _apiClient.post('/signin_otp.php', {"email": email});
  }

  /// 🔹 **Verify OTP**
  Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
    return _apiClient.post('/verify_otp.php', {"email": email, "otp": otp});
  }

  /// 🔹 **Logout**
  Future<Map<String, dynamic>?> logout(String token) async {
    return _apiClient.post('/logout.php', {"token": token});
  }

  /// 🔹 **Verify SMS OTP**
  Future<Map<String, dynamic>?> verifySmsOtp({
    required String userId,
    required String otpId,
    required String otpCode,
    required String phone,
  }) async {
    return _apiClient.post('/verify_sms_otp.php', {
      "user_id": userId,
      "otp_id": otpId,
      "otp_code": otpCode,
      "phone": phone,
    });
  }

  /// 🔹 **Request SMS OTP**
  Future<Map<String, dynamic>?> requestSmsOtp(String phone) async {
    return _apiClient.post('/request_sms_otp.php', {"phone": phone});
  }
}
