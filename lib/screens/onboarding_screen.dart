import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onCompleted;
  
  const OnboardingScreen({Key? key, required this.onCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with your actual data
    final DateTime nextPeriodStart = DateTime.now().add(const Duration(days: 5));
    final DateTime fertileStart = DateTime.now().add(const Duration(days: -5));
    final DateTime ovulationDate = DateTime.now().add(const Duration(days: -2));
    final bool isPeriodDay = true;
    final int cycleDay = 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Section
              _buildPeriodSection(context, nextPeriodStart),
              const SizedBox(height: 24),
              
              // Cycle Phase Section
              _buildCyclePhaseSection(fertileStart, ovulationDate),
              const SizedBox(height: 24),
              
              // Today's Status
              _buildTodayStatus(isPeriodDay, cycleDay),
              const Spacer(),
              
              // Get Started Button
              _buildGetStartedButton(context),
              const SizedBox(height: 16),
              
              // Navigation Buttons (disabled during onboarding)
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSection(BuildContext context, DateTime nextPeriodStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.purple[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '1st Day',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            Text(
              '${DateFormat('MMM d').format(nextPeriodStart)} - Next Period',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(thickness: 1),
        const SizedBox(height: 8),
        Text(
          'Period Ends',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCyclePhaseSection(DateTime fertileStart, DateTime ovulationDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cycle phase',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.purple[800],
          ),
        ),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '${DateFormat('MMM d').format(fertileStart)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '${DateFormat('MMM d').format(ovulationDate)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Text('Next Fertile', style: TextStyle(color: Colors.grey[600])),
                Text('Ovulation', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayStatus(bool isPeriodDay, int cycleDay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPeriodDay ? Colors.red[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Day $cycleDay',
                style: TextStyle(
                  color: isPeriodDay ? Colors.red[800] : Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onCompleted,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Opacity(
      opacity: 0.5, // Make it visually disabled
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(Icons.today, 'Today', isSelected: true),
          _buildNavButton(Icons.calendar_today, 'Calendar'),
          _buildNavButton(Icons.self_improvement, 'Self Care'),
          _buildNavButton(Icons.analytics, 'Analysis'),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.purple[800] : Colors.grey[600],
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.purple[800] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}