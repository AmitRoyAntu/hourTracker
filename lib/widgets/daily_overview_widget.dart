import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

class DailyOverviewWidget extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback? onTap;

  const DailyOverviewWidget({
    Key? key,
    required this.selectedDate,
    this.onTap,
  }) : super(key: key);

  @override
  State<DailyOverviewWidget> createState() => _DailyOverviewWidgetState();
}

class _DailyOverviewWidgetState extends State<DailyOverviewWidget>
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  int _activitiesLogged = 0;
  int _emptyHours = 0;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOut,
    ));
    _loadActivityData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DailyOverviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _loadActivityData();
    }
  }

  Future<void> _loadActivityData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final entries = await _storageService.getEntriesForDate(widget.selectedDate);
    final activitiesLogged = entries.where((entry) => entry.activity.trim().isNotEmpty).length;
    final emptyHours = 24 - activitiesLogged;

    if (mounted) {
      setState(() {
        _activitiesLogged = activitiesLogged;
        _emptyHours = emptyHours;
        _isLoading = false;
      });
      
      _animationController.reset();
      _chartAnimationController.reset();
      _animationController.forward();
      _chartAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isToday = _isSameDay(widget.selectedDate, DateTime.now());

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: isToday
                    ? [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withOpacity(0.7),
                      ]
                    : [
                        colorScheme.surface,
                        colorScheme.surface.withOpacity(0.8),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isToday 
                    ? colorScheme.primary.withOpacity(0.4)
                    : colorScheme.outline.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isToday 
                      ? colorScheme.primary.withOpacity(0.2)
                      : colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isToday 
                                    ? [colorScheme.primary, colorScheme.primary.withOpacity(0.8)]
                                    : [colorScheme.secondary, colorScheme.secondary.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: (isToday ? colorScheme.primary : colorScheme.secondary).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              isToday ? Icons.today_rounded : Icons.calendar_today_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isToday ? 'Today' : 'Daily Overview',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isToday 
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    if (isToday) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'LIVE',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('EEEE, MMM d').format(widget.selectedDate),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isToday 
                                        ? colorScheme.onPrimaryContainer.withOpacity(0.8)
                                        : colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.onTap != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            // Animated Pie Chart
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: AnimatedBuilder(
                                animation: _chartAnimation,
                                builder: (context, child) {
                                  return _activitiesLogged == 0
                                      ? Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                                            border: Border.all(
                                              color: colorScheme.outline.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.schedule_rounded,
                                            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                                            size: 40,
                                          ),
                                        )
                                      : PieChart(
                                          PieChartData(
                                            sectionsSpace: 4,
                                            centerSpaceRadius: 30,
                                            sections: [
                                              PieChartSectionData(
                                                color: colorScheme.primary,
                                                value: (_activitiesLogged * _chartAnimation.value).toDouble(),
                                                title: '',
                                                radius: 30,
                                              ),
                                              if (_emptyHours > 0)
                                                PieChartSectionData(
                                                  color: colorScheme.surfaceVariant,
                                                  value: (_emptyHours * _chartAnimation.value).toDouble(),
                                                  title: '',
                                                  radius: 30,
                                                ),
                                            ],
                                          ),
                                        );
                                },
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Enhanced Stats
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAnimatedStatRow(
                                    'Activities Logged',
                                    _activitiesLogged,
                                    24,
                                    colorScheme.primary,
                                    Icons.task_alt_rounded,
                                    theme,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAnimatedStatRow(
                                    'Empty Hours',
                                    _emptyHours,
                                    24,
                                    colorScheme.surfaceVariant,
                                    Icons.schedule_rounded,
                                    theme,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFunProgressIndicator(theme, colorScheme),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStatRow(String label, int value, int total, Color color, IconData icon, ThemeData theme) {
    final percentage = total > 0 ? (value / total * 100).round() : 0;
    
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        final animatedValue = (value * _chartAnimation.value).round();
        final animatedPercentage = (percentage * _chartAnimation.value).round();
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LinearProgressIndicator(
                      value: animatedPercentage / 100,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$animatedValue ($animatedPercentage%)',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFunProgressIndicator(ThemeData theme, ColorScheme colorScheme) {
    final percentage = _activitiesLogged / 24;
    String emoji;
    String message;
    Color bgColor;
    Color textColor;

    if (percentage >= 0.8) {
      emoji = '🔥';
      message = 'On fire! Amazing day!';
      bgColor = Colors.orange.withOpacity(0.2);
      textColor = Colors.orange.shade700;
    } else if (percentage >= 0.6) {
      emoji = '⭐';
      message = 'Great progress today!';
      bgColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    } else if (percentage >= 0.4) {
      emoji = '💪';
      message = 'Keep pushing forward!';
      bgColor = Colors.blue.withOpacity(0.2);
      textColor = Colors.blue.shade700;
    } else if (percentage >= 0.2) {
      emoji = '🌱';
      message = 'Small steps matter!';
      bgColor = Colors.green.withOpacity(0.2);
      textColor = Colors.green.shade700;
    } else {
      emoji = '🎯';
      message = 'Start your journey!';
      bgColor = colorScheme.tertiaryContainer;
      textColor = colorScheme.onTertiaryContainer;
    }
    
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage * _chartAnimation.value,
                        backgroundColor: textColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(textColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(percentage * _chartAnimation.value * 100).round()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}
