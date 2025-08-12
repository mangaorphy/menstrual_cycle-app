import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    if (!notificationProvider.isInitialized) {
      await notificationProvider.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return TextButton(
                onPressed: () => _testNotification(notificationProvider),
                child: Text(
                  'Test',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (!notificationProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Stay on track with gentle reminders 💕',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize when you want to receive notifications about your cycle.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 30),

                // Period Reminders Section
                _buildSectionCard(
                  title: 'Period Reminders',
                  icon: Icons.calendar_month,
                  iconColor: Colors.pinkAccent,
                  children: [
                    _buildSwitchTile(
                      title: 'Period Reminders',
                      subtitle: 'Get notified before your period arrives',
                      value: notificationProvider.isPeriodReminderEnabled,
                      onChanged: (value) =>
                          notificationProvider.togglePeriodReminder(value),
                    ),
                    if (notificationProvider.isPeriodReminderEnabled) ...[
                      const SizedBox(height: 16),
                      _buildReminderDaysSelector(notificationProvider),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                // Daily Log Reminders Section
                _buildSectionCard(
                  title: 'Daily Reminders',
                  icon: Icons.edit_note,
                  iconColor: Colors.purple,
                  children: [
                    _buildSwitchTile(
                      title: 'Daily Log Reminders',
                      subtitle: 'Remind me to log my daily symptoms and mood',
                      value: notificationProvider.isDailyLogReminderEnabled,
                      onChanged: (value) =>
                          notificationProvider.toggleDailyLogReminder(value),
                    ),
                    if (notificationProvider.isDailyLogReminderEnabled) ...[
                      const SizedBox(height: 16),
                      _buildTimeSelector(notificationProvider),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                // Fertile Window Section
                _buildSectionCard(
                  title: 'Fertile Window',
                  icon: Icons.eco,
                  iconColor: Colors.green,
                  children: [
                    _buildSwitchTile(
                      title: 'Fertile Window Reminders',
                      subtitle: 'Get notified when your fertile window starts',
                      value:
                          notificationProvider.isFertileWindowReminderEnabled,
                      onChanged: (value) => notificationProvider
                          .toggleFertileWindowReminder(value),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Notification Status
                _buildNotificationStatus(notificationProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildReminderDaysSelector(NotificationProvider notificationProvider) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remind me',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4, 5].map((days) {
            final isSelected = notificationProvider.periodReminderDays == days;
            return GestureDetector(
              onTap: () => notificationProvider.setPeriodReminderDays(days),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                  ),
                ),
                child: Text(
                  '$days day${days == 1 ? '' : 's'} before',
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(NotificationProvider notificationProvider) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder time',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectTime(notificationProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  notificationProvider.formatTime(
                    notificationProvider.dailyLogReminderTime,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationStatus(NotificationProvider notificationProvider) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            'Notification Status',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FutureBuilder<int>(
            future: notificationProvider.getPendingNotificationsCount(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  '${snapshot.data} notifications scheduled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                );
              }
              return Text(
                'Loading...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(NotificationProvider notificationProvider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: notificationProvider.dailyLogReminderTime,
      helpText: 'Select reminder time',
    );

    if (picked != null) {
      await notificationProvider.setDailyLogReminderTime(picked);
      // Reschedule daily reminders with new time
      await notificationProvider.scheduleDailyLogReminders();
    }
  }

  Future<void> _testNotification(
    NotificationProvider notificationProvider,
  ) async {
    await notificationProvider.testNotification();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent! 🔔'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
