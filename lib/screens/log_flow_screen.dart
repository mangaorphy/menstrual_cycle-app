import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../models/daily_log.dart';

class LogFlowScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const LogFlowScreen({super.key, this.selectedDate});

  @override
  State<LogFlowScreen> createState() => _LogFlowScreenState();
}

class _LogFlowScreenState extends State<LogFlowScreen> {
  late DateTime _selectedDate;
  String? _selectedFlow;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _flowOptions = [
    {
      'value': 'Light',
      'title': 'Light Flow',
      'description': 'Less than usual, might need fewer products.',
      'icon': Icons.water_drop_outlined,
    },
    {
      'value': 'Normal',
      'title': 'Normal Flow',
      'description': 'A typical amount for you, following your usual routine.',
      'icon': Icons.water_drop,
    },
    {
      'value': 'Heavy',
      'title': 'Heavy Flow',
      'description': 'More than usual, might need extra protection.',
      'icon': Icons.water_drop,
    },
    {
      'value': 'Spotting',
      'title': 'Spotting',
      'description': 'Very light, occasional drops outside of your period.',
      'icon': Icons.circle_outlined,
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
        _selectedFlow = existingLog.flowIntensity;
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
          'Log Flow',
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
            _buildSectionTitle('How is your flow today?'),
            const SizedBox(height: 16),
            ..._flowOptions.map((option) => _buildFlowCard(option)),
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
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildFlowCard(Map<String, dynamic> option) {
    final theme = Theme.of(context);
    final isSelected = _selectedFlow == option['value'];

    return GestureDetector(
      onTap: () => setState(() => _selectedFlow = option['value']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(option['icon'], color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
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
        onPressed: _isLoading ? null : _saveFlow,
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

  Future<void> _saveFlow() async {
    if (_selectedFlow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a flow type.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
      final existingLog = cycleProvider.getDailyLogForDate(_selectedDate);

      final newLog = DailyLog(
        id: existingLog?.id ?? DateTime.now().toIso8601String(),
        date: _selectedDate,
        flowIntensity: _selectedFlow,
        moods: existingLog?.moods ?? [],
        symptoms: existingLog?.symptoms ?? [],
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await cycleProvider.addOrUpdateDailyLog(newLog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flow log saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving flow log: $e'),
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
