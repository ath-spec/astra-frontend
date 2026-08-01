import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

enum ResultType { discipline, allocation, performance }

class AnalysisResultView extends StatefulWidget {
  final ResultType type;
  final String mode;
  final String scoreText;
  final String description;
  final Color gaugeColor;
  final double fillPercentage;
  final VoidCallback onNext;

  const AnalysisResultView({
    super.key,
    required this.type,
    required this.mode,
    required this.scoreText,
    required this.description,
    required this.gaugeColor,
    required this.fillPercentage,
    required this.onNext,
  });

  @override
  State<AnalysisResultView> createState() => _AnalysisResultViewState();
}

class _AnalysisResultViewState extends State<AnalysisResultView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _lastHapticValue = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: widget.fillPercentage).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _animation.addListener(() {
      // Fire a haptic tick every 10% of fill progress
      if (_animation.value - _lastHapticValue >= 0.1) {
        _lastHapticValue = _animation.value;
        HapticFeedback.selectionClick();
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case ResultType.discipline:
        return 'Discipline';
      case ResultType.allocation:
        return 'Allocation';
      case ResultType.performance:
        return 'Performance';
    }
  }

  String get _buttonText {
    if (widget.type == ResultType.performance) {
      return 'Explore Analysis \u2192';
    }
    return 'Next \u2192';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Animated Gauge Section
        SizedBox(
          height: 240,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CustomPaint(
                    size: const Size(280, 140),
                    painter: _LargeGaugePainter(
                      progress: _animation.value,
                      color: widget.gaugeColor,
                    ),
                  ),
                  // Text inside/below the gauge
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _title,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.mode,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: widget.gaugeColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Text Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Text(
                widget.scoreText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Gradient CTA Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onNext();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFF5BA1F7),
                    Color(0xFF031E6B),
                    Color(0xFF241714),
                  ],
                  stops: [0.0, 0.25, 0.7, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _buttonText,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LargeGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _LargeGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // We want the bounding box to be twice the height, so the arc forms a perfect semi-circle.
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    
    // Background track (light grey)
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round;

    // Draw background arc
    canvas.drawArc(
      rect,
      math.pi, // start from 180 degrees (left)
      math.pi, // sweep 180 degrees (to right)
      false,
      trackPaint,
    );

    // Foreground track (colored)
    final gradient = SweepGradient(
      colors: [color.withOpacity(0.4), color],
      stops: const [0.0, 1.0],
      startAngle: math.pi,
      endAngle: math.pi * 2,
    );

    final foregroundPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round;

    // Sweep is based on progress (0.0 to 1.0 -> 0 to 180 degrees)
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * progress, 
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LargeGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
