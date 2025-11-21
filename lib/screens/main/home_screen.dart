import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/chat/chatbot_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _rotateController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotateController);

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Start animations
    _slideController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF000000), // Pure black at top
                    const Color(0xFF0A0A0A), // Very dark gray
                    const Color(0xFF1A1A1A), // Dark gray at bottom
                  ]
                : [
                    const Color(0xFFF7FAFC),
                    const Color(0xFFEDF2F7),
                    const Color(0xFFE2E8F0),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Floating background elements
            _buildFloatingElements(),
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  _buildCustomAppBar(),
                  // Login Reminder Banner
                  _buildLoginReminderBanner(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAnimatedGreeting(),
                            const SizedBox(height: 30),
                            _buildCycleOverview(cycleProvider),
                            const SizedBox(height: 20),
                            _buildCycleStatsBar(cycleProvider),
                            const SizedBox(height: 30),
                            _buildQuickActions(),
                            const SizedBox(height: 30),
                            _buildChatbotSection(),
                            const SizedBox(height: 30),
                            _buildProductGuideSection(),
                            const SizedBox(height: 30),
                            _buildHealthInsights(),
                            const SizedBox(height: 30),
                            _buildTodaysReminders(),
                            // Extra spacing for curved bottom navigation
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu/Profile
          GestureDetector(
            onTap: () {
              Provider.of<NavigationProvider>(
                context,
                listen: false,
              ).navigateToInsights();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.insights,
                color: isDarkMode ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
          ),

          // Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 8),
                Text(
                  _getCurrentDate(),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Notification bell with badge
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: isDarkMode ? Colors.white : Color(0xFF7B6F72),
                ),
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, child) {
                    final unreadCount = notificationProvider.unreadCount;
                    if (unreadCount > 0) {
                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6B9D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}';
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Floating element 1
        Positioned(
          top: 100,
          right: 50,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: Opacity(
              opacity: 0.3,
              child: Text('🌙', style: TextStyle(fontSize: 40)),
            ),
          ),
        ),
        // Floating element 2
        Positioned(
          top: 200,
          left: 30,
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Opacity(
              opacity: 0.2,
              child: Text('⭐', style: TextStyle(fontSize: 30)),
            ),
          ),
        ),
        // Floating element 3
        Positioned(
          top: 400,
          right: 20,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: Opacity(
              opacity: 0.25,
              child: Text('🌸', style: TextStyle(fontSize: 35)),
            ),
          ),
        ),
        // Floating element 4
        Positioned(
          bottom: 200,
          left: 40,
          child: ScaleTransition(
            scale: _bounceAnimation,
            child: Opacity(
              opacity: 0.2,
              child: Text('💫', style: TextStyle(fontSize: 25)),
            ),
          ),
        ),
        // Floating element 5
        Positioned(
          bottom: 300,
          right: 60,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: Opacity(
              opacity: 0.15,
              child: Text('🦋', style: TextStyle(fontSize: 45)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedGreeting() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : const Color(0xFF2D3748);
    final secondaryTextColor = isDarkMode
        ? Colors.white.withOpacity(0.8)
        : const Color(0xFF4A5568);
    final containerColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.9);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.2)
        : Colors.grey.withOpacity(0.3);

    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: () {
          // Navigate to Calendar tab
          Provider.of<NavigationProvider>(
            context,
            listen: false,
          ).navigateToCalendar();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: isDarkMode
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            _getGreeting(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1200),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            'How are you feeling today?',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    // Floating emojis around the heart
                    Positioned(
                      top: -10,
                      right: -5,
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: const Text('✨', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      left: -10,
                      child: RotationTransition(
                        turns: _rotateAnimation,
                        child: const Text('🌸', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: -15,
                      child: ScaleTransition(
                        scale: _bounceAnimation,
                        child: const Text('💖', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  Widget _buildCycleOverview(CycleProvider cycleProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ovulationDays = _calculateOvulationDays(cycleProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF4C1D95), // Deep purple
                  const Color(0xFF6B21A8), // Purple
                  const Color(0xFF7C3AED), // Bright purple
                ]
              : [
                  const Color(0xFF6366F1), // Indigo
                  const Color(0xFF8B5CF6), // Violet
                  const Color(0xFFA855F7), // Purple
                ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.purple.withOpacity(0.3)
                : Colors.indigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main ovulation info
          Text(
            'Ovulation in',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Days count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$ovulationDays',
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Days',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Pregnancy chance
          Text(
            'Chance to get Pregnant',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 20),

          // Progress indicator
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _getOvulationProgress(cycleProvider),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateOvulationDays(CycleProvider cycleProvider) {
    // Ovulation typically occurs around day 14 of a 28-day cycle
    final cycleLength = cycleProvider.averageCycleLength;
    final currentDay = cycleProvider.currentCycleDay;
    final ovulationDay =
        cycleLength - 14; // Approximately 14 days before next period

    final daysToOvulation = ovulationDay - currentDay;
    return daysToOvulation > 0 ? daysToOvulation : 0;
  }

  double _getOvulationProgress(CycleProvider cycleProvider) {
    final cycleLength = cycleProvider.averageCycleLength;
    final currentDay = cycleProvider.currentCycleDay;
    return (currentDay / cycleLength).clamp(0.0, 1.0);
  }

  Widget _buildCycleStatsBar(CycleProvider cycleProvider) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final avgCycleLength = cycleProvider.averageCycleLength;
    final cycleHistoryCount = cycleProvider.cycles.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.grey.withOpacity(0.3),
        ),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Avg. Cycle',
            '$avgCycleLength days',
            Icons.sync_rounded,
            Colors.purple,
            isDarkMode,
          ),
          Container(
            width: 1,
            height: 40,
            color: (isDarkMode ? Colors.white : Colors.grey).withOpacity(0.3),
          ),
          _buildStatItem(
            'Cycles Tracked',
            '$cycleHistoryCount',
            Icons.history_rounded,
            Colors.pink,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: (isDarkMode ? Colors.white : const Color(0xFF2D3748))
                  .withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Daily Insights',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildLogPeriodCard(isDarkMode)),
            const SizedBox(width: 12),
            Expanded(child: _buildLogFlowCard(isDarkMode)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLogMoodCard(isDarkMode)),
            const SizedBox(width: 12),
            Expanded(child: _buildLogSymptomsCard(isDarkMode)),
          ],
        ),
      ],
    );
  }

  Widget _buildLogPeriodCard(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/log-period');
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFF6B7280),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              'Log Period',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogFlowCard(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/log-flow');
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              'Log Flow',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogMoodCard(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/log-mood');
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mood, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              'Log Mood',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogSymptomsCard(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/log-symptoms');
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF10B981), const Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              'Log Symptoms',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGuideSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.9);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.2)
        : Colors.grey.withOpacity(0.3);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);
    final textColor = isDarkMode
        ? Colors.white.withOpacity(0.8)
        : const Color(0xFF4A5568);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Guide',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Watch our video guide to learn more about different types of period products and find the best one for you.',
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1599420186946-7b6fb4e297f0?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthInsights() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildInsightRow(
          'Understanding Your Cycle',
          'Learn about the different phases and what they mean for your body.',
          Icons.book_outlined,
          Colors.teal,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildInsightRow(
          'Nutrition Tips for Your Phase',
          'Discover foods that can help you feel your best throughout your cycle.',
          Icons.restaurant_menu_outlined,
          Colors.orange,
          isDarkMode,
        ),
        const SizedBox(height: 12),
        _buildInsightRow(
          'Exercise and Your Cycle',
          'Find out the best workouts for each phase to maximize your energy.',
          Icons.fitness_center_outlined,
          Colors.blue,
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildInsightRow(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    final containerColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.9);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.2)
        : Colors.grey.withOpacity(0.3);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);
    final subtitleColor = isDarkMode
        ? Colors.white.withOpacity(0.8)
        : const Color(0xFF4A5568);

    return GestureDetector(
      onTap: () {
        // Navigate to specific health topic or insights
        Provider.of<NavigationProvider>(
          context,
          listen: false,
        ).navigateToInsights();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: subtitleColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysReminders() {
    final titleColor = Colors.white;
    final textColor = Colors.white.withOpacity(0.9);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2200),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade300, Colors.purple.shade300],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gentle Reminders',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/notification-settings',
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReminderItem('💧', 'Stay hydrated today', textColor),
                  const SizedBox(height: 12),
                  _buildReminderItem(
                    '🧘‍♀️',
                    'Take a moment for yourself',
                    textColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReminderItem(String emoji, String text, Color textColor) {
    return Row(
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 14, color: textColor)),
        ),
      ],
    );
  }

  Widget _buildLoginReminderBanner() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Only show banner if user is not logged in
        if (authProvider.isAuthenticated) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cloud_upload,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backup Your Data',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to securely backup your cycle data and sync across devices',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatbotSection() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.05),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ask MenstruAI',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get instant answers about your cycle, symptoms, and health',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chatbot Widget
          Container(
            height: 400, // Fixed height for the chat interface
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const ChatbotWidget(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
