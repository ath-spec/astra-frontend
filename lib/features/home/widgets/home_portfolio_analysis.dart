import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../portfolio_analysis/models/portfolio_analysis_models.dart';
import '../../portfolio_analysis/data/portfolio_analysis_providers.dart';

class HomePortfolioAnalysis extends ConsumerWidget {
  const HomePortfolioAnalysis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnlocked = ref.watch(portfolioAnalysisUnlockedProvider);
    final allocAsync = ref.watch(portfolioAllocationProvider);
    final discAsync = ref.watch(portfolioDisciplineProvider);
    final perfAsync = ref.watch(portfolioPerformanceProvider);

    final allocationLevel = allocAsync.value?.level ?? AllocationLevel.veryAggressive;
    final disciplineLevel = discAsync.value?.level ?? DisciplineLevel.moderate;
    final performanceLevel = perfAsync.value?.level ?? PerformanceLevel.veryStrong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF5BA1F7),
              Color(0xFF031E6B),
              Color(0xFF241714),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 22,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Analyse your wealth',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.0,
                  color: Colors.white,
                ),
              ),
            ],
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
        hasUnlocked
            ? _buildUnlockedView(context, disciplineLevel, allocationLevel, performanceLevel)
            : _buildLockedView(context),
      ],
    );
  }

  Widget _buildUnlockedView(
    BuildContext context,
    DisciplineLevel disciplineLevel,
    AllocationLevel allocationLevel,
    PerformanceLevel performanceLevel,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalysisCard(
            context: context,
            title: 'Discipline',
            tabIndex: 0,
            icon: Icons.track_changes,
            valueText: disciplineLevel.label,
            valueColor: disciplineLevel.color,
            gradientColors: disciplineLevel.gradientColors,
            bottomText: 'VIEW >',
            painter: _MiniDisciplinePainter(level: disciplineLevel),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildAnalysisCard(
            context: context,
            title: 'Allocation',
            tabIndex: 1,
            icon: Icons.view_in_ar_outlined,
            valueText: allocationLevel.label,
            valueColor: allocationLevel.activeColor,
            gradientColors: allocationLevel.gradientColors,
            bottomText: '• 2 INSIGHTS >',
            bottomBgColor: const Color(0xFFFEF3C7),
            bottomTextColor: const Color(0xFF92400E),
            painter: _MiniAllocationPainter(
              level: allocationLevel,
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
            valueText: performanceLevel.label,
            valueColor: performanceLevel.activeColor,
            gradientColors: performanceLevel.gradientColors,
            bottomText: 'VIEW >',
            painter: _MiniPerformancePainter(
              level: performanceLevel,
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
                    color: const Color(0xFF4299E1),
                    brailleDots: '⠓⠕⠗⠍',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLockedCard(
                    title: 'Allocation',
                    icon: Icons.layers_outlined,
                    color: const Color(0xFF6B46C1),
                    brailleDots: '⠓⠕⠗⠍',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLockedCard(
                    title: 'Performance',
                    icon: Icons.change_history,
                    color: const Color(0xFF48BB78),
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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 6),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            brailleDots,
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: 2.0,
              color: Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'LOCKED',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF94A3B8),
            ),
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
    required List<Color> gradientColors,
    required String bottomText,
    Color? bottomBgColor,
    Color? bottomTextColor,
    required CustomPainter painter,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/portfolio-analysis?tab=$tabIndex');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 13, color: const Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            title,
                            maxLines: 1,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 60,
                    height: 35,
                    child: CustomPaint(painter: painter),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: gradientColors.isNotEmpty
                        ? ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              valueText,
                              textAlign: TextAlign.center,
                              maxLines: 1,
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
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: valueColor,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: bottomBgColor ?? const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  bottomText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: bottomTextColor ?? const Color(0xFF64748B),
                  ),
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

    canvas.drawArc(innerRect, startAngle, sweepAngle, false,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);

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

    canvas.drawArc(innerRect, startAngle, sweepAngle, false,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);

    const activeColors = [
      Color(0xFFBCE3FF),
      Color(0xFF65B4FF),
      Color(0xFF2796FF),
      Color(0xFF0278D9),
      Color(0xFF015294),
    ];

    int targetSegments = 1;
    final score = level.score;
    if (score > 0.3) targetSegments = 2;
    if (score >= 0.7) targetSegments = 3;
    if (score >= 0.85) targetSegments = 4;
    if (score >= 1.0) targetSegments = 5;

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

    canvas.drawArc(innerRect, startAngle, sweepAngle, false,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);

    final activeIndex = (level.activeSegments - 1).clamp(0, 4);
    final activeStart = startAngle + (activeIndex * segmentSweep);
    canvas.drawArc(innerRect, activeStart, segmentSweep, false,
      Paint()
        ..color = level.activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.butt);

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

    canvas.drawArc(innerRect, startAngle, sweepAngle, false,
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);

    const activeColors = [
      Color(0xFFBBE5B3),
      Color(0xFF86EFAC),
      Color(0xFF4ADE80),
      Color(0xFF22C55E),
      Color(0xFF16A34A),
    ];

    final targetSegments = level.activeSegments.clamp(1, 5);

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
