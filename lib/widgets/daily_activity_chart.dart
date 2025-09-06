import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/hour_entry.dart';
import '../services/storage_service.dart';

class DailyActivityChart extends StatefulWidget {
  final DateTime date;

  const DailyActivityChart({
    super.key,
    required this.date,
  });

  @override
  State<DailyActivityChart> createState() => _DailyActivityChartState();
}

class _DailyActivityChartState extends State<DailyActivityChart> {
  final StorageService _storageService = StorageService();
  int _activitiesLogged = 0;
  int _emptyHours = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  @override
  void didUpdateWidget(DailyActivityChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date) {
      _loadActivityData();
    }
  }

  Future<void> _loadActivityData() async {
    setState(() {
      _isLoading = true;
    });

    final entries = await _storageService.getEntriesForDate(widget.date);
    final activitiesLogged = entries.where((entry) => entry.activity.trim().isNotEmpty).length;
    final emptyHours = 24 - activitiesLogged;

    setState(() {
      _activitiesLogged = activitiesLogged;
      _emptyHours = emptyHours;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Activity Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 150,
                    child: _activitiesLogged == 0 && _emptyHours == 24
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No activities logged',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: [
                                if (_activitiesLogged > 0)
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: _activitiesLogged.toDouble(),
                                    title: '',
                                    radius: 50,
                                  ),
                                if (_emptyHours > 0)
                                  PieChartSectionData(
                                    color: Colors.grey[300],
                                    value: _emptyHours.toDouble(),
                                    title: '',
                                    radius: 50,
                                  ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend and Stats
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        color: Colors.green,
                        label: 'Activities Logged',
                        value: _activitiesLogged,
                        total: 24,
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        color: Colors.grey[300]!,
                        label: 'Empty Hours',
                        value: _emptyHours,
                        total: 24,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _activitiesLogged >= 12 
                              ? Colors.green[50] 
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _activitiesLogged >= 12 
                                ? Colors.green[200]! 
                                : Colors.orange[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _activitiesLogged >= 12 
                                  ? Icons.check_circle 
                                  : Icons.schedule,
                              color: _activitiesLogged >= 12 
                                  ? Colors.green[700] 
                                  : Colors.orange[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _activitiesLogged >= 12
                                    ? 'Great day tracking!'
                                    : 'Keep logging activities',
                                style: TextStyle(
                                  color: _activitiesLogged >= 12 
                                      ? Colors.green[700] 
                                      : Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int value,
    required int total,
  }) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Text(
          '$value ($percentage%)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
