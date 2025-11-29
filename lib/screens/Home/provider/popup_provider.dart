import 'package:flutter/material.dart';
import '../../../models/popup_model.dart';
import '../../../services/popup_service.dart';

class PopupProvider extends ChangeNotifier {
  final PopupService _popupService = PopupService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<PopupBanner> _banners = [];
  List<PopupBanner> get banners => _banners;

  bool _showPopup = false;
  bool get showPopup => _showPopup && _banners.isNotEmpty;

  Future<void> fetchPopupImages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _popupService.fetchPopupImages();
      if (result.success && result.banners.isNotEmpty) {
        _banners = result.banners;
        _showPopup = true;
      } else {
        _banners = [];
        _showPopup = false;
      }
    } catch (e) {
      _error = e.toString();
      _banners = [];
      _showPopup = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void hidePopup() {
    _showPopup = false;
    notifyListeners();
  }

  void showPopupIfBanners() {
    if (_banners.isNotEmpty) {
      _showPopup = true;
      notifyListeners();
    }
  }
}
