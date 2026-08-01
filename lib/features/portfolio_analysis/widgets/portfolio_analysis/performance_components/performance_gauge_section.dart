import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../models/portfolio_analysis_models.dart';

class PerformanceGaugeSection extends StatefulWidget {
  final PerformanceLevel level;

  const PerformanceGaugeSection({
    super.key,
    this.level = PerformanceLevel.veryStrong,
  });

  @override
  State<PerformanceGaugeSection> createState() => _PerformanceGaugeSectionState();
}

class _PerformanceGaugeSectionState extends State<PerformanceGaugeSection> with SingleTickerProviderStateMixin {
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
                    painter: _PerformanceGaugePainter(
                      progress: _animation.value,
                      level: widget.level,
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
                      Icon(Icons.change_history, size: 16, color: Color(0xFF94A3B8)),
                      SizedBox(width: 6),
                      Text(
                        'Performance',
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
                color: Color(0xFF94A3B8),
              ),
              children: [
                TextSpan(text: 'Your portfolio is earning '),
                TextSpan(
                  text: 'well above what most Very Aggressive investors see. ',
                  style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                ),
                TextSpan(text: 'Your investment decisions are clearly paying off.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        
        // Drivers Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'What drives your performance',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const _DottedDivider(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Your Lifetime MF XIRR ',
                            style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          Text(
                            '4.06% higher',
                            style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF38A169)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Container(
                                  height: 8,
                                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.7 * _animation.value,
                                      color: const Color(0xFF48BB78), // Green
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '9.48%',
                            style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const _DottedDivider(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Benchmark',
                        style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Container(
                                  height: 8,
                                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.4 * _animation.value,
                                      color: const Color(0xFFCBD5E1), // Grey
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '5.42%',
                            style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PerformanceGaugePainter extends CustomPainter {
  final double progress;
  final PerformanceLevel level;

  _PerformanceGaugePainter({
    required this.progress,
    required this.level,
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
    
    final numSegments = 5;
    final segmentSweep = sweepAngle / numSegments;

    // Gradient of greens from light to dark
    final activeColors = [
      const Color(0xFFBBE5B3),
      const Color(0xFF86EFAC),
      const Color(0xFF4ADE80),
      const Color(0xFF22C55E),
      const Color(0xFF16A34A),
    ];
    
    // 1. Draw solid continuous background track
    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(innerRect, startAngle, sweepAngle, false, bgPaint);

    // 2. Draw segmented colored progress smoothly from right to left for overlapping rounded caps
    final targetSegments = level.activeSegments;
    if (targetSegments > 0) {
      final targetAngle = targetSegments * segmentSweep;
      final currentAngle = targetAngle * progress;

      for (int i = targetSegments - 1; i >= 0; i--) {
        final start = startAngle + (i * segmentSweep);
        
        if (currentAngle > i * segmentSweep) {
          final sweep = math.min(segmentSweep, currentAngle - (i * segmentSweep));
          final paint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 20
            ..strokeCap = StrokeCap.round
            ..color = activeColors[i];

          canvas.drawArc(innerRect, start, sweep, false, paint);
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
  bool shouldRepaint(covariant _PerformanceGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.level != level;
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DottedLinePainter(),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    
    double dashWidth = 3;
    double dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
