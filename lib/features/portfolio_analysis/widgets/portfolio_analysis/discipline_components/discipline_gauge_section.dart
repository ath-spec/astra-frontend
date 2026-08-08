import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../models/portfolio_analysis_models.dart';
import 'discipline_info_sheet.dart';
import '../../../../../core/widgets/typewriter_text.dart';

class DisciplineGaugeSection extends StatefulWidget {
  final DisciplineLevel level;

  const DisciplineGaugeSection({
    super.key,
    this.level = DisciplineLevel.moderate,
  });

  @override
  State<DisciplineGaugeSection> createState() => _DisciplineGaugeSectionState();
}

class _DisciplineGaugeSectionState extends State<DisciplineGaugeSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final double _lastHapticValue = 0;

  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    int targetSegments = 1;
    if (widget.level.score >= 0.5 && widget.level.score < 0.8) {
      targetSegments = 2;
    }
    if (widget.level.score >= 0.8) targetSegments = 3;

    int hapticCount = 0;

    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
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
    return LayoutBuilder(builder: (context, constraints) {
      final gaugeWidth = constraints.maxWidth * 0.8;
      final gaugeHeight = gaugeWidth * 0.5;
      return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          width: gaugeWidth,
          height: gaugeHeight + 10,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(gaugeWidth, gaugeHeight),
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
                      Icon(Icons.adjust, size: 12, color: Color(0xFF94A3B8)),
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
        GestureDetector(
          onTap: () {
            // Map the 4-tier DisciplineLevel to the 5-tier info sheet UI
            int index = 2; // Default to Fair
            if (widget.level == DisciplineLevel.poor) index = 1; // Low
            if (widget.level == DisciplineLevel.moderate) index = 2; // Fair
            if (widget.level == DisciplineLevel.good) index = 3; // Good
            if (widget.level == DisciplineLevel.excellent) {
              index = 4; // Excellent
            }

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) =>
                  DisciplineInfoSheet(currentLevelIndex: index),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.info_outline, size: 10, color: Color(0xFF64748B)),
                SizedBox(width: 8),
                Text(
                  'KNOW MORE',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: widget.level.gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.0, right: 6.0),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: TypewriterText(
                    text: 'Small withdrawals and some active months, but the habit needs to show up more consistently to move the score higher.',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    });
  }

  Widget _buildLabelText() {
    final baseStyle = const TextStyle(
      fontFamily: 'DMSans',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
    );

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFF5BA1F7),
          Color(0xFF031E6B),
          Color(0xFF241714),
        ],
        stops: [0.0, 0.25, 0.7, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        widget.level.label,
        style: baseStyle.copyWith(color: Colors.white),
      ),
    );
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

    _drawDashedArc(
      canvas,
      outerRect,
      startAngle,
      sweepAngle,
      outerPaint,
      dashWidth: 2,
      dashSpace: 6,
    );

    // Inner arc segments
    final innerRadius = radius - 16;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    const numSegments = 5;
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
    if (score > 0.3) targetSegments = 2;
    if (score >= 0.7) targetSegments = 3; // Moderate is 3rd
    if (score >= 0.85) targetSegments = 4; // Good is 4th
    if (score >= 1.0) targetSegments = 5; // Excellent is 5th

    // Static multi-color track using different shades of blue for different values
    final activeColors = [
      const Color(0xFFBCE3FF), // 1. Very Low (Lightest Blue)
      const Color(0xFF65B4FF), // 2. Low (Light Blue)
      const Color(0xFF2796FF), // 3. Fair / Moderate (Blue)
      const Color(0xFF0278D9), // 4. Good (Dark Blue)
      const Color(0xFF015294), // 5. Excellent (Darkest Blue)
    ];

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

  void _drawDashedArc(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double sweepAngle,
    Paint paint, {
    required double dashWidth,
    required double dashSpace,
  }) {
    double radius = rect.width / 2;
    double circumference = 2 * math.pi * radius;
    double totalArcLength = (sweepAngle / (2 * math.pi)) * circumference;

    double currentLength = 0;
    while (currentLength < totalArcLength) {
      double dashAngle = (dashWidth / circumference) * 2 * math.pi;
      double spaceAngle = (dashSpace / circumference) * 2 * math.pi;

      double currentStartAngle =
          startAngle + (currentLength / totalArcLength) * sweepAngle;

      if (currentLength + dashWidth <= totalArcLength) {
        canvas.drawArc(rect, currentStartAngle, dashAngle, false, paint);
      }
      currentLength += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DisciplineGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.score != score ||
        oldDelegate.activeColor != activeColor;
  }
}
