import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../models/daily_log.dart';

class LogMoodScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const LogMoodScreen({super.key, this.selectedDate});

  @override
  State<LogMoodScreen> createState() => _LogMoodScreenState();
}

class _LogMoodScreenState extends State<LogMoodScreen> {
  late DateTime _selectedDate;
  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _moodOptions = [
    {
      'value': 'Happy',
      'title': 'Happy',
      'emoji': '😊',
      'color': Colors.yellow.shade600,
      'description': 'Feeling joyful and positive',
    },
    {
      'value': 'Calm',
      'title': 'Calm',
      'emoji': '😌',
      'color': Colors.green.shade400,
      'description': 'Peaceful and relaxed',
    },
    {
      'value': 'Energetic',
      'title': 'Energetic',
      'emoji': '🤗',
      'color': Colors.orange.shade500,
      'description': 'Full of energy and motivation',
    },
    {
      'value': 'Neutral',
      'title': 'Neutral',
      'emoji': '😐',
      'color': Colors.grey.shade500,
      'description': 'Feeling balanced, neither up nor down',
    },
    {
      'value': 'Tired',
      'title': 'Tired',
      'emoji': '😴',
      'color': Colors.blue.shade400,
      'description': 'Low energy, need rest',
    },
    {
      'value': 'Stressed',
      'title': 'Stressed',
      'emoji': '😰',
      'color': Colors.red.shade400,
      'description': 'Feeling overwhelmed or anxious',
    },
    {
      'value': 'Sad',
      'title': 'Sad',
      'emoji': '😢',
      'color': Colors.blue.shade600,
      'description': 'Feeling down or emotional',
    },
    {
      'value': 'Irritated',
      'title': 'Irritated',
      'emoji': '😤',
      'color': Colors.red.shade500,
      'description': 'Feeling annoyed or frustrated',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _loadExistingData();
  }

  void _loadExistingData() {
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    final existingLog = cycleProvider.getDailyLogForDate(_selectedDate);

    if (existingLog != null) {
      _selectedMood = existingLog.mood;
      _notesController.text = existingLog.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Log Mood'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveMood,
            child: Text(
              'Save',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date selector
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mood selection
            Text(
              'How are you feeling today?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio:
                    0.9, // Reduced to give more height for content
              ),
              itemCount: _moodOptions.length,
              itemBuilder: (context, index) {
                return _buildMoodOption(_moodOptions[index]);
              },
            ),

            const SizedBox(height: 24),

            // Notes section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes (Optional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'What influenced your mood today?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
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

  Widget _buildMoodOption(Map<String, dynamic> option) {
    final theme = Theme.of(context);
    final isSelected = _selectedMood == option['value'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = option['value'];
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12), // Reduced padding
        decoration: BoxDecoration(
          color: isSelected
              ? option['color'].withValues(alpha: 0.2)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: option['color'], width: 2)
              : Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
          children: [
            Text(
              option['emoji'],
              style: const TextStyle(fontSize: 28),
            ), // Slightly smaller emoji
            const SizedBox(height: 6), // Reduced spacing
            Flexible(
              // Wrap title in Flexible
              child: Text(
                option['title'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14, // Slightly smaller font
                  color: isSelected
                      ? option['color']
                      : theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 2), // Reduced spacing
            Flexible(
              // Wrap description in Flexible
              child: Text(
                option['description'],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10, // Smaller font for description
                  color: isSelected
                      ? option['color'].withValues(alpha: 0.8)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2, // Allow up to 2 lines
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadExistingData(); // Reload data for the new date
    }
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);

    // Get existing log or create new one
    DailyLog dailyLog =
        cycleProvider.getDailyLogForDate(_selectedDate) ??
        DailyLog(date: _selectedDate);

    // Update mood data
    dailyLog = DailyLog(
      id: dailyLog.id,
      date: _selectedDate,
      flowIntensity: dailyLog.flowIntensity,
      mood: _selectedMood,
      symptoms: dailyLog.symptoms,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      await cycleProvider.saveDailyLog(dailyLog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mood: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
