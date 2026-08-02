import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../portfolio_analysis/models/portfolio_analysis_models.dart';

final ValueNotifier<bool> hasSeenAnalysisWalkthrough = ValueNotifier<bool>(false);

class HomePortfolioAnalysis extends StatelessWidget {
  const HomePortfolioAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hasSeenAnalysisWalkthrough,
      builder: (context, hasSeen, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analyse your wealth',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'See your portfolio through a new lens',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            hasSeen
                ? _buildUnlockedView(context)
                : _buildLockedView(context),
          ],
        );
      }
    );
  }

  Widget _buildUnlockedView(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalysisCard(
            context: context,
            title: 'Discipline',
            tabIndex: 0,
            icon: Icons.track_changes,
            valueText: DisciplineLevel.moderate.label,
            valueColor: DisciplineLevel.moderate.color,
            gradientColors: DisciplineLevel.moderate.gradientColors,
            bottomText: 'VIEW >',
            painter: _MiniDisciplinePainter(level: DisciplineLevel.moderate),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildAnalysisCard(
            context: context,
            title: 'Allocation',
            tabIndex: 1,
            icon: Icons.view_in_ar_outlined,
            valueText: AllocationLevel.veryAggressive.label,
            valueColor: AllocationLevel.veryAggressive.activeColor,
            gradientColors: AllocationLevel.veryAggressive.gradientColors,
            bottomText: '• 2 INSIGHTS >',
            bottomBgColor: const Color(0xFFFEF3C7),
            bottomTextColor: const Color(0xFF92400E),
            painter: _MiniAllocationPainter(
              level: AllocationLevel.veryAggressive,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildAnalysisCard(
            context: context,
            title: 'Performance',
            tabIndex: 2,
            icon: Icons.change_history,
            valueText: PerformanceLevel.veryStrong.label,
            valueColor: PerformanceLevel.veryStrong.activeColor,
            gradientColors: PerformanceLevel.veryStrong.gradientColors,
            bottomText: 'VIEW >',
            painter: _MiniPerformancePainter(
              level: PerformanceLevel.veryStrong,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedView(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            children: [
              Expanded(
                child: _buildLockedCard(
                  title: 'Discipline',
                  icon: Icons.track_changes,
                  color: const Color(0xFF4299E1), // Blue
                  brailleDots: '⠓⠕⠗⠍',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLockedCard(
                  title: 'Allocation',
                  icon: Icons.layers_outlined,
                  color: const Color(0xFF9F7AEA), // Purple
                  brailleDots: '⠓⠕⠗⠍',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLockedCard(
                  title: 'Performance',
                  icon: Icons.change_history,
                  color: const Color(0xFF48BB78), // Green
                  brailleDots: '⠓⠕⠗⠍',
                ),
              ),
            ],
          ),
        ),

        // "REVEAL ANALYSIS" glowing pill
        Positioned(
          bottom: 10,
          child: GestureDetector(
            onTap: () {
              context.push('/analysis-walkthrough');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF27272A), Color(0xFF09090B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF48BB78,
                    ).withOpacity(0.3), // Glow effect
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: const Text(
                'REVEAL ANALYSIS',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedCard({
    required String title,
    required IconData icon,
    required Color color,
    required String brailleDots,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 32, bottom: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Semi-circle gauge
          SizedBox(
            width: 70,
            height: 40,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CustomPaint(
                  size: const Size(70, 40),
                  painter: _LockedSemiCircleGaugePainter(color: color),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(icon, size: 16, color: const Color(0xFF475569)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            brailleDots,
            style: TextStyle(fontSize: 20, color: color, letterSpacing: 2.0),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard({
    required BuildContext context,
    required String title,
    required int tabIndex,
    required IconData icon,
    required String valueText,
    required Color valueColor,
    List<Color>? gradientColors,
    required String bottomText,
    Color? bottomBgColor,
    Color? bottomTextColor,
    required CustomPainter painter,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/portfolio-analysis?tab=$tabIndex');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Column(
                children: [
                  SizedBox(
                    width: 60,
                    height: 35,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        CustomPaint(size: const Size(60, 35), painter: painter),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Icon(
                            icon,
                            size: 14,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  gradientColors != null
                      ? ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: Text(
                            valueText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          valueText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: valueColor,
                          ),
                        ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: bottomBgColor ?? const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Text(
                bottomText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: bottomTextColor ?? const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedSemiCircleGaugePainter extends CustomPainter {
  final Color color;

  _LockedSemiCircleGaugePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    // Background track (light grey)
    final trackPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
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
      colors: [color.withOpacity(0.3), color],
      stops: const [0.0, 1.0],
      startAngle: math.pi,
      endAngle: math.pi * 2,
    );

    final foregroundPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi * 0.7, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniDisciplinePainter extends CustomPainter {
  final DisciplineLevel level;
  _MiniDisciplinePainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // Outer track
    final outerPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final outerRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(outerRect, math.pi, math.pi, false, outerPaint);

    // Inner track
    final innerPaint = Paint()
      ..color = level.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final innerRect = Rect.fromCircle(center: center, radius: radius - 6);
    canvas.drawArc(
      innerRect,
      math.pi,
      math.pi * level.score,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MiniAllocationPainter extends CustomPainter {
  final AllocationLevel level;
  _MiniAllocationPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final innerRect = Rect.fromCircle(center: center, radius: radius - 3);

    const numSegments = 5;
    final gapAngle = 0.1;
    final sweepAngle = math.pi;
    final segmentSweep =
        (sweepAngle - (gapAngle * (numSegments - 1))) / numSegments;

    for (int i = 0; i < numSegments; i++) {
      final segmentStart = math.pi + (i * (segmentSweep + gapAngle));
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.butt;

      if (i < level.activeSegments) {
        paint.color = level.activeColor;
      } else {
        paint.color = const Color(0xFFE2E8F0);
      }

      canvas.drawArc(innerRect, segmentStart, segmentSweep, false, paint);

      // Caps
      if (i == 0)
        canvas.drawArc(
          innerRect,
          segmentStart,
          0.01,
          false,
          paint..strokeCap = StrokeCap.round,
        );
      if (i == 4)
        canvas.drawArc(
          innerRect,
          segmentStart + segmentSweep - 0.01,
          0.01,
          false,
          paint..strokeCap = StrokeCap.round,
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MiniPerformancePainter extends CustomPainter {
  final PerformanceLevel level;
  _MiniPerformancePainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final innerRect = Rect.fromCircle(center: center, radius: radius - 3);

    const numSegments = 5;
    final gapAngle = 0.1;
    final sweepAngle = math.pi;
    final segmentSweep =
        (sweepAngle - (gapAngle * (numSegments - 1))) / numSegments;

    final activeColors = [
      const Color(0xFFBBE5B3),
      const Color(0xFF86EFAC),
      const Color(0xFF4ADE80),
      const Color(0xFF22C55E),
      const Color(0xFF16A34A),
    ];

    for (int i = 0; i < numSegments; i++) {
      final segmentStart = math.pi + (i * (segmentSweep + gapAngle));
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.butt;

      if (i < level.activeSegments) {
        if (level == PerformanceLevel.veryStrong) {
          paint.color = activeColors[i]; // Use gradient for very strong
        } else {
          paint.color = level.activeColor.withOpacity(
            (i + 1) / level.activeSegments,
          );
        }
      } else {
        paint.color = const Color(0xFFE2E8F0);
      }

      canvas.drawArc(innerRect, segmentStart, segmentSweep, false, paint);

      // Caps
      if (i == 0)
        canvas.drawArc(
          innerRect,
          segmentStart,
          0.01,
          false,
          paint..strokeCap = StrokeCap.round,
        );
      if (i == 4)
        canvas.drawArc(
          innerRect,
          segmentStart + segmentSweep - 0.01,
          0.01,
          false,
          paint..strokeCap = StrokeCap.round,
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
