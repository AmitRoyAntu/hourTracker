import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class MonthlyOverviewWidget extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback? onTap;

  const MonthlyOverviewWidget({
    super.key,
    required this.selectedDate,
    this.onTap,
  });

  @override
  State<MonthlyOverviewWidget> createState() => _MonthlyOverviewWidgetState();
}

class _MonthlyOverviewWidgetState extends State<MonthlyOverviewWidget> {
  final StorageService _storageService = StorageService();
  List<FlSpot> _monthlyData = [];
  int _totalActivities = 0;
  int _totalDays = 0;
  int _activeDays = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  @override
  void didUpdateWidget(MonthlyOverviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate.month != oldWidget.selectedDate.month ||
        widget.selectedDate.year != oldWidget.selectedDate.year) {
      _loadMonthlyData();
    }
  }

  Future<void> _loadMonthlyData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final monthEnd = DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, 0);
    final totalDays = monthEnd.day;

    final monthlyData = <FlSpot>[];
    int totalActivities = 0;
    int activeDays = 0;

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(widget.selectedDate.year, widget.selectedDate.month, day);
      final entries = await _storageService.getEntriesForDate(date);
      final activitiesCount = entries.where((entry) => entry.activity.trim().isNotEmpty).length;
      
      monthlyData.add(FlSpot(day.toDouble(), activitiesCount.toDouble()));
      totalActivities += activitiesCount;
      if (activitiesCount > 0) activeDays++;
    }

    if (mounted) {
      setState(() {
        _monthlyData = monthlyData;
        _totalActivities = totalActivities;
        _totalDays = totalDays;
        _activeDays = activeDays;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final monthName = DateFormat('MMMM y').format(widget.selectedDate);

    return Card(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Overview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          monthName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Column(
                  children: [
                    // Line Chart
                    SizedBox(
                      height: 120,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 6,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: colorScheme.surfaceContainerHighest,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 5,
                                getTitlesWidget: (value, meta) {
                                  if (value % 5 == 0 && value <= _totalDays) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 6,
                                getTitlesWidget: (value, meta) {
                                  if (value % 6 == 0) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 1,
                          maxX: _totalDays.toDouble(),
                          minY: 0,
                          maxY: 24,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _monthlyData,
                              isCurved: true,
                              color: colorScheme.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: false,
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Monthly Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildMonthlyStatCard(
                            'Total Activities',
                            _totalActivities.toString(),
                            Icons.assignment_turned_in,
                            colorScheme.primary,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMonthlyStatCard(
                            'Active Days',
                            '$_activeDays/$_totalDays',
                            Icons.event_available,
                            colorScheme.secondary,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMonthlyStatCard(
                            'Daily Avg',
                            (_totalActivities / _totalDays).toStringAsFixed(1),
                            Icons.analytics,
                            colorScheme.tertiary,
                            theme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMonthlyProgress(theme, colorScheme),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgress(ThemeData theme, ColorScheme colorScheme) {
    final completionRate = _totalDays > 0 ? _activeDays / _totalDays : 0.0;
    final isGoodProgress = completionRate >= 0.5;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGoodProgress 
            ? colorScheme.primaryContainer 
            : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isGoodProgress ? Icons.trending_up : Icons.schedule,
            color: isGoodProgress 
                ? colorScheme.onPrimaryContainer 
                : colorScheme.onTertiaryContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGoodProgress ? 'Great monthly progress!' : 'Keep building the habit',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isGoodProgress 
                        ? colorScheme.onPrimaryContainer 
                        : colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: completionRate,
                  backgroundColor: (isGoodProgress 
                      ? colorScheme.onPrimaryContainer 
                      : colorScheme.onTertiaryContainer).withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation(
                    isGoodProgress 
                        ? colorScheme.onPrimaryContainer 
                        : colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(completionRate * 100).round()}%',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isGoodProgress 
                  ? colorScheme.onPrimaryContainer 
                  : colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
