import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/notification_provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../l10n/app_localizations_sn.dart';
import 'insights_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Helper method to get the correct localizations based on user's language choice
  AppLocalizations _getLocalizations(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    if (languageProvider.locale.languageCode == 'sn') {
      return AppLocalizationsSn();
    } else {
      return AppLocalizationsEn();
    }
  }

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
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
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
                            _buildProductGuideSection(),
                            const SizedBox(height: 30),
                            _buildHealthInsights(),
                            const SizedBox(height: 30),
                            _buildTodaysReminders(),
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
    final unreadCount = 2; // Mock count for now, will integrate with real notifications later

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu/Profile
          Container(
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
              Icons.menu,
              color: isDarkMode ? Colors.white : Colors.black87,
              size: 20,
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
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/notification-settings');
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
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      size: 20,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
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
    final ovulationDay = cycleLength - 14; // Approximately 14 days before next period
    
    final daysToOvulation = ovulationDay - currentDay;
    return daysToOvulation > 0 ? daysToOvulation : 0;
  }

  double _getOvulationProgress(CycleProvider cycleProvider) {
    final cycleLength = cycleProvider.averageCycleLength;
    final currentDay = cycleProvider.currentCycleDay;
    return (currentDay / cycleLength).clamp(0.0, 1.0);
  }
  }

  }

  Widget _buildProductGuideSection() {

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
            // First card - smaller with icons and +6
            Expanded(
              flex: 1,
              child: _buildInsightCard1(isDarkMode),
            ),
            const SizedBox(width: 12),
            // Second card - Today's Cycle Day
            Expanded(
              flex: 1,
              child: _buildInsightCard2(isDarkMode),
            ),
            const SizedBox(width: 12),
            // Third card - Pregnancy or PMS
            Expanded(
              flex: 1,
              child: _buildInsightCard3(isDarkMode),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard1(bool isDarkMode) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF374151) 
            : const Color(0xFF6B7280),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.pink,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.mood,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+6',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard2(bool isDarkMode) {
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Text(
            'Cycle Day',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            '${cycleProvider.currentCycleDay}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard3(bool isDarkMode) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF59E0B),
            const Color(0xFFEF4444),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregnancy or',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Just PMS?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Illustration placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.pregnant_woman,
              color: Colors.white.withOpacity(0.8),
              size: 24,
            ),
          ),
        ],
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
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: isDarkMode
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
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
                              'Product Guides & Instructions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Discover helpful products and learn how to use them effectively for your menstrual health.',
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Product Catalog',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Usage Instructions',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.tips_and_updates_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Expert Tips',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const InsightsScreen(),
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: const Text(
                        'Explore Products',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.3),
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
    final containerColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.9);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.2)
        : Colors.grey.withOpacity(0.3);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);
    final textColor = isDarkMode
        ? Colors.white.withOpacity(0.9)
        : const Color(0xFF4A5568);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2000),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: const Text('💡', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Today\'s Insight',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _getTodaysInsight(),
                  style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodaysReminders() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = Colors.white;
    final textColor = Colors.white.withOpacity(0.9);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final cycleProvider = Provider.of<CycleProvider>(context);

    // Get personalized reminders based on cycle phase and notifications
    final reminders = _getPersonalizedReminders(
      cycleProvider,
      notificationProvider,
    );

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
                  colors: isDarkMode
                      ? [
                          Colors.indigo.withOpacity(0.8),
                          Colors.blue.withOpacity(0.8),
                        ]
                      : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RotationTransition(
                        turns: _rotateAnimation,
                        child: const Text('🔔', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Gentle Reminders',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/notification-settings',
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...reminders
                      .map(
                        (reminder) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildReminderItem(
                            reminder['emoji'] as String,
                            reminder['text'] as String,
                            textColor,
                          ),
                        ),
                      )
                      ,
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, Beautiful! ☀️';
    if (hour < 17) return 'Good Afternoon, Lovely! 🌤️';
    return 'Good Evening, Gorgeous! 🌙';
  }

  String _getCurrentPhase(CycleProvider cycleProvider) {
    final day = cycleProvider.currentCycleDay;
    if (day <= 5) return 'Menstrual';
    if (day <= 13) return 'Follicular';
    if (day <= 16) return 'Ovulation';
    return 'Luteal';
  }

  String _getPhaseEmoji(CycleProvider cycleProvider) {
    final day = cycleProvider.currentCycleDay;
    if (day <= 5) return '🩸';
    if (day <= 13) return '🌱';
    if (day <= 16) return '🌟';
    return '🌙';
  }

  String _getTodaysInsight() {
    final insights = [
      'Your body is amazing! Every cycle is a testament to its incredible capabilities. 💪',
      'Remember to listen to your body and give it the care it deserves. 🌺',
      'Tracking your cycle helps you understand your body\'s natural rhythm. 🎵',
      'Self-care isn\'t selfish - it\'s essential for your wellbeing. 🛁',
      'You\'re doing great by taking charge of your health! 🌟',
      'Every day is a new opportunity to nurture yourself. 🌸',
      'Your menstrual cycle is a superpower - embrace it! ✨',
    ];
    return insights[DateTime.now().day % insights.length];
  }

  String _getNextPeriodLabel(CycleProvider cycleProvider) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final isShona = languageProvider.locale.languageCode == 'sn';

    // Get localizations with fallback
    AppLocalizations? localizations;
    try {
      localizations = _getLocalizations(context);
    } catch (e) {
      localizations = null;
    }

    final daysUntil = cycleProvider.daysUntilNextPeriod;

    if (daysUntil == 0) {
      return isShona ? 'Nhasi' : 'Today';
    }
    if (daysUntil == 1) {
      return isShona ? 'Mangwana' : 'Tomorrow';
    }
    if (daysUntil <= 7) {
      final daysText = localizations?.daysAway ?? 'days';
      return '$daysUntil $daysText';
    }
    if (daysUntil <= 14) {
      final weekText = isShona ? 'vhiki' : 'week';
      final weeksText = isShona ? 'mavhiki' : 'weeks';
      final weekCount = (daysUntil / 7).round();
      return '$weekCount ${weekCount > 1 ? weeksText : weekText}';
    }
    final daysText = localizations?.daysAway ?? 'days';
    return '$daysUntil $daysText';
  }

  String _getNextPeriodEmoji(CycleProvider cycleProvider) {
    final daysUntil = cycleProvider.daysUntilNextPeriod;
    if (daysUntil == 0) return '🩸';
    if (daysUntil <= 3) return '⏰';
    if (daysUntil <= 7) return '📅';
    if (daysUntil <= 14) return '🌸';
    return '🗓️';
  }

  List<Map<String, String>> _getPersonalizedReminders(
    CycleProvider cycleProvider,
    NotificationProvider notificationProvider,
  ) {
    final phase = _getCurrentPhase(cycleProvider);
    final daysUntilPeriod = cycleProvider.daysUntilNextPeriod;

    List<Map<String, String>> reminders = [];

    // Phase-specific reminders
    switch (phase) {
      case 'Menstrual':
        reminders.addAll([
          {'emoji': '🔥', 'text': 'Use a heating pad for cramps relief'},
          {'emoji': '🍫', 'text': 'Dark chocolate can help with mood'},
          {'emoji': '😴', 'text': 'Get extra rest - your body is working hard'},
        ]);
        break;
      case 'Follicular':
        reminders.addAll([
          {'emoji': '🥗', 'text': 'Focus on iron-rich foods to rebuild'},
          {'emoji': '💪', 'text': 'Great time to start new fitness routines'},
          {'emoji': '🎯', 'text': 'Perfect for planning and goal setting'},
        ]);
        break;
      case 'Ovulation':
        reminders.addAll([
          {
            'emoji': '✨',
            'text': 'You\'re at peak energy - make the most of it!',
          },
          {'emoji': '💼', 'text': 'Ideal time for important meetings'},
          {'emoji': '🌟', 'text': 'Your confidence is naturally higher'},
        ]);
        break;
      case 'Luteal':
        reminders.addAll([
          {'emoji': '🧘‍♀️', 'text': 'Practice relaxation techniques'},
          {'emoji': '📝', 'text': 'Good time for organizing and planning'},
          {'emoji': '🌙', 'text': 'Listen to your body\'s signals'},
        ]);
        break;
    }

    // Period prediction reminders
    if (daysUntilPeriod <= 3 && daysUntilPeriod > 0) {
      reminders.add({
        'emoji': '📅',
        'text': 'Period expected in $daysUntilPeriod days - prepare supplies',
      });
    }

    // Notification-based reminders
    if (notificationProvider.isPeriodReminderEnabled) {
      reminders.add({
        'emoji': '📝',
        'text': 'Log your daily symptoms and mood',
      });
    }

    if (notificationProvider.isDailyLogReminderEnabled) {
      reminders.add({
        'emoji': '💧',
        'text': 'Don\'t forget your daily log entry',
      });
    }

    // General wellness reminders
    reminders.addAll([
      {'emoji': '💧', 'text': 'Stay hydrated - drink 8 glasses of water'},
      {'emoji': '🌸', 'text': 'You\'re amazing just as you are!'},
    ]);

    // Limit to 4 most relevant reminders
    return reminders.take(4).toList();
  }
}
