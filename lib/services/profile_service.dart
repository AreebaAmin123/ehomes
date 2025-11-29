import 'package:e_Home_app/models/profile/post_user_profile_data_model.dart';
import 'package:e_Home_app/services/client/api_client.dart';
import 'package:flutter/foundation.dart';
import '../models/profile/user_data_model.dart';
import '../Utils/constants/my_sharePrefs.dart';
import 'dart:convert';
import 'package:dio/dio.dart' show FormData;

class ProfileService {
  final ApiClient _apiClient = ApiClient();
  final MySharedPrefs _prefs = MySharedPrefs();

  /// Fetch user data with user id
  Future<UserDataModel> fetchUserData(int userId) async {
    try {
      // Try to get data from cache first
      final cachedData = await _prefs.getProfileData(userId);
      if (cachedData != null) {
        debugPrint('Loading profile from cache for user $userId');
        final response = jsonDecode(cachedData);
        if (response != null) {
          return UserDataModel.fromJson(response);
        }
      }

      // If no cache or cache expired, fetch from API
      debugPrint('Fetching profile from API for user $userId');
      final response = await _apiClient.get(
        '/get_profile.php',
        queryParams: {"id": userId},
      );

      debugPrint("Full API Response: ${response.toString()}");

      if (response != null) {
        // Cache the response
        await _prefs.saveProfileData(userId, jsonEncode(response));
        debugPrint('Cached profile data for user $userId');

        return UserDataModel.fromJson(response);
      } else {
        throw Exception("API returned null response");
      }
    } catch (e) {
      debugPrint("Error in fetching the data : $e");
      rethrow;
    }
  }

  Future<PostUserProfileDataModel> postUserProfileData(dynamic data) async {
    try {
      final response = await _apiClient.post('/user_profile.php', data);

      debugPrint("Full API Response: ${response.toString()}");

      if (response != null) {
        // For FormData, we need to get the id from the fields
        int? userId;
        if (data is FormData) {
          // Get the id from FormData fields
          final fields = data.fields;
          final idField = fields.firstWhere((field) => field.key == 'id',
              orElse: () => const MapEntry('id', ''));
          userId = int.tryParse(idField.value);
        } else if (data is Map) {
          userId = int.tryParse(data['id'].toString());
        }

        // Only update cache if we have a valid userId
        if (userId != null) {
          await _prefs.saveProfileData(userId, jsonEncode(response));
          debugPrint('Updated cache for user $userId after profile update');
        }

        return PostUserProfileDataModel.fromJson(response);
      } else {
        throw Exception("API returned null response");
      }
    } catch (e) {
      debugPrint("Error in posting the data : $e");
      rethrow;
    }
  }
}
