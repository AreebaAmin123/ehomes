import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier {
  int _selectedIndex = 0;
  bool _isHomeReselected = false;

  int get selectedIndex => _selectedIndex;
  bool get isHomeReselected => _isHomeReselected;

  void updateSelectedIndex(int index) {
    // Check if home tab is being reselected
    if (index == 0 && _selectedIndex == 0) {
      _isHomeReselected = true;
    } else {
      _isHomeReselected = false;
    }
    
    _selectedIndex = index;
    notifyListeners();
  }

  // Reset the home reselection flag
  void resetHomeReselection() {
    _isHomeReselected = false;
  }
}