import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/education_provider.dart';
import 'video_player_screen.dart';

class VideoLibraryScreen extends StatelessWidget {
  const VideoLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final educationProvider = Provider.of<EducationProvider>(context);

    final videoCategories = [
      {
        'title': 'Menstrual Health Basics',
        'icon': Icons.health_and_safety,
        'color': Colors.red,
        'videos': [
          {
            'id': 'cycle_overview',
            'title': 'Understanding Your Menstrual Cycle',
            'description':
                'Learn about the four phases of your cycle and what happens in your body',
            'duration': '5:30',
            'thumbnail': 'assets/thumbnail.jpg',
            'difficulty': 'Beginner',
            'youtubeUrl': 'https://youtu.be/lYoXDf1aHI0',
          },
          {
            'id': 'hormones_explained',
            'title': 'Hormones and Your Cycle',
            'description':
                'Discover how estrogen, progesterone, and other hormones work together',
            'duration': '7:15',
            'thumbnail': 'hormones.jpg',
            'difficulty': 'Intermediate',
            'youtubeUrl': 'https://youtu.be/lYoXDf1aHI0',
          },
          {
            'id': 'tracking_benefits',
            'title': 'Benefits of Period Tracking',
            'description':
                'Why tracking your cycle can improve your health and wellbeing',
            'duration': '4:20',
            'thumbnail': 'tracking.jpg',
            'difficulty': 'Beginner',
            'youtubeUrl': 'https://youtu.be/lYoXDf1aHI0',
          },
        ],
      },
      {
        'title': 'Period Products Guide',
        'icon': Icons.inventory_2,
        'color': Colors.purple,
        'videos': [
          {
            'id': 'tampon_guide',
            'title': 'How to Use Tampons Safely',
            'description':
                'Step-by-step guide to inserting and removing tampons safely',
            'duration': '6:45',
            'thumbnail': 'tampon_guide.jpg',
            'difficulty': 'Beginner',
            'youtubeUrl': 'https://youtu.be/lYoXDf1aHI0',
          },
          {
            'id': 'menstrual_cups',
            'title': 'Menstrual Cups: Complete Guide',
            'description':
                'Everything you need to know about using menstrual cups',
            'duration': '8:30',
            'thumbnail': 'cups.jpg',
            'difficulty': 'Intermediate',
            'youtubeUrl': 'https://youtu.be/lYoXDf1aHI0',
          },
          {
            'id': 'product_comparison',
            'title': 'Comparing Period Products',
            'description':
                'Pros and cons of pads, tampons, cups, and other products',
            'duration': '5:55',
            'thumbnail': 'comparison.jpg',
            'difficulty': 'Beginner',
            'youtubeUrl': 'https://youtu.be/lYoXDf1aHI0',
          },
        ],
      },
      {
        'title': 'Health & Wellness',
        'icon': Icons.spa,
        'color': Colors.green,
        'videos': [
          {
            'id': 'period_pain',
            'title': 'Managing Period Pain',
            'description':
                'Natural and medical ways to reduce menstrual discomfort',
            'duration': '6:10',
            'thumbnail': 'pain_relief.jpg',
            'difficulty': 'Beginner',
            'youtubeUrl': 'https://youtu.be/lYoXDf1aHI0',
          },
          {
            'id': 'nutrition_cycle',
            'title': 'Nutrition for Your Cycle',
            'description': 'How to eat for better periods and hormonal health',
            'duration': '9:20',
            'thumbnail': 'nutrition.jpg',
            'difficulty': 'Intermediate',
            'youtubeUrl': 'https://youtu.be/lYoXDf1aHI0',
          },
          {
            'id': 'exercise_periods',
            'title': 'Exercise During Your Period',
            'description': 'Safe and beneficial workouts for each cycle phase',
            'duration': '7:40',
            'thumbnail': 'exercise.jpg',
            'difficulty': 'Beginner',
            'youtubeUrl': 'https://youtu.be/lYoXDf1aHI0',
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.teal],
            ),
          ),
        ),
        title: Text(
          'Video Library',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          // Watch time stats
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.teal.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Learning Progress',
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
                          child: _buildStatCard(
                            'Videos Watched',
                            '${educationProvider.getCompletedVideoCount()}',
                            Colors.blue,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Watch Time',
                            '${educationProvider.getTotalWatchTime()}m',
                            Colors.teal,
                            theme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Video categories
          ...videoCategories.map((category) {
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (category['color'] as Color).withOpacity(
                                0.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              color: category['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category['title'] as String,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Videos in category
                    ...(category['videos'] as List<Map<String, dynamic>>).map((
                      video,
                    ) {
                      final isWatched = educationProvider.isVideoWatched(
                        video['id'] as String,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildVideoCard(
                          video,
                          isWatched,
                          category['color'] as Color,
                          theme,
                          context,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),

          SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildVideoCard(
    Map<String, dynamic> video,
    bool isWatched,
    Color categoryColor,
    ThemeData theme,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isWatched
              ? Colors.green.withOpacity(0.5)
              : categoryColor.withOpacity(0.3),
          width: isWatched ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VideoPlayerScreen(video: video, categoryColor: categoryColor),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Video thumbnail
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: categoryColor.withOpacity(0.2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background or thumbnail image
                      if (video['thumbnail'] != null &&
                          (video['thumbnail'] as String).startsWith('assets/'))
                        Image.asset(
                          video['thumbnail'] as String,
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 60,
                              color: categoryColor.withOpacity(0.2),
                              child: Icon(
                                Icons.video_library,
                                color: categoryColor,
                                size: 24,
                              ),
                            );
                          },
                        )
                      else
                        Icon(
                          Icons.video_library,
                          color: categoryColor,
                          size: 24,
                        ),

                      // Play button overlay
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      if (isWatched)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video['duration'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Video info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            video['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            video['difficulty'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      video['description'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.play_arrow, size: 16, color: categoryColor),
                        const SizedBox(width: 4),
                        Text(
                          isWatched ? 'Watch Again' : 'Watch Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ],
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
}
