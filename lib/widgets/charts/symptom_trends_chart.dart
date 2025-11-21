import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/cycle_provider.dart';
import '../../models/daily_log.dart';

class SymptomTrendsChart extends StatelessWidget {
  const SymptomTrendsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleProvider = Provider.of<CycleProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Symptom Trends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last 7 days',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildChart(cycleProvider, isDarkMode, theme)),
        ],
      ),
    );
  }

  Widget _buildChart(
    CycleProvider cycleProvider,
    bool isDarkMode,
    ThemeData theme,
  ) {
    final logs = cycleProvider.dailyLogs
        .where((log) => log.symptoms != null && log.symptoms!.isNotEmpty)
        .toList();

    // If no data, show sample chart with empty state
    if (logs.isEmpty) {
      return _buildEmptyState(theme);
    }

    return LineChart(_buildChartData(cycleProvider, isDarkMode));
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.show_chart,
          size: 48,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'No symptom data yet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start logging your symptoms to see trends',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Sample chart preview
        Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: LineChart(_buildSampleChart(theme)),
        ),
      ],
    );
  }

  LineChartData _buildSampleChart(ThemeData theme) {
    // Sample data points
    final sampleSpots = [
      const FlSpot(0, 1),
      const FlSpot(1, 3),
      const FlSpot(2, 2),
      const FlSpot(3, 4),
      const FlSpot(4, 3),
      const FlSpot(5, 2),
      const FlSpot(6, 1),
    ];

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: sampleSpots,
          isCurved: true,
          color: theme.colorScheme.primary.withOpacity(0.3),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: theme.colorScheme.primary.withOpacity(0.1),
          ),
        ),
      ],
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 5,
    );
  }

  LineChartData _buildChartData(CycleProvider cycleProvider, bool isDarkMode) {
    final logs = cycleProvider.dailyLogs
        .where((log) => log.symptoms != null && log.symptoms!.isNotEmpty)
        .toList();
    final spots = _getChartSpots(logs);

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              // Simplified date labels
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Day ${value.toInt()}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.pink,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.pink.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getChartSpots(List<DailyLog> logs) {
    if (logs.isEmpty) {
      return [];
    }
    // Normalize data for chart
    final spots = logs.asMap().entries.map((entry) {
      final index = entry.key;
      final log = entry.value;
      // Use number of symptoms as Y value
      final yValue = (log.symptoms?.length ?? 0).toDouble();
      return FlSpot(index.toDouble(), yValue);
    }).toList();
    return spots;
  }
}
