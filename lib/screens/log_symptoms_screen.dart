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
  final List<String> _selectedSymptoms = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _symptomCategories = [
    {
      'name': 'Common',
      'symptoms': [
        {'value': 'Cramps'},
        {'value': 'Bloating'},
        {'value': 'Headache'},
        {'value': 'Mood Swings'},
        {'value': 'Back Pain'},
        {'value': 'Fatigue'},
        {'value': 'Nausea'},
        {'value': 'Tender Breasts'},
      ],
    },
    {
      'name': 'Body',
      'symptoms': [
        {'value': 'Acne'},
        {'value': 'Chills'},
        {'value': 'Constipation'},
        {'value': 'Diarrhea'},
        {'value': 'Dizziness'},
        {'value': 'Joint Pain'},
        {'value': 'Hot Flashes'},
      ],
    },
    {
      'name': 'Mind',
      'symptoms': [
        {'value': 'Anxiety'},
        {'value': 'Confusion'},
        {'value': 'Depression'},
        {'value': 'Irritability'},
        {'value': 'Low Libido'},
        {'value': 'Stress'},
      ],
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
      setState(() {
        if (existingLog.symptoms != null) {
          _selectedSymptoms.addAll(existingLog.symptoms!);
        }
        _notesController.text = existingLog.notes ?? '';
      });
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Log Symptoms',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._symptomCategories
                .map((category) => _buildSymptomCategory(category))
                ,
            const SizedBox(height: 24),
            _buildSectionTitle('Notes (Optional)'),
            const SizedBox(height: 12),
            _buildNotesField(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSymptomCategory(Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(category['name']),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (category['symptoms'] as List<Map<String, dynamic>>)
              .map((symptom) => _buildSymptomChip(symptom))
              .toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSymptomChip(Map<String, dynamic> symptom) {
    final theme = Theme.of(context);
    final isSelected = _selectedSymptoms.contains(symptom['value']);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSymptoms.remove(symptom['value']);
          } else {
            _selectedSymptoms.add(symptom['value']!);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          symptom['value']!,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Add any additional notes...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSymptoms,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : const Text(
                'Save Log',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _saveSymptoms() async {
    setState(() => _isLoading = true);

    try {
      final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
      final existingLog = cycleProvider.getDailyLogForDate(_selectedDate);

      final newLog = DailyLog(
        id: existingLog?.id ?? DateTime.now().toIso8601String(),
        date: _selectedDate,
        symptoms: _selectedSymptoms,
        flowIntensity: existingLog?.flowIntensity,
        moods: existingLog?.moods ?? [],
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await cycleProvider.addOrUpdateDailyLog(newLog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Symptom log saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving symptom log: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
