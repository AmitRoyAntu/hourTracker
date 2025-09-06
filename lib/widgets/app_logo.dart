import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppLogo extends StatefulWidget {
  final double size;
  final bool animated;

  const AppLogo({
    Key? key,
    this.size = 60,
    this.animated = true,
  }) : super(key: key);

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60), // One full rotation per minute
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    if (widget.animated) {
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: widget.animated
          ? AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ClockLogoPainter(
                    rotation: _rotationAnimation.value,
                    isDark: isDark,
                  ),
                );
              },
            )
          : CustomPaint(
              painter: ClockLogoPainter(
                rotation: 0,
                isDark: isDark,
              ),
            ),
    );
  }
}

class ClockLogoPainter extends CustomPainter {
  final double rotation;
  final bool isDark;

  ClockLogoPainter({
    required this.rotation,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background gradient
    final gradientColors = isDark 
        ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
        : [const Color(0xFF667eea), const Color(0xFF764ba2)];
    
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Draw background circle
    canvas.drawCircle(center, radius * 0.9, backgroundPaint);

    // Draw clock face
    final facePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.8, facePaint);

    // Draw hour markers
    final markerPaint = Paint()
      ..color = const Color(0xFF667eea)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final startX = center.dx + (radius * 0.7) * math.cos(angle - math.pi / 2);
      final startY = center.dy + (radius * 0.7) * math.sin(angle - math.pi / 2);
      final endX = center.dx + (radius * 0.6) * math.cos(angle - math.pi / 2);
      final endY = center.dy + (radius * 0.6) * math.sin(angle - math.pi / 2);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        markerPaint,
      );
    }

    // Draw hour hand (current hour)
    final now = DateTime.now();
    final hourAngle = ((now.hour % 12) * 30 + now.minute * 0.5) * math.pi / 180;
    final hourHandPaint = Paint()
      ..color = const Color(0xFF667eea)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final hourHandX = center.dx + (radius * 0.4) * math.cos(hourAngle - math.pi / 2);
    final hourHandY = center.dy + (radius * 0.4) * math.sin(hourAngle - math.pi / 2);
    
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandPaint);

    // Draw minute hand (with rotation animation)
    final minuteAngle = rotation;
    final minuteHandPaint = Paint()
      ..color = const Color(0xFF764ba2)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final minuteHandX = center.dx + (radius * 0.6) * math.cos(minuteAngle - math.pi / 2);
    final minuteHandY = center.dy + (radius * 0.6) * math.sin(minuteAngle - math.pi / 2);
    
    canvas.drawLine(center, Offset(minuteHandX, minuteHandY), minuteHandPaint);

    // Draw center dot
    final centerPaint = Paint()
      ..color = const Color(0xFF667eea)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.05, centerPaint);

    // Draw activity indicator dots around the edge
    final activityPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * math.pi / 180;
      final dotX = center.dx + (radius * 0.95) * math.cos(angle - math.pi / 2);
      final dotY = center.dy + (radius * 0.95) * math.sin(angle - math.pi / 2);
      
      // Simulate some activity data
      if (i % 3 == 0) {
        canvas.drawCircle(Offset(dotX, dotY), 2, activityPaint);
      }
    }
  }

  @override
  bool shouldRepaint(ClockLogoPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.isDark != isDark;
  }
}
