import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/cycle_provider.dart';
import '../models/cycle_data.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cycleProvider = Provider.of<CycleProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Cycle Calendar',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Legend
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendar Legend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem('Period', Colors.red.shade300, theme),
                    _buildLegendItem('Fertile', Colors.green.shade300, theme),
                    _buildLegendItem('Ovulation', Colors.blue.shade300, theme),
                    _buildLegendItem('Safe', Colors.grey.shade300, theme),
                  ],
                ),
              ],
            ),
          ),

          // Calendar
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar<CycleData>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: theme.colorScheme.primary),
                  holidayTextStyle: TextStyle(color: theme.colorScheme.primary),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  formatButtonTextStyle: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  titleTextStyle: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildDayCell(day, cycleProvider, theme);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    return _buildDayCell(
                      day,
                      cycleProvider,
                      theme,
                      isToday: true,
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return _buildDayCell(
                      day,
                      cycleProvider,
                      theme,
                      isSelected: true,
                    );
                  },
                ),
                onDaySelected: _onDaySelected,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
          ),

          // Selected Day Info
          if (_selectedDay != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildSelectedDayInfo(cycleProvider, theme),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    DateTime day,
    CycleProvider cycleProvider,
    ThemeData theme, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final dayType = _getDayType(day, cycleProvider);
    Color backgroundColor = Colors.transparent;
    Color textColor = theme.colorScheme.onSurface;

    switch (dayType) {
      case 'period':
        backgroundColor = Colors.red.shade300;
        textColor = Colors.white;
        break;
      case 'fertile':
        backgroundColor = Colors.green.shade300;
        textColor = Colors.white;
        break;
      case 'ovulation':
        backgroundColor = Colors.blue.shade300;
        textColor = Colors.white;
        break;
      case 'safe':
        backgroundColor = Colors.grey.shade200;
        break;
    }

    if (isSelected) {
      backgroundColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
    } else if (isToday) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.5);
      textColor = theme.colorScheme.onPrimary;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  String _getDayType(DateTime day, CycleProvider cycleProvider) {
    // Find the most recent cycle that includes or precedes this day
    for (final cycle in cycleProvider.cycles) {
      final cycleStart = cycle.periodStartDate;
      final cycleEnd = cycleStart.add(Duration(days: cycle.cycleLength));

      if (day.isAfter(cycleStart.subtract(const Duration(days: 1))) &&
          day.isBefore(cycleEnd.add(const Duration(days: 1)))) {
        final daysSinceStart = day.difference(cycleStart).inDays;

        // Period days
        if (daysSinceStart >= 0 && daysSinceStart < cycle.periodLength) {
          return 'period';
        }

        // Ovulation (around day 14 of a typical 28-day cycle)
        final ovulationDay = (cycle.cycleLength / 2).round() - 1;
        if (daysSinceStart == ovulationDay) {
          return 'ovulation';
        }

        // Fertile window (5 days before ovulation + ovulation day + 1 day after)
        if (daysSinceStart >= ovulationDay - 5 &&
            daysSinceStart <= ovulationDay + 1) {
          return 'fertile';
        }

        // Safe days
        return 'safe';
      }
    }

    // If no cycle data, predict based on average cycle
    if (cycleProvider.cycles.isNotEmpty) {
      final lastCycle = cycleProvider.cycles.first;
      final daysSinceLastPeriod = day
          .difference(lastCycle.periodStartDate)
          .inDays;
      final avgCycleLength = cycleProvider.averageCycleLength;

      // Predict next period
      if (daysSinceLastPeriod >= avgCycleLength &&
          daysSinceLastPeriod < avgCycleLength + 5) {
        return 'period';
      }

      // Predict fertile window
      final predictedOvulation = avgCycleLength ~/ 2;
      if (daysSinceLastPeriod >= predictedOvulation - 5 &&
          daysSinceLastPeriod <= predictedOvulation + 1) {
        return 'fertile';
      }

      if (daysSinceLastPeriod == predictedOvulation) {
        return 'ovulation';
      }
    }

    return 'safe';
  }

  Widget _buildSelectedDayInfo(CycleProvider cycleProvider, ThemeData theme) {
    final dayType = _getDayType(_selectedDay!, cycleProvider);
    String title = '';
    String description = '';
    Color color = Colors.grey;

    switch (dayType) {
      case 'period':
        title = 'Period Day';
        description =
            'You are likely on your period today. Track your flow and symptoms.';
        color = Colors.red;
        break;
      case 'fertile':
        title = 'Fertile Window';
        description = 'High chance of pregnancy. This is your fertile window.';
        color = Colors.green;
        break;
      case 'ovulation':
        title = 'Ovulation Day';
        description = 'Peak fertility day. Highest chance of pregnancy.';
        color = Colors.blue;
        break;
      case 'safe':
        title = 'Safe Day';
        description = 'Lower chance of pregnancy. Considered a safe day.';
        color = Colors.grey;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  List<CycleData> _getEventsForDay(DateTime day) {
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    return cycleProvider.cycles.where((cycle) {
      return isSameDay(cycle.periodStartDate, day) ||
          (cycle.periodEndDate != null &&
              day.isAfter(
                cycle.periodStartDate.subtract(const Duration(days: 1)),
              ) &&
              day.isBefore(cycle.periodEndDate!.add(const Duration(days: 1))));
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }
}
