import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../models/daily_log.dart';

class LogSymptomsScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const LogSymptomsScreen({super.key, this.selectedDate});

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  late DateTime _selectedDate;
  List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _symptomOptions = [
    {
      'value': 'Cramps',
      'title': 'Cramps',
      'icon': Icons.healing,
      'color': Colors.red.shade400,
      'category': 'Physical',
    },
    {
      'value': 'Headache',
      'title': 'Headache',
      'icon': Icons.psychology,
      'color': Colors.orange.shade400,
      'category': 'Physical',
    },
    {
      'value': 'Back Pain',
      'title': 'Back Pain',
      'icon': Icons.accessibility_new,
      'color': Colors.red.shade300,
      'category': 'Physical',
    },
    {
      'value': 'Bloating',
      'title': 'Bloating',
      'icon': Icons.bubble_chart,
      'color': Colors.blue.shade300,
      'category': 'Physical',
    },
    {
      'value': 'Breast Tenderness',
      'title': 'Breast Tenderness',
      'icon': Icons.favorite,
      'color': Colors.pink.shade300,
      'category': 'Physical',
    },
    {
      'value': 'Nausea',
      'title': 'Nausea',
      'icon': Icons.sick,
      'color': Colors.green.shade400,
      'category': 'Physical',
    },
    {
      'value': 'Fatigue',
      'title': 'Fatigue',
      'icon': Icons.battery_1_bar,
      'color': Colors.grey.shade500,
      'category': 'Physical',
    },
    {
      'value': 'Dizziness',
      'title': 'Dizziness',
      'icon': Icons.rotate_90_degrees_ccw,
      'color': Colors.cyan.shade400,
      'category': 'Physical',
    },
    {
      'value': 'Mood Swings',
      'title': 'Mood Swings',
      'icon': Icons.mood_bad,
      'color': Colors.purple.shade400,
      'category': 'Emotional',
    },
    {
      'value': 'Anxiety',
      'title': 'Anxiety',
      'icon': Icons.warning,
      'color': Colors.yellow.shade600,
      'category': 'Emotional',
    },
    {
      'value': 'Depression',
      'title': 'Depression',
      'icon': Icons.cloud,
      'color': Colors.indigo.shade400,
      'category': 'Emotional',
    },
    {
      'value': 'Irritability',
      'title': 'Irritability',
      'icon': Icons.flash_on,
      'color': Colors.deepOrange.shade400,
      'category': 'Emotional',
    },
    {
      'value': 'Food Cravings',
      'title': 'Food Cravings',
      'icon': Icons.restaurant,
      'color': Colors.brown.shade400,
      'category': 'Other',
    },
    {
      'value': 'Acne',
      'title': 'Acne',
      'icon': Icons.circle,
      'color': Colors.red.shade200,
      'category': 'Other',
    },
    {
      'value': 'Sleep Issues',
      'title': 'Sleep Issues',
      'icon': Icons.bedtime,
      'color': Colors.deepPurple.shade400,
      'category': 'Other',
    },
    {
      'value': 'Hot Flashes',
      'title': 'Hot Flashes',
      'icon': Icons.whatshot,
      'color': Colors.deepOrange.shade500,
      'category': 'Other',
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
      _selectedSymptoms = List.from(existingLog.symptoms);
      _notesController.text = existingLog.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedSymptoms {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final symptom in _symptomOptions) {
      final category = symptom['category'] as String;
      grouped[category] = grouped[category] ?? [];
      grouped[category]!.add(symptom);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Log Symptoms'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSymptoms,
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

            // Selected symptoms summary
            if (_selectedSymptoms.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Symptoms (${_selectedSymptoms.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedSymptoms.map((symptom) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            symptom,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Symptoms selection by category
            Text(
              'What symptoms are you experiencing?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            ..._groupedSymptoms.entries.map((entry) {
              return _buildSymptomCategory(entry.key, entry.value, theme);
            }).toList(),

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
                      hintText: 'Additional details about your symptoms...',
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

  Widget _buildSymptomCategory(
    String category,
    List<Map<String, dynamic>> symptoms,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: symptoms.length,
          itemBuilder: (context, index) {
            return _buildSymptomOption(symptoms[index]);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSymptomOption(Map<String, dynamic> option) {
    final theme = Theme.of(context);
    final isSelected = _selectedSymptoms.contains(option['value']);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSymptoms.remove(option['value']);
          } else {
            _selectedSymptoms.add(option['value']);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              option['icon'],
              color: isSelected
                  ? option['color']
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option['title'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? option['color']
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: option['color'], size: 16),
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
        _selectedSymptoms.clear(); // Clear selection when date changes
      });
      _loadExistingData(); // Reload data for the new date
    }
  }

  Future<void> _saveSymptoms() async {
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);

    // Get existing log or create new one
    DailyLog dailyLog =
        cycleProvider.getDailyLogForDate(_selectedDate) ??
        DailyLog(date: _selectedDate);

    // Update symptoms data
    dailyLog = DailyLog(
      id: dailyLog.id,
      date: _selectedDate,
      flowIntensity: dailyLog.flowIntensity,
      mood: dailyLog.mood,
      symptoms: _selectedSymptoms,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      await cycleProvider.saveDailyLog(dailyLog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedSymptoms.isEmpty
                  ? 'Symptoms cleared!'
                  : 'Symptoms logged successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving symptoms: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
