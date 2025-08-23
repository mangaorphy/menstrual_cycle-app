import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<String> _quickTopics = [
    'Ovulation',
    'Pregnancy',
    'PMS',
    'Cramps',
    'Diet',
    'Exercise',
  ];

  final List<Map<String, dynamic>> _reproductiveHealthTopics = [
    {
      'title': 'Understanding Your Cycle',
      'subtitle': 'Learn about the phases of your menstrual cycle',
      'icon': Icons.sync_rounded,
      'color': Colors.purple,
    },
    {
      'title': 'Ovulation Signs',
      'subtitle': 'Recognize the signs of ovulation',
      'icon': Icons.favorite,
      'color': Colors.pink,
    },
    {
      'title': 'Period Health',
      'subtitle': 'What\'s normal and when to see a doctor',
      'icon': Icons.health_and_safety,
      'color': Colors.red,
    },
    {
      'title': 'Fertility Awareness',
      'subtitle': 'Understanding your fertile window',
      'icon': Icons.child_care,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _sexTopics = [
    {
      'title': 'Safe Sex Practices',
      'subtitle': 'Protection and contraception methods',
      'icon': Icons.shield,
      'color': Colors.green,
    },
    {
      'title': 'Sexual Health',
      'subtitle': 'Maintaining sexual wellness',
      'icon': Icons.healing,
      'color': Colors.blue,
    },
    {
      'title': 'Communication',
      'subtitle': 'Talking about sexual health with partners',
      'icon': Icons.chat,
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(isDarkMode),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickTopics(isDarkMode),
                      const SizedBox(height: 30),
                      _buildSectionTitle('Reproductive Health', isDarkMode),
                      const SizedBox(height: 16),
                      _buildTopicCards(_reproductiveHealthTopics, isDarkMode),
                      const SizedBox(height: 30),
                      _buildSectionTitle('Sex & Relationships', isDarkMode),
                      const SizedBox(height: 16),
                      _buildTopicCards(_sexTopics, isDarkMode),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top row with back button and title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
                    Icons.arrow_back,
                    color: isDarkMode ? Colors.white : Colors.black87,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Health Insights',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40), // Balance the back button
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Search section
          if (!_isSearching) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Explore topics and get personalized insights about your reproductive health.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode 
                          ? Colors.white.withOpacity(0.8) 
                          : Colors.grey[600],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  icon: Container(
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
                      Icons.search,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search health topics...',
                  hintStyle: TextStyle(
                    color: isDarkMode 
                        ? Colors.white.withOpacity(0.6) 
                        : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            size: 20,
                          ),
                        ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickTopics(bool isDarkMode) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Topics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _quickTopics.map((topic) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                ),
                child: Text(
                  topic,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildTopicCards(List<Map<String, dynamic>> topics, bool isDarkMode) {
    return Column(
      children: topics.map((topic) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
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
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: topic['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  topic['icon'],
                  color: topic['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode 
                            ? Colors.white 
                            : const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic['subtitle'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.8)
                            : const Color(0xFF4A5568),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.6)
                    : const Color(0xFF4A5568),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
