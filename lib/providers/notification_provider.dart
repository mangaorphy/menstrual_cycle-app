import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _isPeriodReminderEnabled = true;
  bool _isDailyLogReminderEnabled = true;
  bool _isFertileWindowReminderEnabled = true;
  int _periodReminderDays = 3; // Days before period to remind
  TimeOfDay _dailyLogReminderTime = const TimeOfDay(
    hour: 20,
    minute: 0,
  ); // 8 PM
  bool _isInitialized = false;

  // Getters
  bool get isPeriodReminderEnabled => _isPeriodReminderEnabled;
  bool get isDailyLogReminderEnabled => _isDailyLogReminderEnabled;
  bool get isFertileWindowReminderEnabled => _isFertileWindowReminderEnabled;
  int get periodReminderDays => _periodReminderDays;
  TimeOfDay get dailyLogReminderTime => _dailyLogReminderTime;
  bool get isInitialized => _isInitialized;

  /// Initialize notification provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _notificationService.initialize();
    await _loadPreferences();
    _isInitialized = true;
    print('🔔 NotificationProvider initialized');
  }

  /// Load notification preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _isPeriodReminderEnabled = prefs.getBool('period_reminder_enabled') ?? true;
    _isDailyLogReminderEnabled =
        prefs.getBool('daily_log_reminder_enabled') ?? true;
    _isFertileWindowReminderEnabled =
        prefs.getBool('fertile_window_reminder_enabled') ?? true;
    _periodReminderDays = prefs.getInt('period_reminder_days') ?? 3;

    // Load daily log reminder time
    final hour = prefs.getInt('daily_log_hour') ?? 20;
    final minute = prefs.getInt('daily_log_minute') ?? 0;
    _dailyLogReminderTime = TimeOfDay(hour: hour, minute: minute);

    print('🔔 Loaded notification preferences');
    notifyListeners();
  }

  /// Save notification preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('period_reminder_enabled', _isPeriodReminderEnabled);
    await prefs.setBool(
      'daily_log_reminder_enabled',
      _isDailyLogReminderEnabled,
    );
    await prefs.setBool(
      'fertile_window_reminder_enabled',
      _isFertileWindowReminderEnabled,
    );
    await prefs.setInt('period_reminder_days', _periodReminderDays);
    await prefs.setInt('daily_log_hour', _dailyLogReminderTime.hour);
    await prefs.setInt('daily_log_minute', _dailyLogReminderTime.minute);

    print('🔔 Saved notification preferences');
  }

  /// Toggle period reminder notifications
  Future<void> togglePeriodReminder(bool enabled) async {
    _isPeriodReminderEnabled = enabled;
    await _savePreferences();

    if (!enabled) {
      // Cancel existing period reminder notifications
      await _notificationService.cancelNotification(1000);
      await _notificationService.cancelNotification(1001);
      print('🔔 Cancelled period reminder notifications');
    }

    notifyListeners();
  }

  /// Toggle daily log reminder notifications
  Future<void> toggleDailyLogReminder(bool enabled) async {
    _isDailyLogReminderEnabled = enabled;
    await _savePreferences();

    if (!enabled) {
      // Cancel existing daily log reminder notifications
      await _cancelDailyLogNotifications();
      print('🔔 Cancelled daily log reminder notifications');
    }

    notifyListeners();
  }

  /// Toggle fertile window reminder notifications
  Future<void> toggleFertileWindowReminder(bool enabled) async {
    _isFertileWindowReminderEnabled = enabled;
    await _savePreferences();

    if (!enabled) {
      // Cancel existing fertile window notifications
      await _notificationService.cancelNotification(3000);
      print('🔔 Cancelled fertile window reminder notifications');
    }

    notifyListeners();
  }

  /// Set period reminder days
  Future<void> setPeriodReminderDays(int days) async {
    _periodReminderDays = days;
    await _savePreferences();
    notifyListeners();
  }

  /// Set daily log reminder time
  Future<void> setDailyLogReminderTime(TimeOfDay time) async {
    _dailyLogReminderTime = time;
    await _savePreferences();
    notifyListeners();
  }

  /// Schedule period reminder notification
  Future<void> schedulePeriodReminder({
    required DateTime expectedPeriodDate,
  }) async {
    if (!_isPeriodReminderEnabled) return;

    // Cancel existing period reminders
    await _notificationService.cancelNotification(1000);
    await _notificationService.cancelNotification(1001);

    // Schedule reminder X days before period
    final reminderDate = expectedPeriodDate.subtract(
      Duration(days: _periodReminderDays),
    );
    await _notificationService.schedulePeriodReminder(
      scheduledDate: reminderDate,
      daysUntilPeriod: _periodReminderDays,
      notificationId: 1000,
    );

    // Schedule notification for period start day
    await _notificationService.scheduleNextPeriodNotification(
      nextPeriodDate: expectedPeriodDate,
      notificationId: 1001,
    );

    print('🔔 Period reminders scheduled for: $expectedPeriodDate');
  }

  /// Schedule daily log reminders for the next 30 days
  Future<void> scheduleDailyLogReminders() async {
    if (!_isDailyLogReminderEnabled) return;

    // Cancel existing daily log reminders
    await _cancelDailyLogNotifications();

    // Schedule daily log reminders for the next 30 days
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final scheduleDate = now.add(Duration(days: i));
      final scheduledTime = DateTime(
        scheduleDate.year,
        scheduleDate.month,
        scheduleDate.day,
        _dailyLogReminderTime.hour,
        _dailyLogReminderTime.minute,
      );

      await _notificationService.scheduleDailyLogReminder(
        scheduledDate: scheduledTime,
        notificationId: 2000 + i,
      );
    }

    print(
      '🔔 Daily log reminders scheduled for next 30 days at ${_dailyLogReminderTime.format24Hour}',
    );
  }

  /// Schedule fertile window notification
  Future<void> scheduleFertileWindowNotification({
    required DateTime fertileStartDate,
  }) async {
    if (!_isFertileWindowReminderEnabled) return;

    await _notificationService.scheduleFertileWindowNotification(
      fertileStartDate: fertileStartDate,
      notificationId: 3000,
    );

    print('🔔 Fertile window notification scheduled for: $fertileStartDate');
  }

  /// Cancel daily log notifications (2000-2029)
  Future<void> _cancelDailyLogNotifications() async {
    for (int i = 0; i < 30; i++) {
      await _notificationService.cancelNotification(2000 + i);
    }
  }

  /// Test notification functionality
  Future<void> testNotification() async {
    await _notificationService.showImmediateNotification(
      title: '🔔 Test Notification',
      body: 'Notifications are working correctly! 💕',
      payload: 'test_notification',
    );
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _notificationService.getPendingNotifications();
    return pending.length;
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    print('🔔 All notifications cancelled');
  }

  /// Format TimeOfDay for display
  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}

extension TimeOfDayExtension on TimeOfDay {
  String get format24Hour {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
