import 'package:flutter/material.dart';
import '../../providers/cycle_provider.dart';

/// Reusable widgets for the Insights screen
/// This separates the UI components from the main screen logic

class PersonalizedDashboard extends StatelessWidget {
  final CycleProvider cycleProvider;
  final ThemeData theme;

  const PersonalizedDashboard({
    super.key,
    required this.cycleProvider,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWelcomeCard(),
        const SizedBox(height: 16),
        _buildQuickInsights(),
        const SizedBox(height: 16),
        _buildRecommendedActions(),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getPersonalizedGreeting(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text('✨', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPhaseBasedMessage(),
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInsights() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Your Insights',
                style: TextStyle(
                  fontSize: 16,
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
                child: _buildInsightChip(
                  'Cycle Day',
                  '${cycleProvider.currentCycleDay}',
                  _getCycleDayEmoji(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightChip(
                  'Next Period',
                  '${cycleProvider.daysUntilNextPeriod} days',
                  '📅',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightChip(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedActions() {
    final recommendations = _getPersonalizedRecommendations();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Recommended for You',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recommendations.map((rec) => _buildRecommendationItem(rec)),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(recommendation['emoji'], style: TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation['text'],
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPersonalizedGreeting() {
    final phase = _getCurrentPhase();
    switch (phase) {
      case 'menstrual':
        return 'Take it easy today 💝';
      case 'follicular':
        return 'Energy is building! 🌱';
      case 'ovulation':
        return 'You\'re glowing! ✨';
      case 'luteal':
        return 'Almost there! 🌙';
      default:
        return 'Hello, beautiful! 🌸';
    }
  }

  String _getPhaseBasedMessage() {
    final phase = _getCurrentPhase();
    switch (phase) {
      case 'menstrual':
        return 'Self-care and rest are your priorities right now.';
      case 'follicular':
        return 'Perfect time for new projects and activities.';
      case 'ovulation':
        return 'Peak energy - make the most of it!';
      case 'luteal':
        return 'Listen to your body and prepare for your period.';
      default:
        return 'Track your cycle to get personalized insights.';
    }
  }

  String _getCurrentPhase() {
    final day = cycleProvider.currentCycleDay;
    if (day <= 5) return 'menstrual';
    if (day <= 13) return 'follicular';
    if (day <= 16) return 'ovulation';
    return 'luteal';
  }

  String _getCycleDayEmoji() {
    final day = cycleProvider.currentCycleDay;
    if (day <= 5) return '🩸';
    if (day <= 13) return '🌱';
    if (day <= 16) return '⭐';
    return '🌙';
  }

  List<Map<String, dynamic>> _getPersonalizedRecommendations() {
    final phase = _getCurrentPhase();

    List<Map<String, dynamic>> recommendations = [];

    switch (phase) {
      case 'menstrual':
        recommendations.addAll([
          {'emoji': '🛁', 'text': 'Try a warm bath to ease cramps'},
          {'emoji': '🍫', 'text': 'Dark chocolate can help with mood'},
          {
            'emoji': '😴',
            'text': 'Get extra sleep - your body is working hard',
          },
        ]);
        break;
      case 'follicular':
        recommendations.addAll([
          {
            'emoji': '🏃‍♀️',
            'text': 'Great time to start a new workout routine',
          },
          {'emoji': '📚', 'text': 'Your brain is sharp - perfect for learning'},
          {'emoji': '🥗', 'text': 'Focus on iron-rich foods to rebuild'},
        ]);
        break;
      case 'ovulation':
        recommendations.addAll([
          {'emoji': '💃', 'text': 'You might feel more social and confident'},
          {'emoji': '💪', 'text': 'Peak performance time for workouts'},
          {'emoji': '🌟', 'text': 'Great time for important meetings or dates'},
        ]);
        break;
      case 'luteal':
        recommendations.addAll([
          {'emoji': '🧘‍♀️', 'text': 'Practice stress management techniques'},
          {'emoji': '🥛', 'text': 'Calcium and magnesium can help with PMS'},
          {'emoji': '📝', 'text': 'Good time for planning and organizing'},
        ]);
        break;
    }

    return recommendations.take(3).toList();
  }
}

class InteractiveContentCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? badge;

  const InteractiveContentCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  State<InteractiveContentCard> createState() => _InteractiveContentCardState();
}

class _InteractiveContentCardState extends State<InteractiveContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16), // Reduced padding
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isPressed
                      ? widget.color.withOpacity(0.5)
                      : widget.color.withOpacity(0.2),
                  width: _isPressed ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_isPressed ? 0.3 : 0.1),
                    blurRadius: _isPressed ? 15 : 8,
                    offset: Offset(0, _isPressed ? 8 : 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Minimize space usage
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10), // Reduced padding
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Smaller radius
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 20,
                        ), // Smaller icon
                      ),
                      const Spacer(),
                      if (widget.badge != null) widget.badge!,
                    ],
                  ),
                  const SizedBox(height: 12), // Reduced spacing
                  Flexible(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16, // Slightly smaller
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6), // Reduced spacing
                  Flexible(
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 12, // Smaller text
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced spacing
                  Row(
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 12, // Smaller text
                          fontWeight: FontWeight.w600,
                          color: widget.color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10, // Smaller arrow
                        color: widget.color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
