import 'package:flutter/material.dart';
import 'package:menstrual_tracker/models/cycle_data.dart';
import 'package:menstrual_tracker/models/daily_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menstrual_tracker/services/notification_service.dart';
import 'dart:math';

class CycleProvider with ChangeNotifier {
  final List<CycleData> _cycles = [];
  final List<DailyLog> _dailyLogs = [];
  DateTime? _selectedDate;
  bool _isInitialSetupComplete = false;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  List<CycleData> get cycles => _cycles;
  List<DailyLog> get dailyLogs => _dailyLogs;
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
    await _loadDailyLogsFromFirestore();
  }

  // Get or create a user ID (prioritize Firebase Auth ID)
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get user ID from Firebase Auth first
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _userId = currentUser.uid;
      print('🔐 Using Firebase Auth user ID: $_userId');
      // Update SharedPreferences with the authenticated user ID
      await prefs.setString('user_id', _userId!);
    } else {
      // Fall back to persistent user ID from SharedPreferences
      _userId = prefs.getString('user_id');
      print('💾 Retrieved user ID from SharedPreferences: $_userId');

      // If no user ID exists, create a temporary one
      if (_userId == null) {
        _userId =
            'user_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
        print('✨ Created new temporary user ID: $_userId');
        await prefs.setString('user_id', _userId!);
      }
    }
    print('👤 Final user ID: $_userId');
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
      await _loadDailyLogsFromFirestore();
    } else if (newUserId == null && oldUserId != null) {
      // User logged out, create temporary ID
      await _loadUserId();
      await _loadCyclesFromFirestore();
      await _loadDailyLogsFromFirestore();
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
          .orderBy(
            'periodStartDate',
            descending: true,
          ) // Show recent cycles first
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

  // Load daily logs from Firestore
  Future<void> _loadDailyLogsFromFirestore() async {
    print('📥 Loading daily logs from Firestore for user: $_userId');

    if (_userId == null) {
      print('❌ No user ID for loading daily logs');
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('daily_logs')
          .orderBy('date', descending: true)
          .get();

      print('📥 Found ${querySnapshot.docs.length} daily logs');

      _dailyLogs.clear();
      for (var doc in querySnapshot.docs) {
        final dailyLog = DailyLog.fromDocument(doc);
        _dailyLogs.add(dailyLog);
        print('📥 Loaded daily log: ${dailyLog.id} for ${dailyLog.date}');
      }

      print('📥 Total daily logs loaded: ${_dailyLogs.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading daily logs from Firestore: $e');
    }
  }

  // Add cycle to Firestore and local list
  Future<void> addCycle(CycleData newCycle) async {
    print('🔄 Adding cycle - User ID: $_userId');

    if (_userId == null) {
      print('❌ No user ID found - storing locally only');
      // Add locally only if no user ID
      _cycles.insert(0, newCycle);
      notifyListeners();
      return;
    }

    try {
      print('📤 Attempting to add cycle to Firestore...');
      // Add to Firestore
      final docRef = await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('cycles')
          .add(newCycle.toMap());

      print('✅ Successfully added to Firestore with ID: ${docRef.id}');

      // Set the Firestore document ID
      newCycle.id = docRef.id;

      // Add to local list at the beginning (most recent first)
      _cycles.insert(0, newCycle);

      // Schedule notifications for the new cycle
      await _scheduleNotificationsForCycle(newCycle);

      notifyListeners();
    } catch (e) {
      print('❌ Error adding cycle to Firestore: $e');
      // Still add locally if Firestore fails (at beginning)
      _cycles.insert(0, newCycle);

      // Schedule notifications even if Firestore fails
      await _scheduleNotificationsForCycle(newCycle);

      notifyListeners();
    }
  }

  // Refresh data from Firestore
  Future<void> refreshData() async {
    await _loadCyclesFromFirestore();
    await _loadDailyLogsFromFirestore();
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

  // Add or update daily log
  Future<void> saveDailyLog(DailyLog dailyLog) async {
    print('🗓️ Saving daily log - User ID: $_userId');
    print('🗓️ Daily log date: ${dailyLog.date}');
    print(
      '🗓️ Daily log data: flow=${dailyLog.flowIntensity}, mood=${dailyLog.mood}, symptoms=${dailyLog.symptoms}',
    );

    if (_userId == null) {
      print('❌ No user ID found for daily log');
      return;
    }

    try {
      // Check if a log already exists for this date
      final existingLogIndex = _dailyLogs.indexWhere(
        (log) => _isSameDate(log.date, dailyLog.date),
      );

      print('🗓️ Existing log index: $existingLogIndex');

      if (existingLogIndex != -1) {
        // Update existing log
        final existingLog = _dailyLogs[existingLogIndex];
        print('🔄 Updating existing log with ID: ${existingLog.id}');

        if (existingLog.id != null) {
          await _firestore
              .collection('users')
              .doc(_userId!)
              .collection('daily_logs')
              .doc(existingLog.id)
              .update({...dailyLog.toMap(), 'updatedAt': Timestamp.now()});

          print('✅ Successfully updated existing daily log');

          // Update local data
          _dailyLogs[existingLogIndex] = DailyLog(
            id: existingLog.id,
            date: dailyLog.date,
            flowIntensity: dailyLog.flowIntensity,
            mood: dailyLog.mood,
            symptoms: dailyLog.symptoms,
            notes: dailyLog.notes,
          );
        }
      } else {
        // Create new log
        print('✨ Creating new daily log');
        final docRef = await _firestore
            .collection('users')
            .doc(_userId!)
            .collection('daily_logs')
            .add(dailyLog.toMap());

        print('✅ Successfully created new daily log with ID: ${docRef.id}');
        dailyLog.id = docRef.id;
        _dailyLogs.insert(0, dailyLog);
      }

      print('🗓️ Total daily logs now: ${_dailyLogs.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error saving daily log: $e');
    }
  }

  // Get daily log for a specific date
  DailyLog? getDailyLogForDate(DateTime date) {
    print('🔍 Looking for daily log for date: $date');
    print('🔍 Available daily logs: ${_dailyLogs.length}');
    for (var log in _dailyLogs) {
      print(
        '🔍 Log date: ${log.date}, matches: ${_isSameDate(log.date, date)}',
      );
    }

    try {
      final result = _dailyLogs.firstWhere(
        (log) => _isSameDate(log.date, date),
      );
      print('✅ Found daily log: ${result.id}');
      return result;
    } catch (e) {
      print('❌ No daily log found for date: $date');
      return null;
    }
  }

  // Helper method to check if two dates are the same (ignoring time)
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Delete daily log
  Future<void> deleteDailyLog(String logId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId!)
          .collection('daily_logs')
          .doc(logId)
          .delete();

      _dailyLogs.removeWhere((log) => log.id == logId);
      notifyListeners();
    } catch (e) {
      print('Error deleting daily log: $e');
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
            (cycle.periodEndDate != null &&
                !date.isAfter(cycle.periodEndDate!)),
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
          (cycle.periodEndDate != null &&
              !targetDate.isAfter(cycle.periodEndDate!))) {
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
        .where((c) => c.periodEndDate != null)
        .map((c) => c.periodEndDate!.difference(c.periodStartDate).inDays + 1)
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

    // Calculate cycle day from period start date
    final daysSinceStart =
        targetDate.difference(cycle.periodStartDate).inDays + 1;

    // Ensure it's within reasonable bounds
    return daysSinceStart.clamp(1, 45);
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

  /// Get the most common flow intensity
  String get mostCommonFlow {
    if (_cycles.isEmpty) return 'Normal';

    final flowCounts = <String, int>{};
    for (final cycle in _cycles) {
      flowCounts[cycle.flowIntensity] =
          (flowCounts[cycle.flowIntensity] ?? 0) + 1;
    }

    return flowCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get the most common symptoms
  List<String> get mostCommonSymptoms {
    if (_cycles.isEmpty) return [];

    final symptomCounts = <String, int>{};
    for (final cycle in _cycles) {
      for (final symptom in cycle.symptoms) {
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }

    final sortedSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedSymptoms.take(5).map((e) => e.key).toList();
  }

  /// End the current period
  void endPeriod() {
    final cycle = currentCycle;
    if (cycle != null) {
      cycle.periodEndDate = DateTime.now();
      notifyListeners();
    }
  }

  // Daily Log Analytics Methods

  /// Get mood trends for the last 30 days
  Map<String, int> get moodTrends {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentLogs = _dailyLogs.where(
      (log) => log.date.isAfter(thirtyDaysAgo) && log.mood != null,
    );

    final moodCounts = <String, int>{};
    for (final log in recentLogs) {
      if (log.mood != null) {
        moodCounts[log.mood!] = (moodCounts[log.mood!] ?? 0) + 1;
      }
    }
    return moodCounts;
  }

  /// Get flow trends for the last 90 days
  Map<String, int> get flowTrends {
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    final recentLogs = _dailyLogs.where(
      (log) => log.date.isAfter(ninetyDaysAgo) && log.flowIntensity != null,
    );

    final flowCounts = <String, int>{};
    for (final log in recentLogs) {
      if (log.flowIntensity != null) {
        flowCounts[log.flowIntensity!] =
            (flowCounts[log.flowIntensity!] ?? 0) + 1;
      }
    }
    return flowCounts;
  }

  /// Get symptom frequency for the last 90 days
  Map<String, int> get symptomFrequency {
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    final recentLogs = _dailyLogs.where(
      (log) => log.date.isAfter(ninetyDaysAgo) && log.symptoms.isNotEmpty,
    );

    final symptomCounts = <String, int>{};
    for (final log in recentLogs) {
      for (final symptom in log.symptoms) {
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }
    return symptomCounts;
  }

  /// Get most common mood
  String get mostCommonMood {
    if (moodTrends.isEmpty) return 'Not enough data';
    return moodTrends.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get most frequent symptoms (top 5)
  List<String> get topSymptoms {
    final symptoms = symptomFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return symptoms.take(5).map((e) => e.key).toList();
  }

  /// Get logging consistency percentage for last 30 days
  double get loggingConsistency {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final totalDays = DateTime.now().difference(thirtyDaysAgo).inDays;

    final loggedDays = _dailyLogs
        .where((log) => log.date.isAfter(thirtyDaysAgo) && log.hasData)
        .length;

    return totalDays > 0 ? (loggedDays / totalDays) * 100 : 0;
  }

  /// Get patterns based on cycle phase and symptoms
  List<String> get cyclePatterns {
    final patterns = <String>[];

    // Mood patterns
    final moodData = moodTrends;
    if (moodData.isNotEmpty) {
      final dominantMood = moodData.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      if (dominantMood.value >= 3) {
        patterns.add(
          'You tend to feel ${dominantMood.key.toLowerCase()} most often',
        );
      }
    }

    // Symptom patterns
    final symptoms = topSymptoms;
    if (symptoms.isNotEmpty) {
      patterns.add(
        'Your most common symptoms are: ${symptoms.take(3).join(', ')}',
      );
    }

    // Flow patterns
    final flows = flowTrends;
    if (flows.isNotEmpty) {
      final dominantFlow = flows.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      patterns.add('Your flow is typically ${dominantFlow.key.toLowerCase()}');
    }

    return patterns;
  }

  // Notification scheduling methods
  Future<void> _scheduleNotificationsForCycle(CycleData cycle) async {
    try {
      await NotificationService().initialize();

      // Use average cycle length if we have data, else 28
      final estCycleLength = averageCycleLength; // already has default fallback
      final nextPeriodDate = cycle.periodStartDate.add(
        Duration(days: estCycleLength),
      );

      // Schedule a reminder 3 days before
      if (nextPeriodDate.isAfter(DateTime.now())) {
        await NotificationService().schedulePeriodReminder(
          scheduledDate: nextPeriodDate,
          daysUntilPeriod: 3,
          notificationId: 1000,
        );
        // Day-of notification
        await NotificationService().scheduleNextPeriodNotification(
          nextPeriodDate: nextPeriodDate,
          notificationId: 1001,
        );
      }

      // Fertile window (ovulation ~14 days before next period; fertile start 5 days before ovulation)
      final ovulationDate = nextPeriodDate.subtract(const Duration(days: 14));
      final fertileStart = ovulationDate.subtract(const Duration(days: 5));
      if (fertileStart.isAfter(DateTime.now())) {
        await NotificationService().scheduleFertileWindowNotification(
          fertileStartDate: fertileStart,
          notificationId: 3000,
        );
      }

      // Schedule daily log reminders (next 7 days)
      await _scheduleDailyLogReminders(days: 7);
    } catch (e) {
      print('❌ Error scheduling notifications: $e');
    }
  }

  Future<void> _scheduleDailyLogReminders({int days = 7}) async {
    try {
      final now = DateTime.now();
      for (int i = 0; i < days; i++) {
        final date = DateTime(
          now.year,
          now.month,
          now.day,
        ).add(Duration(days: i));
        await NotificationService().scheduleDailyLogReminder(
          scheduledDate: date,
          notificationId: 2000 + i,
        );
      }
      print('📅 Scheduled daily log reminders for next $days days');
    } catch (e) {
      print('❌ Error scheduling daily log reminders: $e');
    }
  }

  // Method to initialize and schedule all notifications
  Future<void> initializeNotifications() async {
    try {
      await NotificationService().initialize();
      if (_cycles.isNotEmpty) {
        final latestCycle = _cycles.first; // most recent at index 0
        await _scheduleNotificationsForCycle(latestCycle);
      } else {
        await _scheduleDailyLogReminders(days: 7);
      }
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }
}
