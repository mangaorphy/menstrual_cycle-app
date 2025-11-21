import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _periodReminderChannelId = 'period_reminder_channel';
  static const String _cycleTrackingChannelId = 'cycle_tracking_channel';
  static const String _dailyLogChannelId = 'daily_log_channel';

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Set local timezone with error handling
    try {
      final String timeZoneName = _getLocalTimeZoneName();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print('⚠️ Failed to set timezone: $e. Using UTC as fallback.');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          requestCriticalPermission: false,
        );

    // Initialization settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    // Create notification channels
    await _createNotificationChannels();

    _isInitialized = true;
    print('🔔 Notification service initialized successfully');
  }

  /// Get the local timezone name
  String _getLocalTimeZoneName() {
    try {
      final timeZoneName = DateTime.now().timeZoneName;

      // Handle common timezone mappings
      switch (timeZoneName) {
        case 'CAT': // Central Africa Time
          return 'Africa/Johannesburg';
        case 'EAT': // East Africa Time
          return 'Africa/Nairobi';
        case 'WAT': // West Africa Time
          return 'Africa/Lagos';
        case 'SAST': // South Africa Standard Time
          return 'Africa/Johannesburg';
        default:
          // Try to use the timezone name as is
          return timeZoneName;
      }
    } catch (e) {
      // Fallback to UTC if timezone detection fails
      return 'UTC';
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    print('🔔 Notification tapped with payload: $payload');

    // Handle different notification types based on payload
    if (payload != null) {
      if (payload.contains('period_reminder')) {
        // TODO: Implement navigation
      } else if (payload.contains('daily_log')) {
        // TODO: Implement navigation
      }
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? granted = await androidPlugin
          ?.requestNotificationsPermission();
      print('🔔 Android notification permission: ${granted ?? false}');
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: false,
          );
      print('🔔 iOS notification permission: ${result ?? false}');
      return result ?? false;
    }

    return false;
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _periodReminderChannelId,
        'Period Reminders',
        description: 'Notifications about upcoming periods',
        importance: Importance.high,
        showBadge: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color.fromARGB(255, 244, 143, 177),
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _cycleTrackingChannelId,
        'Cycle Tracking',
        description: 'General cycle tracking reminders',
        importance: Importance.defaultImportance,
        showBadge: true,
        enableVibration: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _dailyLogChannelId,
        'Daily Log Reminders',
        description: 'Reminders to log daily symptoms and mood',
        importance: Importance.defaultImportance,
        showBadge: true,
      ),
    );

    print('🔔 Android notification channels created');
  }

  /// Schedule a period reminder notification
  Future<void> schedulePeriodReminder({
    required DateTime scheduledDate, // Expected period start date
    required int daysUntilPeriod, // How many days before to notify
    int notificationId = 1000,
  }) async {
    if (!_isInitialized) await initialize();

    // Compute reminder date based on daysUntilPeriod
    final reminderDate = scheduledDate.subtract(
      Duration(days: daysUntilPeriod),
    );
    final scheduledDateTime = tz.TZDateTime.from(reminderDate, tz.local);

    if (scheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('🔔 Skipping past date notification: $scheduledDateTime');
      return;
    }

    final bodyText =
        'Your period is expected in $daysUntilPeriod day${daysUntilPeriod == 1 ? '' : 's'}. Stay prepared! 💕';

    final bigText =
        'Your period is expected in $daysUntilPeriod day${daysUntilPeriod == 1 ? '' : 's'}. Start preparing and track any pre-period symptoms!';

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _periodReminderChannelId,
        'Period Reminders',
        channelDescription: 'Notifications about upcoming periods',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        enableLights: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(bigText),
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'period_reminder',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default.wav',
      ),
    );

    await _notifications.zonedSchedule(
      notificationId,
      '🌸 Period Reminder',
      bodyText,
      scheduledDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'period_reminder_$notificationId',
    );

    print('🔔 Period reminder scheduled for: $scheduledDateTime');
  }

  /// Schedule next period prediction notification (day of)
  Future<void> scheduleNextPeriodNotification({
    required DateTime nextPeriodDate,
    int notificationId = 1001,
  }) async {
    if (!_isInitialized) await initialize();

    final scheduledDateTime = tz.TZDateTime.from(
      DateTime(
        nextPeriodDate.year,
        nextPeriodDate.month,
        nextPeriodDate.day,
        9,
        0,
      ),
      tz.local,
    );

    if (scheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('🔔 Skipping past date notification: $scheduledDateTime');
      return;
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _periodReminderChannelId,
        'Period Reminders',
        channelDescription: 'Notifications about upcoming periods',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'period_start',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      notificationId,
      '🔴 Period Day',
      'Your period is expected to start today. Don\'t forget to log it! 💕',
      scheduledDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'period_start_$notificationId',
    );

    print('🔔 Next period notification scheduled for: $scheduledDateTime');
  }

  /// Schedule daily log reminder (one-time at 8 PM for given date)
  Future<void> scheduleDailyLogReminder({
    required DateTime scheduledDate,
    int notificationId = 2000,
  }) async {
    if (!_isInitialized) await initialize();

    final scheduledDateTime = tz.TZDateTime.from(
      DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        20,
        0,
      ),
      tz.local,
    );

    if (scheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('🔔 Skipping past daily log notification (past time)');
      return;
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _dailyLogChannelId,
        'Daily Log Reminders',
        channelDescription: 'Reminders to log daily symptoms and mood',
        importance: Importance.defaultImportance,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'daily_log',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      notificationId,
      '📝 Daily Check-in',
      'How are you feeling today? Log your mood and symptoms! ✨',
      scheduledDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_log_$notificationId',
    );

    print('🔔 Daily log reminder scheduled for: $scheduledDateTime');
  }

  /// Schedule fertile window notification
  Future<void> scheduleFertileWindowNotification({
    required DateTime fertileStartDate,
    int notificationId = 3000,
  }) async {
    if (!_isInitialized) await initialize();

    final scheduledDateTime = tz.TZDateTime.from(
      DateTime(
        fertileStartDate.year,
        fertileStartDate.month,
        fertileStartDate.day,
        10,
        0,
      ),
      tz.local,
    );

    if (scheduledDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('🔔 Skipping past date notification: $scheduledDateTime');
      return;
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _cycleTrackingChannelId,
        'Cycle Tracking',
        channelDescription: 'General cycle tracking reminders',
        importance: Importance.defaultImportance,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'fertile_window',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      notificationId,
      '🌱 Fertile Window',
      'Your fertile window is starting. Track any changes! 🌸',
      scheduledDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'fertile_window_$notificationId',
    );

    print('🔔 Fertile window notification scheduled for: $scheduledDateTime');
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
    print('🔔 Cancelled notification: $notificationId');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🔔 Cancelled all notifications');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
    int notificationId = 0,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _cycleTrackingChannelId,
        'Cycle Tracking',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    print('🔔 Immediate notification shown: $title');
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _cycleTrackingChannelId,
        'Cycle Tracking',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    print('🔔 Notification shown: $title');
  }

  /// Test notification function - shows immediate notification for testing
  Future<void> testNotification() async {
    await showImmediateNotification(
      title: '🧪 Test Notification',
      body: 'If you see this, notifications are working! 🎉',
      payload: 'test_notification',
      notificationId: 9999,
    );
  }

  /// Check notification permissions and system status
  Future<Map<String, dynamic>> getNotificationStatus() async {
    if (!_isInitialized) await initialize();

    final isEnabled = await areNotificationsEnabled();
    final pendingNotifications = await getPendingNotifications();

    return {
      'is_initialized': _isInitialized,
      'permissions_granted': isEnabled,
      'pending_notifications_count': pendingNotifications.length,
      'pending_notifications': pendingNotifications
          .map((n) => {'id': n.id, 'title': n.title, 'body': n.body})
          .toList(),
      'platform': Platform.isAndroid
          ? 'Android'
          : (Platform.isIOS ? 'iOS' : 'Other'),
    };
  }
}
