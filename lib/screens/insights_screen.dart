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
  late TextEditingController _searchController;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Search
            _buildCustomAppBar(theme),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Topics Section
                    _buildQuickTopicsSection(theme),
                    const SizedBox(height: 30),
                    
                    // Reproductive Health 101
                    _buildReproductiveHealthSection(theme),
                    const SizedBox(height: 30),
                    
                    // Sex Section
                    _buildSexSection(theme),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // App Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Search Bar
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Bookmark Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.3),
              ),
            ),
            child: Icon(
              Icons.bookmark_border,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Notification Icon with Badge
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.notifications_none,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTopicsSection(ThemeData theme) {
    final topics = [
      {
        'title': 'Am I\npregnant?',
        'icon': Icons.pregnant_woman_outlined,
        'color': Colors.blue,
      },
      {
        'title': 'Orgasms\nand pleasure',
        'icon': Icons.favorite_outline,
        'color': Colors.pink,
      },
      {
        'title': 'Vaginal\ndischarge',
        'icon': Icons.water_drop_outlined,
        'color': Colors.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: topics.map((topic) {
            return _buildTopicCard(
              topic['title'] as String,
              topic['icon'] as IconData,
              topic['color'] as Color,
              theme,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopicCard(String title, IconData icon, Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReproductiveHealthSection(ThemeData theme) {
    final articles = [
      {
        'title': 'How to clean your\nvulva',
        'color': const Color(0xFFFFB5A7),
        'image': 'vulva_care',
      },
      {
        'title': 'Early signs of\npregnancy',
        'color': const Color(0xFFFFC1A8),
        'image': 'pregnancy_signs',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reproductive health 101',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: articles.map((article) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: articles.last == article ? 0 : 12),
                height: 180,
                decoration: BoxDecoration(
                  color: article['color'] as Color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        article['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSexSection(ThemeData theme) {
    final sexTopics = [
      {
        'title': '9 life-changing\nmasturbation tips',
        'color': const Color(0xFFE6D7FF),
        'type': 'article',
      },
      {
        'title': 'How to choose\nyour first sex toy',
        'color': const Color(0xFFFF9FE5),
        'type': 'video',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sex',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: sexTopics.map((topic) {
            final isVideo = topic['type'] == 'video';
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: sexTopics.last == topic ? 0 : 12),
                height: 180,
                decoration: BoxDecoration(
                  color: topic['color'] as Color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    if (isVideo)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.pink,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Video',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.pink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Text(
                        topic['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isSearching = true;
                                  });
                                },
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search insights, videos, quizzes...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isSearching = false;
                                      _searchQuery = '';
                                      _searchController.clear();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                        ],
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
                // Search Results or Regular Content
                if (_isSearching && _searchQuery.isNotEmpty)
                  _buildSearchResults(educationProvider, theme)
                else if (_isSearching && _searchQuery.isEmpty)
                  _buildSearchSuggestions(theme)
                else ...[
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
                ],
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

  Widget _buildSearchResults(
    EducationProvider educationProvider,
    ThemeData theme,
  ) {
    final searchableContent = _getSearchableContent();
    final filteredContent = searchableContent
        .where(
          (item) =>
              item['title'].toLowerCase().contains(_searchQuery) ||
              item['description'].toLowerCase().contains(_searchQuery) ||
              item['category'].toLowerCase().contains(_searchQuery),
        )
        .toList();

    if (filteredContent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or browse categories below',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results (${filteredContent.length})',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...filteredContent.map((item) => _buildSearchResultCard(item, theme)),
      ],
    );
  }

  Widget _buildSearchSuggestions(ThemeData theme) {
    final suggestions = [
      'Period tracking tips',
      'Menstrual cup guide',
      'Tampon safety',
      'Cycle phases',
      'PMS remedies',
      'Iron-rich foods',
      'Exercise during periods',
      'Mood tracking',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .map(
                (suggestion) => GestureDetector(
                  onTap: () {
                    _searchController.text = suggestion;
                    setState(() {
                      _searchQuery = suggestion.toLowerCase();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> item, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => item['onTap'](),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item['icon'], color: item['color'], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['category'],
                    style: TextStyle(
                      fontSize: 12,
                      color: item['color'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSearchableContent() {
    return [
      {
        'title': 'Period Products Guide',
        'description':
            'Learn about tampons, pads, cups and how to use them safely',
        'category': 'Products',
        'icon': Icons.inventory_2,
        'color': Colors.purple,
        'onTap': () => _navigateToProductsTab(),
      },
      {
        'title': 'Knowledge Quizzes',
        'description': 'Test your understanding with interactive quizzes',
        'category': 'Education',
        'icon': Icons.quiz,
        'color': Colors.blue,
        'onTap': () => _navigateToQuiz(),
      },
      {
        'title': 'Video Library',
        'description': 'Educational videos about menstrual health',
        'category': 'Videos',
        'icon': Icons.play_circle,
        'color': Colors.red,
        'onTap': () => _navigateToVideos(),
      },
      {
        'title': 'Tampon Safety Guide',
        'description': 'Step-by-step instructions for safe tampon use',
        'category': 'Products',
        'icon': Icons.health_and_safety,
        'color': Colors.orange,
        'onTap': () => _navigateToProductsTab(),
      },
      {
        'title': 'Menstrual Cup Tutorial',
        'description': 'Complete guide to using menstrual cups',
        'category': 'Products',
        'icon': Icons.eco,
        'color': Colors.green,
        'onTap': () => _navigateToProductsTab(),
      },
      {
        'title': 'Cycle Tracking Tips',
        'description': 'Learn effective ways to track your menstrual cycle',
        'category': 'Education',
        'icon': Icons.trending_up,
        'color': Colors.teal,
        'onTap': () => _navigateToQuiz(),
      },
      {
        'title': 'PMS Management',
        'description': 'Natural remedies and tips for managing PMS symptoms',
        'category': 'Health',
        'icon': Icons.spa,
        'color': Colors.indigo,
        'onTap': () => _navigateToVideos(),
      },
      {
        'title': 'Iron-Rich Foods',
        'description': 'Nutrition guide for healthy periods',
        'category': 'Nutrition',
        'icon': Icons.restaurant,
        'color': Colors.brown,
        'onTap': () => _navigateToVideos(),
      },
    ];
  }
}
