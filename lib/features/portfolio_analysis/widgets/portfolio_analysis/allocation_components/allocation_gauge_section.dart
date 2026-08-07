import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart';
import '../../../../../core/widgets/typewriter_text.dart';
import 'dart:math' as math;
import '../../../models/portfolio_analysis_models.dart';
import 'allocation_info_sheet.dart';

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
        if (_animation.value > 0.3 && hapticCount == 0) {
          HapticFeedback.selectionClick();
          hapticCount = 1;
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
    return LayoutBuilder(
      builder: (context, constraints) {
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
                      Icon(Icons.view_in_ar_outlined, size: 12, color: Color(0xFF94A3B8)),
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
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: widget.level.gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      widget.level.label,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => AllocationInfoSheet(level: widget.level),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.info_outline, size: 12, color: Color(0xFF64748B)),
                SizedBox(width: 6),
                Text(
                  'KNOW MORE',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
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
                    text: 'You have almost no stable, low-risk assets in your portfolio. You\'re fully riding market momentum, with all your wealth geared towards growth.',
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
        const SizedBox(height: 40),
      ],
    );
    });
  }
}

class _AllocationGaugePainter extends CustomPainter {
  final double progress;
  final int activeSegments; // 1 to 5
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

    // 1. Draw outer dotted line (sparse)
    final outerRect = Rect.fromCircle(center: center, radius: radius);
    final outerPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    _drawDashedArc(canvas, outerRect, startAngle, sweepAngle, outerPaint, dashWidth: 1.5, dashSpace: 12);

    // 2. Draw segments
    final innerRadius = radius - 16;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    
    const numSegments = 5;
    final activeIndex = activeSegments - 1; // 0 to 4
    final segmentSweep = sweepAngle / numSegments;

    // Background Arc (Gray, round ends)
    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(innerRect, startAngle, sweepAngle, false, bgPaint);

    // Draw active segment (Fades in)
    final activeStart = startAngle + (activeIndex * segmentSweep);
    
    final activePaint = Paint()
      ..color = activeColor.withOpacity(progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.butt; // Flat edges by default
      
    canvas.drawArc(innerRect, activeStart, segmentSweep, false, activePaint);
    
    // Add round caps manually if it's the first or last segment
    if (progress > 0) {
      if (activeIndex == 0) {
        // Left cap is round
        final dx = math.cos(activeStart);
        final dy = math.sin(activeStart);
        canvas.drawCircle(center + Offset(dx * innerRadius, dy * innerRadius), 8, Paint()..color = activeColor.withOpacity(progress));
      }
      if (activeIndex == numSegments - 1) {
        // Right cap is round
        final endAngle = activeStart + segmentSweep;
        final dx = math.cos(endAngle);
        final dy = math.sin(endAngle);
        canvas.drawCircle(center + Offset(dx * innerRadius, dy * innerRadius), 8, Paint()..color = activeColor.withOpacity(progress));
      }
    }

    // Draw white gaps to cut the arc perfectly
    final gapPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.butt;
      
    for (int i = 1; i < numSegments; i++) {
      final angle = startAngle + (i * segmentSweep);
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      
      final p1 = center + Offset(dx * (innerRadius - 10), dy * (innerRadius - 10));
      final p2 = center + Offset(dx * (innerRadius + 10), dy * (innerRadius + 10));
      
      canvas.drawLine(p1, p2, gapPaint);
    }
    
    // Draw the glowing pie slice
    if (progress > 0) {
      final glowPath = Path();
      glowPath.moveTo(center.dx, center.dy);
      glowPath.arcTo(
        innerRect,
        activeStart,
        segmentSweep,
        false,
      );
      glowPath.close();

      final midAngle = activeStart + (segmentSweep / 2);
      final glowCenter = center + Offset(math.cos(midAngle) * innerRadius, math.sin(midAngle) * innerRadius);

      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            activeColor.withOpacity(0.3 * progress),
            activeColor.withOpacity(0.0),
          ],
          stops: const [0.0, 0.7],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: innerRadius * 0.9));

      canvas.drawPath(glowPath, glowPaint);
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
