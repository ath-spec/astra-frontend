import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../models/portfolio_analysis_models.dart';

class AllocationGaugeSection extends StatefulWidget {
  final AllocationLevel level;

  const AllocationGaugeSection({
    super.key,
    this.level = AllocationLevel.veryAggressive,
  });

  @override
  State<AllocationGaugeSection> createState() => _AllocationGaugeSectionState();
}

class _AllocationGaugeSectionState extends State<AllocationGaugeSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _lastHapticValue = 0;

  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    int hapticCount = 0;
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        int currentSegment = (_animation.value * widget.level.activeSegments).ceil();
        if (currentSegment > hapticCount) {
          HapticFeedback.selectionClick();
          hapticCount = currentSegment;
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only animate when the tab actually becomes active/visible
    if (TickerMode.of(context) && !_hasAnimated) {
      _hasAnimated = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          width: 300,
          height: 160,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(300, 150),
                    painter: _AllocationGaugePainter(
                      progress: _animation.value,
                      activeSegments: widget.level.activeSegments,
                      activeColor: widget.level.activeColor,
                    ),
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.view_in_ar_outlined, size: 16, color: Color(0xFF94A3B8)),
                      SizedBox(width: 6),
                      Text(
                        'Allocation',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.level.label,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: widget.level.activeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 8),
              Text(
                'KNOW MORE',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF64748B),
              ),
              children: [
                TextSpan(text: 'You have almost no stable, low-risk assets in your portfolio. '),
                TextSpan(
                  text: 'You\'re fully riding market momentum, with all your wealth geared towards growth.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _AllocationGaugePainter extends CustomPainter {
  final double progress;
  final int activeSegments;
  final Color activeColor;

  _AllocationGaugePainter({
    required this.progress,
    required this.activeSegments,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // 1. Draw outer dotted line
    final outerRect = Rect.fromCircle(center: center, radius: radius);
    final outerPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    _drawDashedArc(canvas, outerRect, startAngle, sweepAngle, outerPaint, dashWidth: 2, dashSpace: 8);

    // 2. Draw segments
    final innerRadius = radius - 16;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    
    const numSegments = 5;
    final gapAngle = 0.05; // Gap between segments
    final segmentSweep = (sweepAngle - (gapAngle * (numSegments - 1))) / numSegments;

    // 1. Draw Background Tracks
    for (int i = 0; i < numSegments; i++) {
      final segmentStart = startAngle + (i * (segmentSweep + gapAngle));
      final bgPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(innerRect, segmentStart, segmentSweep, false, bgPaint);
    }

    // 2. Draw segmented colored progress smoothly
    if (activeSegments > 0) {
      final targetAngle = (activeSegments * segmentSweep) + ((activeSegments - 1) * gapAngle);
      final currentAngle = targetAngle * progress;

      for (int i = 0; i < activeSegments; i++) {
        final segmentStart = startAngle + (i * (segmentSweep + gapAngle));
        final segmentStartAngle = i * (segmentSweep + gapAngle);
        
        if (currentAngle > segmentStartAngle) {
          final sweep = math.min(segmentSweep, currentAngle - segmentStartAngle);
          final paint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 20
            ..strokeCap = StrokeCap.butt;
            
          if (i == activeSegments - 1 && activeSegments == 5) {
            // If it's the last segment of Very Aggressive, give it a sweep gradient
            final gradient = SweepGradient(
              colors: [const Color(0xFF9F7AEA), activeColor],
              stops: const [0.0, 1.0],
              startAngle: segmentStart,
              endAngle: segmentStart + segmentSweep,
            );
            paint.shader = gradient.createShader(innerRect);
          } else {
            paint.color = activeColor.withOpacity(0.4 + (0.6 * (i + 1) / activeSegments));
          }

          canvas.drawArc(innerRect, segmentStart, sweep, false, paint);
        }
      }
    }
  }

  void _drawDashedArc(Canvas canvas, Rect rect, double startAngle, double sweepAngle, Paint paint, {required double dashWidth, required double dashSpace}) {
    final circumference = rect.width * math.pi;
    final arcLength = (sweepAngle / (math.pi * 2)) * circumference;
    final dashCount = (arcLength / (dashWidth + dashSpace)).floor();
    final anglePerDash = sweepAngle / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final currentStart = startAngle + (i * anglePerDash);
      final currentSweep = anglePerDash * (dashWidth / (dashWidth + dashSpace));
      canvas.drawArc(rect, currentStart, currentSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AllocationGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.activeSegments != activeSegments || oldDelegate.activeColor != activeColor;
  }
}
