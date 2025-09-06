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
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _rotationController = AnimationController(
        duration: const Duration(seconds: 60),
        vsync: this,
      );
      _rotationAnimation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(_rotationController);
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _rotationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Widget clockWidget = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
            colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(widget.size * 0.2),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: widget.size * 0.2,
            offset: Offset(0, widget.size * 0.1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Clock face
          Center(
            child: Container(
              width: widget.size * 0.85,
              height: widget.size * 0.85,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Hour markers
                  ...List.generate(12, (index) {
                    final angle = (index * 30) * (3.14159 / 180);
                    final isMainHour = index % 3 == 0;
                    return Positioned(
                      left: widget.size * 0.425 + (widget.size * 0.32) * math.cos(angle - 3.14159 / 2) - (isMainHour ? 2 : 1),
                      top: widget.size * 0.425 + (widget.size * 0.32) * math.sin(angle - 3.14159 / 2) - (isMainHour ? 2 : 1),
                      child: Container(
                        width: isMainHour ? 4 : 2,
                        height: isMainHour ? 4 : 2,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withOpacity(isMainHour ? 0.8 : 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                  
                  // Hour hand
                  Center(
                    child: Transform.rotate(
                      angle: (9 * 30) * (3.14159 / 180), // 9 o'clock position
                      child: Container(
                        width: 2,
                        height: widget.size * 0.25,
                        margin: EdgeInsets.only(bottom: widget.size * 0.25),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                  
                  // Minute hand
                  Center(
                    child: Transform.rotate(
                      angle: (0 * 6) * (3.14159 / 180), // 12 o'clock position
                      child: Container(
                        width: 1.5,
                        height: widget.size * 0.35,
                        margin: EdgeInsets.only(bottom: widget.size * 0.35),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(0.75),
                        ),
                      ),
                    ),
                  ),
                  
                  // Center dot
                  Center(
                    child: Container(
                      width: widget.size * 0.08,
                      height: widget.size * 0.08,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Activity indicator
          Positioned(
            right: widget.size * 0.05,
            top: widget.size * 0.05,
            child: Container(
              width: widget.size * 0.15,
              height: widget.size * 0.15,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: widget.size * 0.08,
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.animated) {
      return AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: clockWidget,
          );
        },
      );
    }

    return clockWidget;
  }
}
