import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void navigateToCalendar() {
    setIndex(1); // Calendar is at index 1
  }

  void navigateToHome() {
    setIndex(0);
  }

  void navigateToInsights() {
    setIndex(2);
  }

  void navigateToSettings() {
    setIndex(3);
  }
}
