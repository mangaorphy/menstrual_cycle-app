import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cycleProvider = Provider.of<CycleProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Insights & Tips',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.6,
          ),
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Period'),
            Tab(text: 'Fertile'),
            Tab(text: 'Wellness'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(cycleProvider, theme),
          _buildPeriodTab(theme),
          _buildFertileTab(theme),
          _buildWellnessTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(CycleProvider cycleProvider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cycle Statistics
          _buildStatsCard(cycleProvider, theme),
          const SizedBox(height: 16),

          // Current Phase
          _buildCurrentPhaseCard(cycleProvider, theme),
          const SizedBox(height: 16),

          // Recent Patterns
          _buildPatternsCard(cycleProvider, theme),
        ],
      ),
    );
  }

  Widget _buildStatsCard(CycleProvider cycleProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Cycle Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Average Cycle',
                '${cycleProvider.averageCycleLength} days',
                Icons.loop,
                theme,
              ),
              _buildStatItem(
                'Average Period',
                '${cycleProvider.averagePeriodLength} days',
                Icons.calendar_today,
                theme,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Cycles Tracked',
                '${cycleProvider.cycles.length}',
                Icons.analytics,
                theme,
              ),
              _buildStatItem(
                'Most Common Flow',
                cycleProvider.mostCommonFlow,
                Icons.water_drop,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPhaseCard(CycleProvider cycleProvider, ThemeData theme) {
    final phase = _getCurrentPhase(cycleProvider);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getPhaseColors(phase),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getPhaseColors(phase)[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Phase',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPhaseTitle(phase),
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPhaseDescription(phase),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsCard(CycleProvider cycleProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patterns & Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildPatternItem(
            'Cycle Regularity',
            _getCycleRegularity(cycleProvider),
            Icons.timeline,
            theme,
          ),
          const SizedBox(height: 12),
          _buildPatternItem(
            'Common Symptoms',
            cycleProvider.mostCommonSymptoms.take(3).join(', '),
            Icons.healing,
            theme,
          ),
          const SizedBox(height: 12),
          _buildPatternItem(
            'Next Period Prediction',
            _getNextPeriodPrediction(cycleProvider),
            Icons.schedule,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternItem(
    String title,
    String description,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTipCard(
            'Managing Period Pain',
            'Try gentle exercises like walking or yoga. Heat therapy can help relax muscles. Stay hydrated and consider anti-inflammatory medications if needed.',
            Icons.healing,
            Colors.red.shade300,
            theme,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            'Nutrition During Period',
            'Focus on iron-rich foods like spinach, lean meats, and beans. Limit caffeine and sugar. Dark chocolate can help with cravings and provides magnesium.',
            Icons.restaurant,
            Colors.orange.shade300,
            theme,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            'Period Products',
            'Choose products that work best for you - pads, tampons, cups, or period underwear. Change regularly and maintain good hygiene.',
            Icons.favorite,
            Colors.pink.shade300,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildFertileTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTipCard(
            'Understanding Fertility',
            'Your fertile window is typically 6 days - 5 days before ovulation plus ovulation day. Track your cycle to identify patterns.',
            Icons.eco,
            Colors.green.shade300,
            theme,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            'Ovulation Signs',
            'Look for changes in cervical mucus (clear and stretchy), slight temperature rise, and mild pelvic pain on one side.',
            Icons.visibility,
            Colors.blue.shade300,
            theme,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            'Conception Tips',
            'If trying to conceive, have regular intercourse during your fertile window. Maintain a healthy lifestyle with good nutrition and exercise.',
            Icons.child_care,
            Colors.purple.shade300,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTipCard(
            'Stress Management',
            'Practice meditation, deep breathing, or yoga. Stress can affect your cycle, so find healthy ways to manage it.',
            Icons.spa,
            Colors.indigo.shade300,
            theme,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            'Sleep & Exercise',
            'Aim for 7-9 hours of quality sleep. Regular moderate exercise can help regulate hormones and reduce period symptoms.',
            Icons.bedtime,
            Colors.teal.shade300,
            theme,
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            'When to See a Doctor',
            'Consult a healthcare provider if you experience severe pain, irregular cycles, heavy bleeding, or other concerning symptoms.',
            Icons.medical_services,
            Colors.amber.shade300,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
    String title,
    String description,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getCurrentPhase(CycleProvider cycleProvider) {
    if (cycleProvider.cycles.isEmpty) return 'tracking';

    final lastCycle = cycleProvider.cycles.first;
    final daysSinceStart = DateTime.now()
        .difference(lastCycle.periodStartDate)
        .inDays;

    if (daysSinceStart < lastCycle.periodLength) {
      return 'period';
    } else if (daysSinceStart < 14) {
      return 'follicular';
    } else if (daysSinceStart < 16) {
      return 'ovulation';
    } else {
      return 'luteal';
    }
  }

  List<Color> _getPhaseColors(String phase) {
    switch (phase) {
      case 'period':
        return [Colors.red.shade300, Colors.red.shade400];
      case 'follicular':
        return [Colors.pink.shade300, Colors.pink.shade400];
      case 'ovulation':
        return [Colors.green.shade300, Colors.green.shade400];
      case 'luteal':
        return [Colors.orange.shade300, Colors.orange.shade400];
      default:
        return [Colors.grey.shade300, Colors.grey.shade400];
    }
  }

  String _getPhaseTitle(String phase) {
    switch (phase) {
      case 'period':
        return 'Menstrual Phase';
      case 'follicular':
        return 'Follicular Phase';
      case 'ovulation':
        return 'Ovulation Phase';
      case 'luteal':
        return 'Luteal Phase';
      default:
        return 'Start Tracking';
    }
  }

  String _getPhaseDescription(String phase) {
    switch (phase) {
      case 'period':
        return 'Your period is here. Focus on self-care and rest.';
      case 'follicular':
        return 'Energy is building. Good time for new projects.';
      case 'ovulation':
        return 'Peak fertility time. You might feel more energetic.';
      case 'luteal':
        return 'Body is preparing for next cycle. Take it easy.';
      default:
        return 'Start logging your periods to get insights.';
    }
  }

  String _getCycleRegularity(CycleProvider cycleProvider) {
    if (cycleProvider.cycles.length < 3) return 'Need more data';

    final lengths = cycleProvider.cycles.map((c) => c.cycleLength).toList();
    final variance = _calculateVariance(lengths);

    if (variance <= 2) return 'Very Regular';
    if (variance <= 5) return 'Fairly Regular';
    return 'Irregular';
  }

  double _calculateVariance(List<int> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) /
        values.length;
    return variance;
  }

  String _getNextPeriodPrediction(CycleProvider cycleProvider) {
    if (cycleProvider.cycles.isEmpty) return 'Start tracking cycles';

    final lastCycle = cycleProvider.cycles.first;
    final avgLength = cycleProvider.averageCycleLength;
    final nextPeriod = lastCycle.periodStartDate.add(Duration(days: avgLength));
    final daysUntil = nextPeriod.difference(DateTime.now()).inDays;

    if (daysUntil <= 0) return 'Period may be starting soon';
    return 'In $daysUntil days (${nextPeriod.day}/${nextPeriod.month})';
  }
}
