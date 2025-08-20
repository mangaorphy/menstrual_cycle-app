import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/education_provider.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final educationProvider = Provider.of<EducationProvider>(context);

    final quizzes = [
      {
        'id': 'menstrual_basics',
        'title': 'Menstrual Cycle Basics',
        'description':
            'Test your knowledge about the menstrual cycle phases and hormones',
        'icon': Icons.favorite,
        'color': Colors.red,
        'questions': 10,
        'difficulty': 'Beginner',
        'estimatedTime': '5 min',
      },
      {
        'id': 'period_products',
        'title': 'Period Products Knowledge',
        'description':
            'Learn about different period products and their proper usage',
        'icon': Icons.inventory_2,
        'color': Colors.purple,
        'questions': 8,
        'difficulty': 'Beginner',
        'estimatedTime': '4 min',
      },
      {
        'id': 'health_hygiene',
        'title': 'Health & Hygiene',
        'description':
            'Important facts about menstrual health and hygiene practices',
        'icon': Icons.health_and_safety,
        'color': Colors.green,
        'questions': 12,
        'difficulty': 'Intermediate',
        'estimatedTime': '6 min',
      },
      {
        'id': 'myths_facts',
        'title': 'Myths vs Facts',
        'description': 'Separate period myths from scientific facts',
        'icon': Icons.fact_check,
        'color': Colors.orange,
        'questions': 15,
        'difficulty': 'Advanced',
        'estimatedTime': '8 min',
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
              colors: [Colors.purple, Colors.pink],
            ),
          ),
        ),
        title: Text(
          'Knowledge Quizzes',
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
          // Progress Overview
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.1),
                      Colors.pink.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Your Quiz Progress',
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
                            'Completed',
                            '${educationProvider.getCompletedQuizCount()}/${quizzes.length}',
                            Colors.green,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Best Score',
                            '${(educationProvider.getOverallQuizProgress() * 100).toInt()}%',
                            Colors.blue,
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

          // Quiz List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final quiz = quizzes[index];
                final isCompleted =
                    educationProvider.getQuizCompletionCount(
                      quiz['id'] as String,
                    ) >
                    0;
                final bestScore = educationProvider.getBestScore(
                  quiz['id'] as String,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildQuizCard(
                    context,
                    quiz,
                    isCompleted,
                    bestScore,
                    theme,
                  ),
                );
              }, childCount: quizzes.length),
            ),
          ),

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

  Widget _buildQuizCard(
    BuildContext context,
    Map<String, dynamic> quiz,
    bool isCompleted,
    double bestScore,
    ThemeData theme,
  ) {
    final color = quiz['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isCompleted ? color.withOpacity(0.5) : color.withOpacity(0.3),
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                quizId: quiz['id'] as String,
                quizTitle: quiz['title'] as String,
                quizColor: color,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      quiz['icon'] as IconData,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  if (isCompleted) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${bestScore.toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
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
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              Text(
                quiz['title'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                quiz['description'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _buildQuizInfo(
                    Icons.quiz,
                    '${quiz['questions']} questions',
                    color,
                  ),
                  const SizedBox(width: 16),
                  _buildQuizInfo(
                    Icons.access_time,
                    quiz['estimatedTime'] as String,
                    color,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quiz['difficulty'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    isCompleted ? 'Retake Quiz' : 'Start Quiz',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final Color quizColor;

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.quizColor,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  List<int> selectedAnswers = [];
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    // Mock quiz questions - in a real app, you'd fetch from Firebase
    setState(() {
      questions = _getQuestionsForQuiz(widget.quizId);
      selectedAnswers = List.filled(questions.length, -1);
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getQuestionsForQuiz(String quizId) {
    switch (quizId) {
      case 'menstrual_basics':
        return [
          {
            'question': 'How long is an average menstrual cycle?',
            'options': ['21 days', '28 days', '35 days', '42 days'],
            'correctAnswer': 1,
          },
          {
            'question': 'Which hormone triggers ovulation?',
            'options': [
              'Estrogen',
              'Progesterone',
              'LH (Luteinizing Hormone)',
              'FSH',
            ],
            'correctAnswer': 2,
          },
          {
            'question': 'During which phase does the uterine lining shed?',
            'options': ['Follicular', 'Ovulation', 'Luteal', 'Menstrual'],
            'correctAnswer': 3,
          },
        ];
      case 'period_products':
        return [
          {
            'question': 'How often should you change a tampon?',
            'options': [
              'Every 2 hours',
              'Every 4-8 hours',
              'Every 12 hours',
              'Once a day',
            ],
            'correctAnswer': 1,
          },
          {
            'question': 'Which product can be worn for up to 12 hours?',
            'options': ['Tampon', 'Pad', 'Menstrual cup', 'Liner'],
            'correctAnswer': 2,
          },
        ];
      default:
        return [
          {
            'question': 'Sample question for ${widget.quizTitle}',
            'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
            'correctAnswer': 0,
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: widget.quizColor,
          foregroundColor: Colors.white,
          title: Text(widget.quizTitle),
        ),
        body: Center(child: CircularProgressIndicator(color: widget.quizColor)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: widget.quizColor,
        foregroundColor: Colors.white,
        title: Text(widget.quizTitle),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.quizColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.quizColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Question
            Text(
              questions[currentQuestionIndex]['question'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 32),

            // Answer options
            Expanded(
              child: ListView.builder(
                itemCount: questions[currentQuestionIndex]['options'].length,
                itemBuilder: (context, index) {
                  final isSelected =
                      selectedAnswers[currentQuestionIndex] == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAnswers[currentQuestionIndex] = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.quizColor.withOpacity(0.1)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? widget.quizColor
                                : theme.colorScheme.outline.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? widget.quizColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? widget.quizColor
                                      : theme.colorScheme.outline.withOpacity(
                                          0.5,
                                        ),
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                questions[currentQuestionIndex]['options'][index],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.quizColor,
                        side: BorderSide(color: widget.quizColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Previous'),
                    ),
                  ),

                if (currentQuestionIndex > 0) const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedAnswers[currentQuestionIndex] != -1
                        ? () {
                            if (currentQuestionIndex < questions.length - 1) {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            } else {
                              _finishQuiz();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.quizColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex < questions.length - 1
                          ? 'Next'
                          : 'Finish Quiz',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _finishQuiz() {
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }

    final score = (correctAnswers / questions.length * 100).round();

    // Record completion
    Provider.of<EducationProvider>(context, listen: false).recordQuizCompletion(
      quizType: widget.quizId,
      score: correctAnswers,
      totalQuestions: questions.length,
    );

    // Show results
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Quiz Complete!',
          style: TextStyle(color: widget.quizColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              score >= 80 ? Icons.emoji_events : Icons.thumb_up,
              size: 64,
              color: score >= 80 ? Colors.amber : widget.quizColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score: $score%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.quizColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$correctAnswers out of ${questions.length} correct',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              score >= 80
                  ? 'Excellent work! 🎉'
                  : score >= 60
                  ? 'Good job! Keep learning! 📚'
                  : 'Keep practicing! You\'ll do better next time! 💪',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close quiz screen
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}
