import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../models/portfolio_analysis_models.dart';

class DisciplineGaugeSection extends StatefulWidget {
  final DisciplineLevel level;

  const DisciplineGaugeSection({
    super.key,
    this.level = DisciplineLevel.moderate,
  });

  @override
  State<DisciplineGaugeSection> createState() => _DisciplineGaugeSectionState();
}

class _DisciplineGaugeSectionState extends State<DisciplineGaugeSection> with SingleTickerProviderStateMixin {
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
    int targetSegments = 1;
    if (widget.level.score >= 0.5 && widget.level.score < 0.8) targetSegments = 2;
    if (widget.level.score >= 0.8) targetSegments = 3;
    
    int hapticCount = 0;
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        int currentSegment = (_animation.value * targetSegments).ceil();
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
                    painter: _DisciplineGaugePainter(
                      progress: _animation.value,
                      score: widget.level.score,
                      activeColor: widget.level.color,
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
                      Icon(Icons.adjust, size: 16, color: Color(0xFF94A3B8)),
                      SizedBox(width: 6),
                      Text(
                        'Discipline',
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
                  _buildLabelText(),
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
                TextSpan(text: 'Small withdrawals and some active months, but '),
                TextSpan(
                  text: 'but the habit needs to show up more consistently to move the score higher.',
                  style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
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

  Widget _buildLabelText() {
    final baseStyle = const TextStyle(
      fontFamily: 'DMSans',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
    );

    if (widget.level.label == 'Moderate') {
      return ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color(0xFF90CDF4), // Replaced pure white so it doesn't vanish on white bg
            Color(0xFF5BA1F7),
            Color(0xFF031E6B),
            Color(0xFF241714),
          ],
          stops: [0.0, 0.25, 0.7, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Text(
          'Moderate',
          style: baseStyle.copyWith(color: Colors.white),
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          style: baseStyle,
          children: _getSplitLabel(widget.level.label, widget.level.color),
        ),
      );
    }
  }

  List<InlineSpan> _getSplitLabel(String label, Color color) {
    if (label == 'Moderate') {
      return [
        const TextSpan(text: 'Moder', style: TextStyle(color: Color(0xFF0F172A))),
        TextSpan(text: 'ate', style: TextStyle(color: color)),
      ];
    } else if (label == 'Needs Work') {
      return [
        const TextSpan(text: 'Needs ', style: TextStyle(color: Color(0xFF0F172A))),
        TextSpan(text: 'Work', style: TextStyle(color: color)),
      ];
    } else if (label == 'Excellent') {
      return [
        const TextSpan(text: 'Excel', style: TextStyle(color: Color(0xFF0F172A))),
        TextSpan(text: 'lent', style: TextStyle(color: color)),
      ];
    }
    return [TextSpan(text: label, style: TextStyle(color: color))];
  }
}

class _DisciplineGaugePainter extends CustomPainter {
  final double progress;
  final double score;
  final Color activeColor;

  _DisciplineGaugePainter({
    required this.progress,
    required this.score,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Outer dotted track
    final startAngle = math.pi;
    final sweepAngle = math.pi;
    
    final outerRect = Rect.fromCircle(center: center, radius: radius);
    final outerPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    _drawDashedArc(canvas, outerRect, startAngle, sweepAngle, outerPaint, dashWidth: 2, dashSpace: 6);

    // Inner arc segments
    final innerRadius = radius - 16;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    
    const numSegments = 3;
    final segmentSweep = sweepAngle / numSegments;
    
    // 1. Draw solid continuous background track
    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(innerRect, startAngle, sweepAngle, false, bgPaint);
    
    // Determine target segments based on score
    int targetSegments = 1;
    if (score >= 0.5 && score < 0.8) targetSegments = 2;
    if (score >= 0.8) targetSegments = 3;
    
    // Pick active colors based on the final activeColor
    List<Color> activeColors;
    if (activeColor.value == const Color(0xFF38A169).value || activeColor.value == const Color(0xFF16A34A).value) {
      activeColors = [const Color(0xFF86EFAC), const Color(0xFF4ADE80), const Color(0xFF22C55E)];
    } else if (activeColor.value == const Color(0xFFE53E3E).value || activeColor.value == const Color(0xFFDC2626).value || activeColor.value == const Color(0xFFF56565).value) {
      activeColors = [const Color(0xFFFCA5A5), const Color(0xFFF87171), const Color(0xFFEF4444)];
    } else {
      activeColors = [const Color(0xFF7DD3FC), const Color(0xFF38BDF8), const Color(0xFF0EA5E9)];
    }
    
    final targetAngle = targetSegments * segmentSweep;
    final currentAngle = targetAngle * progress;
    
    // 2. Draw from right to left so left segments' right caps sit on top
    for (int i = targetSegments - 1; i >= 0; i--) {
      final start = startAngle + (i * segmentSweep);
      if (currentAngle > i * segmentSweep) {
        final sweep = math.min(segmentSweep, currentAngle - (i * segmentSweep));
        final paint = Paint()
          ..color = activeColors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round; // All caps are round!
          
        canvas.drawArc(innerRect, start, sweep, false, paint);
      }
    }
  }

  void _drawDashedArc(Canvas canvas, Rect rect, double startAngle, double sweepAngle, Paint paint, {required double dashWidth, required double dashSpace}) {
    double radius = rect.width / 2;
    double circumference = 2 * math.pi * radius;
    double totalArcLength = (sweepAngle / (2 * math.pi)) * circumference;
    
    double currentLength = 0;
    while (currentLength < totalArcLength) {
      double dashAngle = (dashWidth / circumference) * 2 * math.pi;
      double spaceAngle = (dashSpace / circumference) * 2 * math.pi;
      
      double currentStartAngle = startAngle + (currentLength / totalArcLength) * sweepAngle;
      
      if (currentLength + dashWidth <= totalArcLength) {
        canvas.drawArc(rect, currentStartAngle, dashAngle, false, paint);
      }
      currentLength += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DisciplineGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.score != score || oldDelegate.activeColor != activeColor;
  }
}
