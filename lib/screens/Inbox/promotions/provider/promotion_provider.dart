import 'package:flutter/material.dart';
import '../../../../models/promotion_model.dart';
import '../../../../services/promotion_service.dart';

class PromotionProvider with ChangeNotifier {
  final PromotionService _promotionService = PromotionService();

  List<PromotionModel> _promotions = [];
  List<PromotionModel> get promotions => _promotions;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> fetchPromotions() async {
    debugPrint('🔄 Starting to fetch promotions');
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📡 Calling promotion service');
      final data = await _promotionService.getPromotions();
      debugPrint('📦 Received ${data.length} promotions');

      if (data.isNotEmpty) {
        debugPrint(
            '📝 First promotion: title=${data[0].title}, image=${data[0].image}');
      }

      _promotions = data;
      debugPrint('✅ Promotions updated in provider');
    } catch (e) {
      debugPrint('❌ Error fetching promotions: $e');
      _error = e.toString();
      _promotions = [];
    } finally {
      _loading = false;
      notifyListeners();
      debugPrint(
          '🏁 Finished fetching promotions. Has error: ${_error != null}');
    }
  }

  void refresh() {
    debugPrint('🔄 Refreshing promotions');
    fetchPromotions();
  }
}
