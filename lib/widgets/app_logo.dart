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
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: widget.size,
      height: widget.size,
      child: widget.animated
          ? AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: _buildClockFace(colorScheme),
                );
              },
            )
          : _buildClockFace(colorScheme),
    );
  }

  Widget _buildClockFace(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Clock face background
          Container(
            margin: EdgeInsets.all(widget.size * 0.1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surface,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          // Hour markers
          ...List.generate(12, (index) => _buildHourMarker(index, colorScheme)),
          // Clock hands
          _buildClockHands(colorScheme),
          // Center dot
          Center(
            child: Container(
              width: widget.size * 0.08,
              height: widget.size * 0.08,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourMarker(int hour, ColorScheme colorScheme) {
    final angle = (hour * 30 - 90) * math.pi / 180;
    final radius = widget.size * 0.35;
    final markerSize = hour % 3 == 0 ? widget.size * 0.03 : widget.size * 0.02;
    
    return Positioned(
      left: widget.size / 2 + radius * math.cos(angle) - markerSize / 2,
      top: widget.size / 2 + radius * math.sin(angle) - markerSize / 2,
      child: Container(
        width: markerSize,
        height: markerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hour % 3 == 0 
              ? colorScheme.primary 
              : colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildClockHands(ColorScheme colorScheme) {
    final now = DateTime.now();
    final hourAngle = ((now.hour % 12) * 30 + now.minute * 0.5 - 90) * math.pi / 180;
    final minuteAngle = (now.minute * 6 - 90) * math.pi / 180;
    
    return Stack(
      children: [
        // Hour hand
        _buildHand(
          angle: hourAngle,
          length: widget.size * 0.25,
          width: widget.size * 0.025,
          color: colorScheme.primary,
        ),
        // Minute hand
        _buildHand(
          angle: minuteAngle,
          length: widget.size * 0.35,
          width: widget.size * 0.015,
          color: colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildHand({
    required double angle,
    required double length,
    required double width,
    required Color color,
  }) {
    return Positioned(
      left: widget.size / 2 - width / 2,
      top: widget.size / 2 - width / 2,
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: width,
          height: length,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(width / 2),
          ),
        ),
      ),
    );
  }
}
