import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/education_provider.dart';
import '../widgets/insights_widgets.dart';
import 'products_guide_screen.dart';
import 'quiz_list_screen.dart';
import 'video_library_screen.dart';

class InsightsScreen extends StatefulWidget {
  final int initialTabIndex;

  const InsightsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cycleProvider = Provider.of<CycleProvider>(context);
    final educationProvider = Provider.of<EducationProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Journey',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Insights & Education',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Personalized Dashboard
                PersonalizedDashboard(
                  cycleProvider: cycleProvider,
                  theme: theme,
                ),

                const SizedBox(height: 24),

                // Quick Access Section
                Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                _buildQuickAccessGrid(educationProvider, theme),

                const SizedBox(height: 24),

                // Learning Journey
                Text(
                  'Your Learning Journey',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                _buildLearningJourney(educationProvider, theme),

                const SizedBox(height: 24),

                // Health Insights
                Text(
                  'Health Insights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                _buildHealthInsights(cycleProvider, theme),

                const SizedBox(height: 100), // Bottom padding for FAB
              ]),
            ),
          ),
        ],
      ),

      // Floating Action Button for quick learning
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickLearningModal(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.school),
        label: Text('Quick Learn'),
      ),
    );
  }

  Widget _buildQuickAccessGrid(
    EducationProvider educationProvider,
    ThemeData theme,
  ) {
    final quickActions = [
      {
        'title': 'Period Products',
        'description': 'Learn about different options',
        'icon': Icons.inventory_2,
        'color': Colors.pink,
        'badge': _buildNewBadge(),
        'onTap': () => _navigateToProductsTab(),
      },
      {
        'title': 'Cycle Quiz',
        'description': 'Test your knowledge',
        'icon': Icons.quiz,
        'color': Colors.purple,
        'badge': _buildProgressBadge(
          educationProvider.getOverallQuizProgress(),
        ),
        'onTap': () => _navigateToQuiz(),
      },
      {
        'title': 'Educational Videos',
        'description': 'Watch and learn',
        'icon': Icons.play_circle_filled,
        'color': Colors.blue,
        'badge': _buildWatchTimeBadge(educationProvider.getTotalWatchTime()),
        'onTap': () => _navigateToVideos(),
      },
      {
        'title': 'Health Resources',
        'description': 'Expert advice & tips',
        'icon': Icons.health_and_safety,
        'color': Colors.green,
        'badge': null,
        'onTap': () => _navigateToResources(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12, // Reduced spacing
        mainAxisSpacing: 12, // Reduced spacing
        childAspectRatio: 1.0, // Better ratio to prevent overflow
      ),
      itemCount: quickActions.length,
      itemBuilder: (context, index) {
        final action = quickActions[index];
        return InteractiveContentCard(
          title: action['title'] as String,
          description: action['description'] as String,
          icon: action['icon'] as IconData,
          color: action['color'] as Color,
          onTap: action['onTap'] as VoidCallback,
          badge: action['badge'] as Widget?,
        );
      },
    );
  }

  Widget _buildLearningJourney(
    EducationProvider educationProvider,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.1), Colors.red.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildProgressItem(
            'Quizzes Completed',
            educationProvider.getCompletedQuizCount(),
            educationProvider.getTotalQuizCount(),
            Colors.purple,
            theme,
          ),
          const SizedBox(height: 12),

          _buildProgressItem(
            'Videos Watched',
            educationProvider.getWatchedVideoCount(),
            educationProvider.getTotalVideoCount(),
            Colors.blue,
            theme,
          ),
          const SizedBox(height: 12),

          _buildProgressItem(
            'Resources Explored',
            educationProvider.getExploredResourceCount(),
            educationProvider.getTotalResourceCount(),
            Colors.green,
            theme,
          ),

          const SizedBox(height: 16),

          _buildAchievementBadges(educationProvider, theme),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    String label,
    int completed,
    int total,
    Color color,
    ThemeData theme,
  ) {
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '$completed/$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildAchievementBadges(
    EducationProvider educationProvider,
    ThemeData theme,
  ) {
    final achievements = educationProvider.getUnlockedAchievements();

    if (achievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Complete activities to unlock achievements!',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      children: achievements
          .map(
            (achievement) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏆', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    achievement,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHealthInsights(CycleProvider cycleProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Cycle Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildAnalyticCard(
                  'Avg Cycle',
                  '${cycleProvider.averageCycleLength} days',
                  _getCycleHealthStatus(cycleProvider.averageCycleLength),
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticCard(
                  'Regularity',
                  _getCycleRegularity(cycleProvider),
                  _getRegularityStatus(cycleProvider),
                  theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildInsightTip(cycleProvider, theme),
        ],
      ),
    );
  }

  Widget _buildAnalyticCard(
    String label,
    String value,
    String status,
    ThemeData theme,
  ) {
    final statusColor = status == 'Normal'
        ? Colors.green
        : status == 'Irregular'
        ? Colors.orange
        : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTip(CycleProvider cycleProvider, ThemeData theme) {
    final tip = _getPersonalizedTip(cycleProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insight for You',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Badge widgets
  Widget _buildNewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProgressBadge(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(progress * 100).toInt()}%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWatchTimeBadge(int minutes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${minutes}m',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToProductsTab() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductsGuideScreen()),
    );
  }

  void _navigateToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizListScreen()),
    );
  }

  void _navigateToVideos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoLibraryScreen()),
    );
  }

  void _navigateToResources() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Navigating to Resources...')));
  }

  void _showQuickLearningModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Quick Learning',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildQuickLearningItem(
                        'Menstrual Cycle Basics',
                        'Learn the fundamentals in 5 minutes',
                        Icons.school,
                        Colors.blue,
                      ),
                      _buildQuickLearningItem(
                        'Period Product Guide',
                        'Quick comparison of all options',
                        Icons.inventory,
                        Colors.pink,
                      ),
                      _buildQuickLearningItem(
                        'Tracking Your Symptoms',
                        'What to log and why it matters',
                        Icons.analytics,
                        Colors.green,
                      ),
                      _buildQuickLearningItem(
                        'Myths vs Facts',
                        'Common misconceptions debunked',
                        Icons.fact_check,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickLearningItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          // Navigate to specific learning content
        },
      ),
    );
  }

  // Helper methods
  String _getCycleHealthStatus(int avgLength) {
    if (avgLength >= 21 && avgLength <= 35) return 'Normal';
    if (avgLength < 21) return 'Short';
    return 'Long';
  }

  String _getCycleRegularity(CycleProvider cycleProvider) {
    if (cycleProvider.cycles.length < 3) return 'Need more data';
    return 'Regular'; // Simplified for now
  }

  String _getRegularityStatus(CycleProvider cycleProvider) {
    return 'Normal'; // Simplified for now
  }

  String _getPersonalizedTip(CycleProvider cycleProvider) {
    final day = cycleProvider.currentCycleDay;
    if (day <= 5) {
      return 'Focus on iron-rich foods to replenish what you lose during menstruation.';
    } else if (day <= 13) {
      return 'Great time to start new habits - your energy is naturally increasing!';
    } else if (day <= 16) {
      return 'Peak fertility window. Your body temperature may be slightly higher.';
    } else {
      return 'PMS symptoms are common now. Try stress-reduction techniques.';
    }
  }
}
