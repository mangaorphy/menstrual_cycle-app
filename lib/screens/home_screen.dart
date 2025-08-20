import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
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
                      const SizedBox(height: 20),
                      _buildAnimatedGreeting(),
                      const SizedBox(height: 30),
                      _buildCycleOverview(cycleProvider),
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
    );
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
    );
  }

  Widget _buildCycleOverview(CycleProvider cycleProvider) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.withOpacity(0.8),
              Colors.purple.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getLocalizations(context).cycleOverview,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                RotationTransition(
                  turns: _rotateAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sync,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: _buildCycleInfo(
                    'Day',
                    '${cycleProvider.currentCycleDay}',
                    'of ${cycleProvider.averageCycleLength}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white.withOpacity(0.3),
                ),
                Flexible(
                  flex: 2,
                  child: _buildCycleInfo(
                    'Phase',
                    _getCurrentPhase(cycleProvider),
                    _getPhaseEmoji(cycleProvider),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white.withOpacity(0.3),
                ),
                Flexible(
                  flex: 2,
                  child: _buildCycleInfo(
                    _getLocalizations(context).nextPeriod,
                    _getNextPeriodLabel(cycleProvider),
                    _getNextPeriodEmoji(cycleProvider),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleInfo(String label, String value, String subtitle) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);
    final cardColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.9);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);

    // Get localizations with fallback
    AppLocalizations? localizations;
    try {
      localizations = _getLocalizations(context);
    } catch (e) {
      localizations = null;
    }

    final actions = [
      {
        'title': localizations?.logPeriod ?? 'Log Period',
        'icon': Icons.water_drop,
        'color': Colors.red,
        'emoji': '🩸',
        'onTap': () => Navigator.pushNamed(context, '/log-period'),
      },
      {
        'title': localizations?.logMood ?? 'Track Mood',
        'icon': Icons.mood,
        'color': Colors.orange,
        'emoji': '😊',
        'onTap': () => Navigator.pushNamed(context, '/log-mood'),
      },
      {
        'title': localizations?.logSymptoms ?? 'Symptoms',
        'icon': Icons.health_and_safety,
        'color': Colors.green,
        'emoji': '💊',
        'onTap': () => Navigator.pushNamed(context, '/log-symptoms'),
      },
      {
        'title': 'Flow',
        'icon': Icons.trending_up,
        'color': Colors.blue,
        'emoji': '📈',
        'onTap': () => Navigator.pushNamed(context, '/log-flow'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(width: 10),
            const Text('✨', style: TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Material(
              elevation: 4,
              shadowColor: (action['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: action['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cardColor, cardColor],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: (action['color'] as Color).withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: isDarkMode
                        ? [
                            BoxShadow(
                              color: (action['color'] as Color).withOpacity(
                                0.1,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: (action['color'] as Color).withOpacity(
                                0.15,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container with gradient background
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                (action['color'] as Color).withOpacity(0.2),
                                (action['color'] as Color).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (action['color'] as Color).withOpacity(
                                0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                action['emoji'] as String,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 2),
                              Icon(
                                action['icon'] as IconData,
                                color: action['color'] as Color,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Title with better styling
                        Text(
                          action['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReminderItem(
                    '💧',
                    'Stay hydrated - drink 8 glasses of water',
                    textColor,
                  ),
                  const SizedBox(height: 8),
                  _buildReminderItem(
                    '🧘‍♀️',
                    'Take a moment for mindfulness',
                    textColor,
                  ),
                  const SizedBox(height: 8),
                  _buildReminderItem(
                    '📝',
                    'Log your symptoms and mood',
                    textColor,
                  ),
                  const SizedBox(height: 8),
                  _buildReminderItem(
                    '🌸',
                    'You\'re amazing just as you are!',
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
}
