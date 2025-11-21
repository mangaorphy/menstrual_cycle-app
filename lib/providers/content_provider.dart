import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _searchableContent = [];
  List<Map<String, dynamic>> _forYouTips = [];
  Map<String, Map<String, dynamic>> _learningContent = {};
  List<Map<String, dynamic>> _communityPosts = [];
  List<Map<String, dynamic>> _quizData = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Map<String, dynamic>> get searchableContent => _searchableContent;
  List<Map<String, dynamic>> get forYouTips => _forYouTips;
  Map<String, Map<String, dynamic>> get learningContent => _learningContent;
  List<Map<String, dynamic>> get communityPosts => _communityPosts;
  List<Map<String, dynamic>> get quizData => _quizData;
  bool get isLoading => _isLoading;

  ContentProvider() {
    _initializeContent();
  }

  Future<void> _initializeContent() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Check if quiz content exists in Firestore
      final quizSnapshot = await _firestore
          .collection('app_content')
          .doc('quiz_data')
          .get();

      if (!quizSnapshot.exists) {
        print('Quiz data not found, seeding content...');
        // Initialize content in Firestore
        await _seedContent();
      } else {
        print('Quiz data found in Firestore');
      }

      // Load content from Firestore
      await _loadContentFromFirestore();
    } catch (e) {
      print('Error initializing content: $e');
      // Fallback to hardcoded content if Firestore fails
      _loadFallbackContent();
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  static IconData getIconForTitle(String title) {
    final iconMap = <String, IconData>{
      'Understanding Ovulation': Icons.scatter_plot,
      'Period Product Guide': Icons.shopping_bag,
      'Tracking Your Symptoms': Icons.track_changes,
      'Myths vs Facts': Icons.lightbulb_outline,
      'Nutrition & Periods': Icons.restaurant,
      'Exercise During Periods': Icons.fitness_center,
      'When to See a Doctor': Icons.medical_services,
      'ovulation': Icons.scatter_plot,
      'tracking': Icons.track_changes,
      'nutrition': Icons.restaurant,
      'exercise': Icons.fitness_center,
      'medical': Icons.medical_services,
      'myths': Icons.lightbulb_outline,
      'disposable': Icons.shopping_bag,
    };

    return iconMap[title] ?? iconMap[title.toLowerCase()] ?? Icons.info;
  }

  static Color getColorForTitle(String title) {
    final colorMap = <String, Color>{
      'Understanding Ovulation': const Color(0xFFE8F5E8),
      'Period Product Guide': const Color(0xFFFFF3E0),
      'Tracking Your Symptoms': const Color(0xFFE3F2FD),
      'Myths vs Facts': const Color(0xFFF3E5F5),
      'Nutrition & Periods': const Color(0xFFE8F5E8),
      'Exercise During Periods': const Color(0xFFFFEBEE),
      'When to See a Doctor': const Color(0xFFE1F5FE),
    };

    return colorMap[title] ?? const Color(0xFFF5F5F5);
  }

  Future<void> _loadContentFromFirestore() async {
    try {
      // Load searchable content
      final searchDoc = await _firestore
          .collection('app_content')
          .doc('searchable_content')
          .get();
      if (searchDoc.exists) {
        final data = searchDoc.data() as Map<String, dynamic>;
        _searchableContent = List<Map<String, dynamic>>.from(
          data['content'] ?? [],
        );
      }

      // Load for you tips
      final tipsDoc = await _firestore
          .collection('app_content')
          .doc('for_you_tips')
          .get();
      if (tipsDoc.exists) {
        final data = tipsDoc.data() as Map<String, dynamic>;
        _forYouTips = List<Map<String, dynamic>>.from(data['tips'] ?? []);
      }

      // Load learning content
      final learningDoc = await _firestore
          .collection('app_content')
          .doc('learning_content')
          .get();
      if (learningDoc.exists) {
        final data = learningDoc.data() as Map<String, dynamic>;
        _learningContent = Map<String, Map<String, dynamic>>.from(
          (data['content'] ?? {}).map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
          ),
        );
      }

      // Load community posts
      final communityDoc = await _firestore
          .collection('app_content')
          .doc('community_posts')
          .get();
      if (communityDoc.exists) {
        final data = communityDoc.data() as Map<String, dynamic>;
        _communityPosts = List<Map<String, dynamic>>.from(data['posts'] ?? []);
      }

      // Load quiz data
      print('Loading quiz data from Firestore...');
      final quizDoc = await _firestore
          .collection('app_content')
          .doc('quiz_data')
          .get();
      if (quizDoc.exists) {
        final data = quizDoc.data() as Map<String, dynamic>;
        _quizData = List<Map<String, dynamic>>.from(data['quizzes'] ?? []);
        print('Loaded ${_quizData.length} quizzes from Firestore');
      } else {
        print('Quiz document does not exist in Firestore');
      }
    } catch (e) {
      print('Error loading content from Firestore: $e');
      _loadFallbackContent();
    }
  }

  Future<void> _seedContent() async {
    try {
      // Seed searchable content
      await _firestore.collection('app_content').doc('searchable_content').set({
        'content': [
          {
            'title': 'Menstrual Cycle',
            'description': 'Learn about your cycle phases',
            'type': 'article',
          },
          {
            'title': 'Product Guide',
            'description': 'Find the right products for you',
            'type': 'guide',
          },
          {
            'title': 'Symptom Tracking',
            'description': 'Track and understand your symptoms',
            'type': 'feature',
          },
          {
            'title': 'Period Quiz',
            'description': 'Test your knowledge about periods',
            'type': 'quiz',
          },
          {
            'title': 'Educational Videos',
            'description': 'Watch videos about reproductive health',
            'type': 'videos',
          },
          {
            'title': 'Health Resources',
            'description': 'Access health and wellness resources',
            'type': 'resources',
          },
          {
            'title': 'Ovulation',
            'description': 'Understanding ovulation and fertility',
            'type': 'article',
          },
          {
            'title': 'PMS',
            'description': 'Managing PMS symptoms',
            'type': 'article',
          },
          {
            'title': 'Nutrition',
            'description': 'Nutrition for menstrual health',
            'type': 'guide',
          },
          {
            'title': 'Exercise',
            'description': 'Exercise during your cycle',
            'type': 'guide',
          },
        ],
        'last_updated': DateTime.now(),
      });

      // Seed for you tips based on cycle phases
      await _firestore.collection('app_content').doc('for_you_tips').set({
        'tips': [
          {
            'phase': 'menstrual',
            'day_range': {'start': 1, 'end': 5},
            'tip':
                'Focus on iron-rich foods to replenish what you lose during menstruation.',
          },
          {
            'phase': 'follicular',
            'day_range': {'start': 6, 'end': 13},
            'tip':
                'Great time to start new habits - your energy is naturally increasing!',
          },
          {
            'phase': 'ovulation',
            'day_range': {'start': 14, 'end': 16},
            'tip':
                'Peak fertility window. Your body temperature may be slightly higher.',
          },
          {
            'phase': 'luteal',
            'day_range': {'start': 17, 'end': 28},
            'tip':
                'PMS symptoms are common now. Try stress-reduction techniques.',
          },
        ],
        'last_updated': DateTime.now(),
      });

      // Seed learning content
      await _firestore.collection('app_content').doc('learning_content').set({
        'content': {
          'Menstrual Cycle Basics': {
            'content':
                '''Understanding your menstrual cycle is key to understanding your body and reproductive health. The menstrual cycle is a monthly series of changes your body goes through to prepare for the possibility of pregnancy.

The average menstrual cycle is 28 days long, but normal cycles can range from 21 to 35 days. Your cycle is counted from the first day of your period to the first day of your next period.

Tracking your cycle can help you:
• Predict when your next period will start
• Identify your fertile window if you're trying to conceive
• Notice any unusual changes in your cycle
• Plan ahead for important events
• Better understand your body's natural rhythms

Remember, every person's cycle is unique. What's normal for you might be different from what's normal for someone else.''',
            'sections': [
              {
                'title': 'The Four Phases',
                'content':
                    '''1. Menstrual Phase (Days 1-5): Your period begins. The lining of your uterus (endometrium) sheds.

2. Follicular Phase (Days 1-13): Your body prepares to release an egg. Estrogen levels rise.

3. Ovulation (Around Day 14): A mature egg is released from the ovary. This is your most fertile time.

4. Luteal Phase (Days 15-28): If pregnancy doesn't occur, hormone levels drop and the cycle begins again.''',
                'icon': 'cycle',
              },
              {
                'title': 'Common Symptoms',
                'content':
                    '''Throughout your cycle, you may experience various symptoms:

• Cramping during menstruation
• Mood changes
• Breast tenderness
• Bloating
• Food cravings
• Energy level changes
• Changes in vaginal discharge

These symptoms are normal and vary from person to person.''',
                'icon': 'symptoms',
              },
            ],
          },
          'Understanding Ovulation': {
            'content':
                '''Ovulation is the release of an egg from one of your ovaries. This typically happens around day 14 of a 28-day cycle, but can vary depending on your individual cycle length.

During ovulation, you may notice:
• Changes in cervical mucus (clearer, stretchier)
• Slight increase in body temperature
• Light spotting
• Mild pelvic pain on one side
• Increased libido

Understanding when you ovulate can help you understand your fertility window and plan accordingly.''',
            'sections': [
              {
                'title': 'Signs of Ovulation',
                'content':
                    '''Common signs that ovulation is occurring or about to occur:

• Cervical mucus becomes clear and stretchy
• Basal body temperature rises slightly
• Ovulation pain (mittelschmerz)
• Breast tenderness
• Increased energy and sex drive
• Light spotting

Tracking these signs can help you identify your ovulation pattern.''',
                'icon': 'ovulation',
              },
            ],
          },
          'Period Product Guide': {
            'content':
                '''Choosing the right period product is personal and depends on your flow, lifestyle, and comfort preferences. Here's a comprehensive guide to help you make informed decisions.

There are many options available, from traditional pads and tampons to newer innovations like menstrual cups and period underwear.

Each product has its benefits:
• Comfort and convenience
• Environmental impact
• Cost considerations
• Health and safety factors''',
            'sections': [
              {
                'title': 'Product Types',
                'content': '''Disposable Options:
• Pads: External protection, various absorbencies
• Tampons: Internal protection, different sizes
• Liners: Light protection for daily use

Reusable Options:
• Menstrual cups: Silicone cups worn internally
• Period underwear: Absorbent underwear
• Cloth pads: Washable external protection''',
                'icon': 'disposable',
              },
            ],
          },
          'Tracking Your Symptoms': {
            'content':
                '''Symptom tracking helps you understand your unique cycle patterns and can be valuable for healthcare discussions. 

Key symptoms to track:
• Flow intensity and duration
• Pain levels and locations
• Mood changes
• Energy levels
• Sleep patterns
• Appetite changes''',
            'sections': [
              {
                'title': 'Why Track Symptoms',
                'content': '''Benefits of tracking:
• Predict your next period
• Identify patterns in PMS symptoms
• Monitor health changes
• Prepare for healthcare appointments
• Better understand your body''',
                'icon': 'tracking',
              },
            ],
          },
          'Myths vs Facts': {
            'content':
                '''Many myths surround menstruation, often leading to shame and misinformation. Let's separate fact from fiction with evidence-based information.

Common myths we'll address:
• Exercise restrictions during periods
• Food and drink limitations
• Hygiene misconceptions
• Health and fertility myths''',
            'sections': [
              {
                'title': 'Exercise Myths',
                'content': '''Myth: You shouldn't exercise during your period
Fact: Exercise can actually help reduce cramps and improve mood

Myth: Swimming during periods is dangerous
Fact: Swimming is safe and water pressure prevents leakage''',
                'icon': 'myths',
              },
            ],
          },
          'Nutrition & Periods': {
            'content':
                '''Your nutritional needs may change throughout your cycle. Understanding how to fuel your body can help manage symptoms and maintain energy.

Key nutritional considerations:
• Iron replacement during menstruation
• Anti-inflammatory foods for pain
• Hydration importance
• Foods that may worsen symptoms''',
            'sections': [
              {
                'title': 'Helpful Foods',
                'content': '''Iron-rich foods: Spinach, lentils, lean meat
Anti-inflammatory: Berries, fatty fish, turmeric
Calcium sources: Dairy, leafy greens, almonds
Magnesium foods: Dark chocolate, nuts, seeds''',
                'icon': 'nutrition',
              },
            ],
          },
          'Exercise During Periods': {
            'content':
                '''Exercise during menstruation is not only safe but can be beneficial for managing symptoms and maintaining overall health.

Benefits of exercising during periods:
• Reduced cramp intensity
• Improved mood through endorphins
• Better energy levels
• Reduced bloating''',
            'sections': [
              {
                'title': 'Best Exercises',
                'content': '''Gentle options:
• Walking and light jogging
• Yoga and stretching
• Swimming
• Low-intensity strength training

Listen to your body and adjust intensity as needed.''',
                'icon': 'exercise',
              },
            ],
          },
          'When to See a Doctor': {
            'content':
                '''While periods can vary widely, certain symptoms warrant medical attention. Know when to seek professional help.

Warning signs to watch for:
• Severe pain that disrupts daily life
• Very heavy bleeding
• Irregular cycles consistently
• Periods that suddenly change dramatically''',
            'sections': [
              {
                'title': 'Red Flags',
                'content': '''Seek immediate care for:
• Bleeding between periods
• Severe abdominal pain
• Fever with period symptoms
• Passing large clots regularly
• Periods lasting longer than 7 days''',
                'icon': 'medical',
              },
            ],
          },
        },
        'last_updated': DateTime.now(),
      });

      // Seed community posts
      await _firestore.collection('app_content').doc('community_posts').set({
        'posts': [
          {
            'title': 'Best remedies for cramps?',
            'user': 'user123',
            'timeAgo': '2 hours ago',
            'replies': '15 replies',
            'timestamp': DateTime.now(),
          },
          {
            'title': 'Feeling extra tired this week, anyone else?',
            'user': 'another_user',
            'timeAgo': '5 hours ago',
            'replies': '8 replies',
            'timestamp': DateTime.now(),
          },
          {
            'title': 'What are your favorite period products?',
            'user': 'wellness_seeker',
            'timeAgo': '1 day ago',
            'replies': '23 replies',
            'timestamp': DateTime.now(),
          },
          {
            'title': 'Exercise during your period - tips?',
            'user': 'fitness_lover',
            'timeAgo': '2 days ago',
            'replies': '12 replies',
            'timestamp': DateTime.now(),
          },
        ],
        'last_updated': DateTime.now(),
      });

      // Seed quiz data
      print('Seeding quiz data to Firestore...');
      await _firestore.collection('app_content').doc('quiz_data').set({
        'quizzes': [
          {
            'id': 'menstrual_basics',
            'title': 'Menstrual Cycle Basics',
            'description':
                'Test your knowledge about the menstrual cycle phases and hormones',
            'icon': 'favorite',
            'color': 'red',
            'questions': 10,
            'difficulty': 'Beginner',
            'estimatedTime': '5 min',
            'quiz_questions': [
              {
                'question': 'How long is the average menstrual cycle?',
                'options': ['21 days', '28 days', '35 days', '40 days'],
                'correct_answer': 1,
                'explanation':
                    'The average menstrual cycle is 28 days, though normal cycles can range from 21-35 days.',
              },
              {
                'question': 'During which phase does ovulation occur?',
                'options': [
                  'Menstrual phase',
                  'Follicular phase',
                  'Ovulation phase',
                  'Luteal phase',
                ],
                'correct_answer': 2,
                'explanation':
                    'Ovulation typically occurs around day 14 of a 28-day cycle, marking the ovulation phase.',
              },
            ],
          },
          {
            'id': 'period_products',
            'title': 'Period Products Knowledge',
            'description':
                'Learn about different period products and their proper usage',
            'icon': 'inventory_2',
            'color': 'purple',
            'questions': 8,
            'difficulty': 'Beginner',
            'estimatedTime': '4 min',
            'quiz_questions': [
              {
                'question': 'How often should you change a tampon?',
                'options': [
                  'Every 12 hours',
                  'Every 8 hours',
                  'Every 4-6 hours',
                  'Once a day',
                ],
                'correct_answer': 2,
                'explanation':
                    'Tampons should be changed every 4-6 hours to prevent bacterial growth and TSS risk.',
              },
            ],
          },
          {
            'id': 'health_hygiene',
            'title': 'Health & Hygiene',
            'description':
                'Important facts about menstrual health and hygiene practices',
            'icon': 'health_and_safety',
            'color': 'green',
            'questions': 12,
            'difficulty': 'Intermediate',
            'estimatedTime': '6 min',
            'quiz_questions': [
              {
                'question':
                    'What is the best way to clean the vaginal area during periods?',
                'options': [
                  'Scented soap',
                  'Plain water or mild soap',
                  'Douching',
                  'Antiseptic solution',
                ],
                'correct_answer': 1,
                'explanation':
                    'Plain water or mild, unscented soap is best for cleaning the external vaginal area.',
              },
            ],
          },
          {
            'id': 'myths_facts',
            'title': 'Myths vs Facts',
            'description': 'Separate period myths from scientific facts',
            'icon': 'fact_check',
            'color': 'orange',
            'questions': 15,
            'difficulty': 'Advanced',
            'estimatedTime': '8 min',
            'quiz_questions': [
              {
                'question': 'Is it safe to exercise during your period?',
                'options': [
                  'No, it can cause harm',
                  'Yes, exercise can actually help with cramps',
                  'Only light exercise',
                  'Exercise should be avoided completely',
                ],
                'correct_answer': 1,
                'explanation':
                    'Exercise during periods is safe and can help reduce cramps and improve mood through endorphin release.',
              },
            ],
          },
        ],
        'last_updated': DateTime.now(),
      });

      print('Content seeded successfully in Firestore');
    } catch (e) {
      print('Error seeding content: $e');
    }
  }

  void _loadFallbackContent() {
    print('Loading fallback content...');
    // Fallback content if Firestore is unavailable
    _searchableContent = [
      {
        'title': 'Menstrual Cycle',
        'description': 'Learn about your cycle phases',
        'type': 'article',
      },
      {
        'title': 'Product Guide',
        'description': 'Find the right products for you',
        'type': 'guide',
      },
    ];

    _forYouTips = [
      {
        'phase': 'menstrual',
        'day_range': {'start': 1, 'end': 5},
        'tip':
            'Focus on iron-rich foods to replenish what you lose during menstruation.',
      },
    ];

    // Add fallback quiz data
    _quizData = [
      {
        'id': 'menstrual_basics',
        'title': 'Menstrual Cycle Basics',
        'description':
            'Test your knowledge about the menstrual cycle phases and hormones',
        'icon': 'favorite',
        'color': 'red',
        'questions': 10,
        'difficulty': 'Beginner',
        'estimatedTime': '5 min',
        'quiz_questions': [
          {
            'question': 'How long is the average menstrual cycle?',
            'options': ['21 days', '28 days', '35 days', '40 days'],
            'correct_answer': 1,
            'explanation':
                'The average menstrual cycle is 28 days, though normal cycles can range from 21-35 days.',
          },
        ],
      },
      {
        'id': 'period_products',
        'title': 'Period Products Knowledge',
        'description':
            'Learn about different period products and their proper usage',
        'icon': 'inventory_2',
        'color': 'purple',
        'questions': 8,
        'difficulty': 'Beginner',
        'estimatedTime': '4 min',
        'quiz_questions': [
          {
            'question': 'How often should you change a tampon?',
            'options': [
              'Every 12 hours',
              'Every 8 hours',
              'Every 4-6 hours',
              'Once a day',
            ],
            'correct_answer': 2,
            'explanation':
                'Tampons should be changed every 4-6 hours to prevent bacterial growth and TSS risk.',
          },
        ],
      },
    ];
    print('Loaded ${_quizData.length} fallback quizzes');
  }

  String getPersonalizedTip(int currentDay) {
    for (var tip in _forYouTips) {
      final dayRange = tip['day_range'] as Map<String, dynamic>;
      if (currentDay >= dayRange['start'] && currentDay <= dayRange['end']) {
        return tip['tip'] ?? 'Stay hydrated and listen to your body.';
      }
    }
    return 'Every day is a good day to take care of yourself.';
  }

  Future<void> updateContent(String docId, Map<String, dynamic> content) async {
    try {
      await _firestore.collection('app_content').doc(docId).update(content);
      await _loadContentFromFirestore();
    } catch (e) {
      print('Error updating content: $e');
    }
  }

  Future<void> addSearchableContent(Map<String, dynamic> newContent) async {
    try {
      _searchableContent.add(newContent);
      await _firestore
          .collection('app_content')
          .doc('searchable_content')
          .update({
            'content': _searchableContent,
            'last_updated': DateTime.now(),
          });
      notifyListeners();
    } catch (e) {
      print('Error adding searchable content: $e');
    }
  }

  List<Map<String, dynamic>> searchContent(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _searchableContent.where((item) {
      final title = item['title']?.toString().toLowerCase() ?? '';
      final description = item['description']?.toString().toLowerCase() ?? '';
      return title.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }

  IconData getIconForType(String type) {
    switch (type) {
      case 'cycle':
        return Icons.refresh;
      case 'symptoms':
        return Icons.health_and_safety;
      case 'disposable':
        return Icons.inventory_2;
      case 'reusable':
        return Icons.eco;
      case 'tracking':
        return Icons.analytics;
      case 'benefits':
        return Icons.star;
      case 'myths':
        return Icons.fact_check;
      case 'positivity':
        return Icons.favorite;
      case 'ovulation':
        return Icons.track_changes;
      default:
        return Icons.article;
    }
  }

  Future<void> refreshContent() async {
    _isInitialized = false;
    _quizData.clear();
    _searchableContent.clear();
    _forYouTips.clear();
    _learningContent.clear();
    _communityPosts.clear();
    await _initializeContent();
  }

  Future<void> forceReseedContent() async {
    print('Force reseeding all content...');
    _isInitialized = false;
    _quizData.clear();
    _searchableContent.clear();
    _forYouTips.clear();
    _learningContent.clear();
    _communityPosts.clear();

    // Force reseed by clearing Firestore docs first
    try {
      await _firestore.collection('app_content').doc('quiz_data').delete();
      await _firestore
          .collection('app_content')
          .doc('searchable_content')
          .delete();
      await _firestore.collection('app_content').doc('for_you_tips').delete();
      await _firestore
          .collection('app_content')
          .doc('learning_content')
          .delete();
      await _firestore
          .collection('app_content')
          .doc('community_posts')
          .delete();
    } catch (e) {
      print('Error clearing Firestore docs (they may not exist): $e');
    }

    await _initializeContent();
  }
}
