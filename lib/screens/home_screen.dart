import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menstrual_tracker/providers/cycle_provider.dart';
import 'package:menstrual_tracker/models/cycle_data.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:menstrual_tracker/screens/stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);

    // Sample data - replace with your actual data
    final DateTime nextPeriodStart = DateTime.now().add(const Duration(days: 5));
    final DateTime fertileStart = DateTime.now().add(const Duration(days: -5));
    final DateTime ovulationDate = DateTime.now().add(const Duration(days: -2));
    final bool isPeriodDay = true;
    final int cycleDay = 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cycle Tracker', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddPeriodDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Period Summary Section
              _buildPeriodSummary(context, nextPeriodStart),
              const SizedBox(height: 24),
              
              // Cycle Phase Section
              _buildCyclePhaseSection(fertileStart, ovulationDate),
              const SizedBox(height: 24),
              
              // Today's Status
              _buildTodayStatus(isPeriodDay, cycleDay),
              const SizedBox(height: 24),
              
              // Calendar
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  cycleProvider.setSelectedDate(selectedDay);
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final cycle = cycleProvider.getCycleForDate(date);
                    if (cycle != null) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          width: 8,
                          height: 8,
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Cycle Details
              _buildCycleDetails(cycleProvider),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildNavigationButtons(),
    );
  }

  Widget _buildPeriodSummary(BuildContext context, DateTime nextPeriodStart) {
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

  Widget _buildNavigationButtons() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.today),
          label: 'Today',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.self_improvement),
          label: 'Self Care',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analysis',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: Colors.purple[800],
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget _buildCycleDetails(CycleProvider cycleProvider) {
    if (cycleProvider.selectedDate == null) {
      return const SizedBox(); // Return empty if no date selected
    }

    final cycle = cycleProvider.getCycleForDate(cycleProvider.selectedDate!);
    
    if (cycle == null) {
      return const SizedBox(); // Return empty if no cycle for selected date
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Period Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Start Date: ${cycle.periodStartDate.toLocal().toString().split(' ')[0]}'),
          Text('End Date: ${cycle.periodEndDate.toLocal().toString().split(' ')[0]}'),
          Text('Cycle Length: ${cycle.cycleLength} days'),
          const SizedBox(height: 10),
          Text('Symptoms: ${cycle.symptoms.join(', ')}'),
          Text('Mood: ${cycle.mood}'),
          Text('Flow: ${cycle.flowIntensity}'),
        ],
      ),
    );
  }

  void _showAddPeriodDialog(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(Duration(days: 5));
    int cycleLength = 28;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Period'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start Date'),
                ElevatedButton(
                  child: Text('${startDate.toLocal().toString().split(' ')[0]}'),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                ),
                SizedBox(height: 10),
                Text('End Date'),
                ElevatedButton(
                  child: Text('${endDate.toLocal().toString().split(' ')[0]}'),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                ),
                SizedBox(height: 10),
                Text('Cycle Length (days)'),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    cycleLength = int.tryParse(value) ?? 28;
                  },
                  decoration: InputDecoration(
                    hintText: '28',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final newCycle = CycleData(
                  periodStartDate: startDate,
                  periodEndDate: endDate,
                  cycleLength: cycleLength,
                );
                cycleProvider.addCycle(newCycle);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}