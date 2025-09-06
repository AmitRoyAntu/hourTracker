import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class WeeklyOverviewWidget extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback? onTap;

  const WeeklyOverviewWidget({
    Key? key,
    required this.selectedDate,
    this.onTap,
  }) : super(key: key);

  @override
  State<WeeklyOverviewWidget> createState() => _WeeklyOverviewWidgetState();
}

class _WeeklyOverviewWidgetState extends State<WeeklyOverviewWidget> {
  final StorageService _storageService = StorageService();
  List<double> _weeklyData = List.filled(7, 0);
  int _totalActivities = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  @override
  void didUpdateWidget(WeeklyOverviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _loadWeeklyData();
    }
  }

  Future<void> _loadWeeklyData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final weekStart = _getWeekStart(widget.selectedDate);
    final weeklyData = <double>[];
    int totalActivities = 0;

    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final entries = await _storageService.getEntriesForDate(date);
      final activitiesCount = entries.where((entry) => entry.activity.trim().isNotEmpty).length;
      weeklyData.add(activitiesCount.toDouble());
      totalActivities += activitiesCount;
    }

    if (mounted) {
      setState(() {
        _weeklyData = weeklyData;
        _totalActivities = totalActivities;
        _isLoading = false;
      });
    }
  }

  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weekStart = _getWeekStart(widget.selectedDate);
    final weekEnd = weekStart.add(const Duration(days: 6));

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
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.date_range,
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
                          'Weekly Overview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}',
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
                    // Bar Chart
                    SizedBox(
                      height: 120,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 24,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                  return Text(
                                    days[value.toInt()],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
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
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 6,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: colorScheme.surfaceVariant,
                                strokeWidth: 1,
                              );
                            },
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _weeklyData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final value = entry.value;
                            
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: value,
                                  color: _getBarColor(value, colorScheme),
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Weekly Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildWeeklyStatCard(
                            'Total Activities',
                            _totalActivities.toString(),
                            Icons.task_alt,
                            colorScheme.primary,
                            theme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildWeeklyStatCard(
                            'Daily Average',
                            (_totalActivities / 7).toStringAsFixed(1),
                            Icons.trending_up,
                            colorScheme.secondary,
                            theme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBarColor(double value, ColorScheme colorScheme) {
    if (value >= 18) return colorScheme.primary;
    if (value >= 12) return colorScheme.secondary;
    if (value >= 6) return colorScheme.tertiary;
    return colorScheme.surfaceVariant;
  }

  Widget _buildWeeklyStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
