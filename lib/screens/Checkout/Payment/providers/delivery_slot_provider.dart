import 'package:flutter/material.dart';

import '../../../../models/delivery_slot_model.dart';
import '../../../../services/delivery_slot_service.dart';

class DeliverySlotProvider extends ChangeNotifier {
  final DeliverySlotService _service = DeliverySlotService();

  DeliverySlotModel? _deliverySlotModel;
  bool _isLoading = false;
  String? _error;
  int _selectedDateIndex = 0;
  int _selectedSlotId = 0;
  bool _isInitialized = false;

  // Getters
  DeliverySlotModel? get deliverySlotModel => _deliverySlotModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedDateIndex => _selectedDateIndex;
  int get selectedSlotId => _selectedSlotId;
  bool get isInitialized => _isInitialized;

  // Setters
  void setSelectedDateIndex(int index) {
    _selectedDateIndex = index;
    notifyListeners();
  }

  void setSelectedSlotId(int slotId) {
    _selectedSlotId = slotId;
    notifyListeners();
  }

  // Initialize provider
  Future<void> initialize(List<String> categoryIds) async {
    if (_isInitialized) return;
    _isInitialized = true;
    await fetchDeliverySlots(categoryIds);
  }

  // Fetch delivery slots
  Future<void> fetchDeliverySlots(List<String> categoryIds) async {
    if (categoryIds.isEmpty) {
      _error = 'No categories available';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _service.getDeliverySlots(categoryIds);

      _deliverySlotModel = result;

      if (result.success && result.slots.isNotEmpty) {
        _selectedSlotId = result.slots[0].slotId;
      } else {
        _error =
            'Sorry, delivery slots are not available for some items in your cart. This could be because:\n\n• The items are not eligible for delivery\n• Delivery is temporarily unavailable\n• The delivery schedule is not yet configured\n\nPlease try again later or contact support for assistance.';
      }
    } catch (e) {
      _error = 'Failed to fetch delivery slots: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get selected slot details
  DeliverySlot? getSelectedSlot() {
    return _deliverySlotModel?.slots.firstWhere(
        (slot) => slot.slotId == _selectedSlotId,
        orElse: () => DeliverySlot(
            date: '',
            day: '',
            slotId: 0,
            slotType: '',
            startTime: '',
            endTime: '',
            status: ''));
  }

  // Clear selection
  void clearSelection() {
    _selectedDateIndex = 0;
    _selectedSlotId = 0;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _deliverySlotModel = null;
    _isLoading = false;
    _error = null;
    _selectedDateIndex = 0;
    _selectedSlotId = 0;
    _isInitialized = false;
    notifyListeners();
  }
}
