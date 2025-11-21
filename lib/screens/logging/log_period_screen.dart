import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cycle_provider.dart';
import '../../models/cycle_data.dart';

class LogPeriodScreen extends StatefulWidget {
  final CycleData? existingCycle; // For editing existing cycle

  const LogPeriodScreen({super.key, this.existingCycle});

  @override
  State<LogPeriodScreen> createState() => _LogPeriodScreenState();
}

class _LogPeriodScreenState extends State<LogPeriodScreen> {
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  int _selectedFlow = 2; // 0: Light, 1: Normal, 2: Heavy
  List<String> _selectedSymptoms = [];
  String _notes = '';
  bool _isLoading = false;

  final List<String> _flowTypes = ['Light', 'Normal', 'Heavy'];
  final List<String> _symptomsList = [
    'Cramps',
    'Bloating',
    // ... existing code
    'Acne',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.existingCycle != null) {
      final cycle = widget.existingCycle!;
      _selectedStartDate = cycle.periodStartDate;
      _selectedEndDate = cycle.periodEndDate;
      _selectedFlow = _flowTypes.indexOf(cycle.flowIntensity).clamp(0, 2);
      _selectedSymptoms = List<String>.from(cycle.symptoms);
      _notes = cycle.notes ?? '';
    }
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
          widget.existingCycle != null ? 'Edit Period' : 'Log Period',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: widget.existingCycle != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _showDeleteDialog,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start Date Section
            _buildSectionTitle('Period Start Date'),
            const SizedBox(height: 12),
            _buildDateCard(
              'Start Date',
              _selectedStartDate,
              () => _selectDate(context, isStartDate: true),
            ),
            const SizedBox(height: 24),

            // End Date Section
            _buildSectionTitle('Period End Date (Optional)'),
            const SizedBox(height: 12),
            _buildDateCard(
              _selectedEndDate == null ? 'Select End Date' : 'End Date',
              _selectedEndDate ?? DateTime.now(),
              () => _selectDate(context, isStartDate: false),
              isOptional: _selectedEndDate == null,
            ),
            const SizedBox(height: 24),

            // Flow Section
            _buildSectionTitle('Flow Intensity'),
            const SizedBox(height: 12),
            _buildFlowSelector(),
            const SizedBox(height: 24),

            // Symptoms Section
            _buildSectionTitle('Symptoms'),
            const SizedBox(height: 12),
            _buildSymptomsSelector(),
            const SizedBox(height: 24),

            // Notes Section
            _buildSectionTitle('Notes (Optional)'),
            const SizedBox(height: 12),
            _buildNotesField(),
            const SizedBox(height: 40),

            // Save Button
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

  Widget _buildDateCard(
    String label,
    DateTime date,
    VoidCallback onTap, {
    bool isOptional = false,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOptional
                ? theme.colorScheme.outline.withOpacity(0.3)
                : theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isOptional
                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isOptional
                        ? theme.colorScheme.onSurface.withOpacity(0.5)
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowSelector() {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(_flowTypes.length, (index) {
        final isSelected = _selectedFlow == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedFlow = index),
            child: Container(
              margin: EdgeInsets.only(
                right: index < _flowTypes.length - 1 ? 12 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    index == 0
                        ? Icons.water_drop_outlined
                        : index == 1
                        ? Icons.water_drop
                        : Icons.water_drop,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                    size: index == 2 ? 28 : 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _flowTypes[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSymptomsSelector() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _symptomsList.map((symptom) {
        final isSelected = _selectedSymptoms.contains(symptom);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSymptoms.remove(symptom);
              } else {
                _selectedSymptoms.add(symptom);
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
              symptom,
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
      }).toList(),
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
        maxLines: 4,
        onChanged: (value) => _notes = value,
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
        onPressed: _isLoading ? null : _savePeriod,
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
            : Text(
                widget.existingCycle != null ? 'Update Period' : 'Save Period',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Period'),
        content: const Text(
          'Are you sure you want to delete this period record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.existingCycle != null) {
      await _deletePeriod();
    }
  }

  Future<void> _deletePeriod() async {
    if (widget.existingCycle?.id == null) return;

    setState(() => _isLoading = true);

    try {
      final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
      await cycleProvider.deleteCycle(widget.existingCycle!.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Period deleted successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting period: $e'),
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

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _selectedStartDate
          : (_selectedEndDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          // Reset end date if it's before start date
          if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
            _selectedEndDate = null;
          }
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _savePeriod() async {
    // Validation
    if (_selectedEndDate != null &&
        _selectedEndDate!.isBefore(_selectedStartDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cycleProvider = Provider.of<CycleProvider>(context, listen: false);

      if (widget.existingCycle != null) {
        // Update existing cycle
        final updatedCycle = widget.existingCycle!;
        updatedCycle.periodStartDate = _selectedStartDate;
        updatedCycle.periodEndDate = _selectedEndDate;
        updatedCycle.flowIntensity = _flowTypes[_selectedFlow];
        updatedCycle.symptoms = _selectedSymptoms;
        updatedCycle.notes = _notes.isEmpty ? null : _notes;

        // Recalculate period length
        if (_selectedEndDate != null) {
          updatedCycle.periodLength =
              _selectedEndDate!.difference(_selectedStartDate).inDays + 1;
        } else {
          updatedCycle.periodLength = 5; // default
        }

        await cycleProvider.updateCycle(updatedCycle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Period updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Add new cycle
        final newCycle = CycleData(
          id: DateTime.now().toIso8601String(),
          periodStartDate: _selectedStartDate,
          periodEndDate: _selectedEndDate,
          flowIntensity: _flowTypes[_selectedFlow],
          symptoms: _selectedSymptoms,
          notes: _notes.isEmpty ? null : _notes,
          periodLength: _selectedEndDate != null
              ? _selectedEndDate!.difference(_selectedStartDate).inDays + 1
              : 5, // default
          cycleLength: 28, // default, will be updated later
        );

        await cycleProvider.addCycle(newCycle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Period saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving period: $e'),
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
