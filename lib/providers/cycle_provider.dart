import 'package:flutter/material.dart';
import 'package:menstrual_tracker/models/cycle_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CycleProvider with ChangeNotifier {
  final List<CycleData> _cycles = [];
  DateTime? _selectedDate;
  bool _isInitialSetupComplete = false;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  List<CycleData> get cycles => _cycles;
  DateTime? get selectedDate => _selectedDate;
  bool get isInitialSetupComplete => _isInitialSetupComplete;
  bool get isLoading => _isLoading;

  // Initialize provider and load data
  CycleProvider() {
    _initializeProvider();
  }

  // Initialize the provider with persistent user ID
  Future<void> _initializeProvider() async {
    await _loadUserId();
    await _loadInitialSetupStatus();
    await _loadCyclesFromFirestore();
  }

  // Get or create a user ID (prioritize Firebase Auth ID)
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get user ID from Firebase Auth first
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _userId = currentUser.uid;
      // Update SharedPreferences with the authenticated user ID
      await prefs.setString('user_id', _userId!);
    } else {
      // Fall back to persistent user ID from SharedPreferences
      _userId = prefs.getString('user_id');

      // If no user ID exists, create a temporary one
      if (_userId == null) {
        _userId =
            'user_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
        await prefs.setString('user_id', _userId!);
      }
    }
  }

  // Load initial setup status from SharedPreferences
  Future<void> _loadInitialSetupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isInitialSetupComplete = prefs.getBool('initial_setup_complete') ?? false;
    notifyListeners();
  }

  // Save initial setup status to SharedPreferences
  Future<void> _saveInitialSetupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('initial_setup_complete', _isInitialSetupComplete);
  }

  // Update user ID when authentication changes (call this after login/logout)
  Future<void> updateUserAuthentication(String? newUserId) async {
    final oldUserId = _userId;

    if (newUserId != null && newUserId != oldUserId) {
      // User logged in with a different ID
      _userId = newUserId;

      // Save new user ID to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userId!);

      // If there were cycles under the old temporary ID, migrate them
      if (oldUserId != null && oldUserId.startsWith('user_')) {
        await _migrateCyclesToAuthenticatedUser(oldUserId, newUserId);
      }

      // Reload cycles for the new user
      await _loadCyclesFromFirestore();
    } else if (newUserId == null && oldUserId != null) {
      // User logged out, create temporary ID
      await _loadUserId();
      await _loadCyclesFromFirestore();
    }
  }

  // Migrate cycles from temporary user to authenticated user
  Future<void> _migrateCyclesToAuthenticatedUser(
    String oldUserId,
    String newUserId,
  ) async {
    try {
      // Get cycles from old temporary user
      final oldCycles = await _firestore
          .collection('users')
          .doc(oldUserId)
          .collection('cycles')
          .get();

      // Add cycles to new authenticated user
      final batch = _firestore.batch();
      for (var doc in oldCycles.docs) {
        final cycleData = doc.data();
        final newCycleRef = _firestore
            .collection('users')
            .doc(newUserId)
            .collection('cycles')
            .doc();
        batch.set(newCycleRef, cycleData);
      }

      // Delete cycles from old temporary user
      for (var doc in oldCycles.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print(
        'Successfully migrated ${oldCycles.docs.length} cycles to authenticated user',
      );
    } catch (e) {
      print('Error migrating cycles: $e');
    }
  }

  // Load cycles from Firestore
  Future<void> _loadCyclesFromFirestore() async {
    if (_userId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('cycles')
          .orderBy('periodStartDate', descending: false)
          .get();

      _cycles.clear();
      for (var doc in querySnapshot.docs) {
        _cycles.add(CycleData.fromDocument(doc));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading cycles from Firestore: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add cycle to Firestore and local list
  Future<void> addCycle(CycleData newCycle) async {
    if (_userId == null) {
      // Add locally only if no user ID
      _cycles.add(newCycle);
      notifyListeners();
      return;
    }

    try {
      // Add to Firestore
      final docRef = await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('cycles')
          .add(newCycle.toMap());

      // Set the Firestore document ID
      newCycle.id = docRef.id;

      // Add to local list
      _cycles.add(newCycle);
      notifyListeners();
    } catch (e) {
      print('Error adding cycle to Firestore: $e');
      // Still add locally if Firestore fails
      _cycles.add(newCycle);
      notifyListeners();
    }
  }

  // Update cycle in Firestore
  Future<void> updateCycle(CycleData cycle) async {
    if (cycle.id == null || _userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('cycles')
          .doc(cycle.id)
          .update(cycle.toMap());

      notifyListeners();
    } catch (e) {
      print('Error updating cycle in Firestore: $e');
    }
  }

  // Delete cycle from Firestore
  Future<void> deleteCycle(String cycleId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('cycles')
          .doc(cycleId)
          .delete();

      _cycles.removeWhere((cycle) => cycle.id == cycleId);
      notifyListeners();
    } catch (e) {
      print('Error deleting cycle from Firestore: $e');
    }
  }

  Future<void> setInitialSetupComplete() async {
    _isInitialSetupComplete = true;
    await _saveInitialSetupStatus();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  CycleData? getCycleForDate(DateTime date) {
    try {
      return _cycles.firstWhere(
        (cycle) =>
            !date.isBefore(cycle.periodStartDate) &&
            !date.isAfter(cycle.periodEndDate),
      );
    } catch (e) {
      return null;
    }
  }

  /// The active cycle for today
  CycleData? get currentCycle {
    if (_cycles.isEmpty) return null;

    final today = DateTime.now();
    final targetDate = _selectedDate ?? today;

    // Find cycle that includes the target date (for current period)
    for (var cycle in _cycles) {
      if (!targetDate.isBefore(cycle.periodStartDate) &&
          !targetDate.isAfter(cycle.periodEndDate)) {
        return cycle;
      }
    }

    // If no active period, find the most recent cycle for cycle tracking
    var mostRecentCycle = _cycles.last;
    for (var cycle in _cycles.reversed) {
      if (!targetDate.isBefore(cycle.periodStartDate)) {
        mostRecentCycle = cycle;
        break;
      }
    }

    return mostRecentCycle;
  }

  /// Average period length across all cycles
  int get averagePeriodLength {
    if (_cycles.isEmpty) return 5; // Default period length
    final lengths = _cycles
        .map((c) => c.periodEndDate.difference(c.periodStartDate).inDays + 1)
        .toList();
    return lengths.isNotEmpty
        ? (lengths.reduce((a, b) => a + b) / lengths.length).round()
        : 5;
  }

  /// Average cycle length across all cycles
  int get averageCycleLength {
    if (_cycles.length < 2) return 28; // Default cycle length
    final lengths = <int>[];
    for (int i = 1; i < _cycles.length; i++) {
      final diff = _cycles[i].periodStartDate
          .difference(_cycles[i - 1].periodStartDate)
          .inDays;
      if (diff > 0) {
        // Only add positive differences
        lengths.add(diff);
      }
    }
    return lengths.isNotEmpty
        ? (lengths.reduce((a, b) => a + b) / lengths.length).round()
        : 28;
  }

  /// Current cycle day
  int get currentCycleDay {
    final cycle = currentCycle;
    if (cycle == null) return 1;

    final targetDate = _selectedDate ?? DateTime.now();

    // If we're currently in the period
    if (!targetDate.isBefore(cycle.periodStartDate) &&
        !targetDate.isAfter(cycle.periodEndDate)) {
      return targetDate.difference(cycle.periodStartDate).inDays + 1;
    }

    // If we're past the period, calculate cycle day
    if (targetDate.isAfter(cycle.periodEndDate)) {
      return targetDate.difference(cycle.periodStartDate).inDays + 1;
    }

    // Default case
    return targetDate.difference(cycle.periodStartDate).inDays + 1;
  }

  /// Estimated fertile window start
  DateTime get fertileWindowStart {
    final cycle = currentCycle;
    if (cycle == null) return DateTime.now();
    final ovulationDay = max(averageCycleLength - 14, 0);
    return cycle.periodStartDate.add(Duration(days: ovulationDay - 5));
  }

  /// Estimated ovulation date
  DateTime get ovulationDate {
    final cycle = currentCycle;
    if (cycle == null) return DateTime.now();
    final ovulationDay = max(averageCycleLength - 14, 0);
    return cycle.periodStartDate.add(Duration(days: ovulationDay));
  }

  /// Pregnancy chance label
  String get pregnancyChanceLabel {
    final targetDate = _selectedDate ?? DateTime.now();
    final fertileStart = fertileWindowStart;
    final fertileEnd = fertileStart.add(const Duration(days: 6));

    if (!targetDate.isBefore(fertileStart) && !targetDate.isAfter(fertileEnd)) {
      return "High";
    }
    return "Low";
  }

  /// Progress through current cycle
  double get cycleProgress {
    final cycle = currentCycle;
    if (cycle == null || averageCycleLength == 0) return 0;
    final progress = (currentCycleDay / averageCycleLength);
    return progress.clamp(0.0, 1.0);
  }

  /// End the current period
  void endPeriod() {
    final cycle = currentCycle;
    if (cycle != null) {
      cycle.periodEndDate = DateTime.now();
      notifyListeners();
    }
  }
}
