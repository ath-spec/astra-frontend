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
  int _lastHapticIndex = -1;

  @override
  void initState() {
    super.initState();
    
    final numSegments = widget.type == ResultType.discipline ? 3 : 5;
    
    _animationController = AnimationController(
      vsync: this,
      // Total duration for a full 100% sweep = 250ms per segment.
      // animateTo(fillPercentage) will automatically scale this down proportionally.
      duration: Duration(milliseconds: numSegments * 250),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear, // Constant velocity so segments don't speed up or slow down
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.animateTo(widget.fillPercentage);
      }
    });

    _animation.addListener(() {
      final numSegments = widget.type == ResultType.discipline ? 3 : 5;
      
      // Calculate current index using the exact same math as the painters
      int currentIndex;
      if (widget.type == ResultType.allocation) {
        currentIndex = (_animation.value * numSegments).ceil() - 1;
      } else {
        currentIndex = (_animation.value * numSegments).floor();
      }
      
      // Clamp to bounds to prevent any possible floating point precision extra buzz
      currentIndex = math.min(currentIndex, numSegments - 1);
      
      // Fire a haptic tick exactly when a new segment lights up or fills
      if (currentIndex > _lastHapticIndex && currentIndex >= 0) {
        _lastHapticIndex = currentIndex;
        HapticFeedback.lightImpact();
      }
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.selectionClick();
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.gaugeColor.withOpacity(0.15),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5], // Fades to transparent halfway down the screen
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 120), // Increased from 40 to clear the overlaid Top Bar and status bar
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
                      type: widget.type,
                      color: widget.gaugeColor,
                    ),
                  ),
                  // Text perfectly centered inside the gauge
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _title,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80.0), // Increased from 24 to strictly fit inside the gauge stroke
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.mode,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: widget.gaugeColor,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                  fontFamily: 'DMSans',
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
    ));
  }
}

class _LargeGaugePainter extends CustomPainter {
  final double progress;
  final ResultType type;
  final Color color;

  _LargeGaugePainter({required this.progress, required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final strokeW = 32.0; 
    
    if (type == ResultType.discipline) {
      _paintDiscipline(canvas, rect, strokeW);
    } else if (type == ResultType.allocation) {
      _paintAllocation(canvas, rect, strokeW);
    } else if (type == ResultType.performance) {
      _paintPerformance(canvas, rect, strokeW);
    }
  }

  void _paintDiscipline(Canvas canvas, Rect rect, double strokeW) {
    // Background track
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);

    final activeColors = [const Color(0xFF7DD3FC), const Color(0xFF38BDF8), const Color(0xFF0EA5E9)];
    const numSegments = 3;
    final segmentSweep = math.pi / numSegments;
    final currentAngle = math.pi * progress;
    
    // Draw from right to left (index 2 down to 0) so the left segments' right caps sit on top
    // of the right segments, perfectly matching the overlapping rounded caps in the design.
    for (int i = numSegments - 1; i >= 0; i--) {
      final start = math.pi + (i * segmentSweep);
      if (currentAngle > i * segmentSweep) {
        final sweep = math.min(segmentSweep, currentAngle - (i * segmentSweep));
        final paint = Paint()
          ..color = activeColors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round; // All caps are round!
          
        canvas.drawArc(rect, start, sweep, false, paint);
      }
    }
  }

  void _paintAllocation(Canvas canvas, Rect rect, double strokeW) {
    const numSegments = 5;
    const gapAngle = 0.03;
    final segmentSweep = (math.pi - (gapAngle * (numSegments - 1))) / numSegments;
    
    // Draw 5 grey segments
    for (int i = 0; i < numSegments; i++) {
      final start = math.pi + (i * (segmentSweep + gapAngle));
      final bgPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.butt;
      
      canvas.drawArc(rect, start, segmentSweep, false, bgPaint);
      if (i == 0) canvas.drawArc(rect, start, 0.01, false, bgPaint..strokeCap = StrokeCap.round);
      if (i == numSegments - 1) canvas.drawArc(rect, start + segmentSweep - 0.01, 0.01, false, bgPaint..strokeCap = StrokeCap.round);
    }
    
    if (progress > 0) {
      // Discretely jump from segment to segment
      final activeIndex = (progress * numSegments).ceil() - 1;
      
      if (activeIndex >= 0) {
        final start = math.pi + (activeIndex * (segmentSweep + gapAngle));
        
        // No track overlay glow; glow is handled by the screen's radial gradient background
        
        // 3. Draw FULL active segment as a solid color (no gradient)
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.butt;
          
        canvas.drawArc(rect, start, segmentSweep, false, paint);
        if (activeIndex == numSegments - 1) {
            canvas.drawArc(rect, start + segmentSweep - 0.01, 0.01, false, paint..strokeCap = StrokeCap.round);
        }
      }
    }
  }

  void _paintPerformance(Canvas canvas, Rect rect, double strokeW) {
    const numSegments = 5;
    final segmentSweep = math.pi / numSegments;
    final colors = [
      const Color(0xFFBBE5B3),
      const Color(0xFF86EFAC),
      const Color(0xFF4ADE80),
      const Color(0xFF22C55E),
      const Color(0xFF16A34A),
    ];
    
    // Background track
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);
    
    final currentAngle = math.pi * progress;
    
    // Draw from right to left so left segments' right caps sit on top
    for (int i = numSegments - 1; i >= 0; i--) {
      final start = math.pi + (i * segmentSweep);
      if (currentAngle > i * segmentSweep) {
        final sweep = math.min(segmentSweep, currentAngle - (i * segmentSweep));
        final paint = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round; // All caps are round!
          
        canvas.drawArc(rect, start, sweep, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LargeGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.type != type;
  }
}
