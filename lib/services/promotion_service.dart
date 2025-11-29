import 'client/api_client.dart';
import '../models/promotion_model.dart';
import '../Utils/constants/my_sharePrefs.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class PromotionService {
  final ApiClient _apiClient = ApiClient();
  final MySharedPrefs _prefs = MySharedPrefs();

  Future<List<PromotionModel>> getPromotions() async {
    try {
      // Try to get data from cache first
      final cachedData = await _prefs.getPromotionData();
      if (cachedData != null) {
        debugPrint('Loading promotions from cache');
        final response = jsonDecode(cachedData);
        if (response != null && response['data'] is List) {
          final promotions = (response['data'] as List<dynamic>)
              .map((e) => PromotionModel.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint('Loaded ${promotions.length} promotions from cache');
          if (promotions.isNotEmpty) {
            debugPrint(
                'Sample promotion - title: ${promotions[0].title}, image: ${promotions[0].image}');
          }
          return promotions;
        }
      }

      // If no cache or cache expired, fetch from API
      debugPrint('Fetching promotions from API');
      final response = await _apiClient.get('/get_promotion.php');
      debugPrint('PromotionService raw response: $response');

      if (response != null) {
        List<Map<String, dynamic>> promotionsList;

        if (response is List) {
          promotionsList = (response as List).cast<Map<String, dynamic>>();
        } else if (response is Map && response['data'] is List) {
          promotionsList =
              (response['data'] as List).cast<Map<String, dynamic>>();
        } else if (response is Map) {
          promotionsList = [response as Map<String, dynamic>];
        } else {
          promotionsList = [];
        }

        final promotions =
            promotionsList.map((e) => PromotionModel.fromJson(e)).toList();

        // Cache the response
        await _prefs.savePromotionData(
            jsonEncode({'success': true, 'data': promotionsList}));

        debugPrint('Cached ${promotions.length} promotions');
        if (promotions.isNotEmpty) {
          debugPrint(
              'Sample promotion - title: ${promotions[0].title}, image: ${promotions[0].image}');
        }

        return promotions;
      }

      debugPrint('PromotionService: response is null');
      return [];
    } catch (e) {
      debugPrint('PromotionService error: $e');
      return [];
    }
  }
}
