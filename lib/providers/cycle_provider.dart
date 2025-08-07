import 'package:flutter/material.dart';
import 'package:menstrual_tracker/models/cycle_data.dart';

class CycleProvider with ChangeNotifier {
  List<CycleData> _cycles = [];
  DateTime? _selectedDate;

  List<CycleData> get cycles => _cycles;
  DateTime? get selectedDate => _selectedDate;

  void addCycle(CycleData newCycle) {
    _cycles.add(newCycle);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  CycleData? getCycleForDate(DateTime date) {
    try {
      return _cycles.firstWhere((cycle) =>
          date.isAfter(cycle.periodStartDate.subtract(const Duration(days: 1))) &&
          date.isBefore(cycle.periodEndDate.add(const Duration(days: 1))));
    } catch (e) {
      return null;
    }
  }
}