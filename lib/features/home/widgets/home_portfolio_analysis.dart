import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../portfolio_analysis/models/portfolio_analysis_models.dart';

final ValueNotifier<bool> hasSeenAnalysisWalkthrough = ValueNotifier<bool>(
  false,
);

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
                fontFamily: 'DMSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.0,
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
            hasSeen ? _buildUnlockedView(context) : _buildLockedView(context),
          ],
        );
      },
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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    color: const Color(0xFF6B46C1), // Matches AllocationLevel.veryAggressive.activeColor
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
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
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
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
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
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const startAngle = math.pi;
    const sweepAngle = math.pi;
    const numSegments = 5;
    const segmentSweep = sweepAngle / numSegments;

    final innerRadius = radius - 5;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // Grey background arc
    canvas.drawArc(innerRect, startAngle, sweepAngle, false,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);

    // Show 3 filled segments (preview state) as a solid color
    canvas.drawArc(innerRect, startAngle, segmentSweep * 3, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Exact miniature of _DisciplineGaugePainter:
// grey bg + multi-shade blue segments drawn right-to-left with overlapping round caps
class _MiniDisciplinePainter extends CustomPainter {
  final DisciplineLevel level;
  _MiniDisciplinePainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const startAngle = math.pi;
    const sweepAngle = math.pi;
    const numSegments = 5;
    const segmentSweep = sweepAngle / numSegments;

    final innerRadius = radius - 5;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // Grey background arc (round caps like the real gauge)
    canvas.drawArc(innerRect, startAngle, sweepAngle, false,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);

    // Same multi-shade blue colors as the real discipline gauge
    const activeColors = [
      Color(0xFFBCE3FF), // 1. Lightest Blue
      Color(0xFF65B4FF), // 2. Light Blue
      Color(0xFF2796FF), // 3. Blue (Moderate)
      Color(0xFF0278D9), // 4. Dark Blue (Good)
      Color(0xFF015294), // 5. Darkest Blue (Excellent)
    ];

    int targetSegments = 1;
    final score = level.score;
    if (score > 0.3) targetSegments = 2;
    if (score >= 0.7) targetSegments = 3;
    if (score >= 0.85) targetSegments = 4;
    if (score >= 1.0) targetSegments = 5;

    // Draw right-to-left so left segments' caps sit on top (matches real gauge)
    for (int i = targetSegments - 1; i >= 0; i--) {
      final start = startAngle + (i * segmentSweep);
      canvas.drawArc(innerRect, start, segmentSweep, false,
        Paint()
          ..color = activeColors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Exact miniature of _AllocationGaugePainter:
// grey bg + single active segment + white gap lines
class _MiniAllocationPainter extends CustomPainter {
  final AllocationLevel level;
  _MiniAllocationPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const startAngle = math.pi;
    const sweepAngle = math.pi;
    const numSegments = 5;
    const segmentSweep = sweepAngle / numSegments;

    final innerRadius = radius - 5;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // Grey background arc
    canvas.drawArc(innerRect, startAngle, sweepAngle, false,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);

    // Single active segment (same as real allocation gauge)
    final activeIndex = level.activeSegments - 1;
    final activeStart = startAngle + (activeIndex * segmentSweep);
    canvas.drawArc(innerRect, activeStart, segmentSweep, false,
      Paint()
        ..color = level.activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.butt);

    // White gap lines between segments
    final gapPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;

    for (int i = 1; i < numSegments; i++) {
      final angle = startAngle + (i * segmentSweep);
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      canvas.drawLine(
        center + Offset(dx * (innerRadius - 5), dy * (innerRadius - 5)),
        center + Offset(dx * (innerRadius + 5), dy * (innerRadius + 5)),
        gapPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Exact miniature of _PerformanceGaugePainter:
// grey bg + multi-shade green segments drawn right-to-left with overlapping round caps
class _MiniPerformancePainter extends CustomPainter {
  final PerformanceLevel level;
  _MiniPerformancePainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const startAngle = math.pi;
    const sweepAngle = math.pi;
    const numSegments = 5;
    const segmentSweep = sweepAngle / numSegments;

    final innerRadius = radius - 5;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // Grey background arc
    canvas.drawArc(innerRect, startAngle, sweepAngle, false,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);

    // Same multi-shade green colors as real performance gauge
    const activeColors = [
      Color(0xFFBBE5B3),
      Color(0xFF86EFAC),
      Color(0xFF4ADE80),
      Color(0xFF22C55E),
      Color(0xFF16A34A),
    ];

    final targetSegments = level.activeSegments;

    // Draw right-to-left so left segments' caps sit on top (matches real gauge)
    for (int i = targetSegments - 1; i >= 0; i--) {
      final start = startAngle + (i * segmentSweep);
      canvas.drawArc(innerRect, start, segmentSweep, false,
        Paint()
          ..color = activeColors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


