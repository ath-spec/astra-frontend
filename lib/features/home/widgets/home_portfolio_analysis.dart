import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../portfolio_analysis/models/portfolio_analysis_models.dart';
import '../../portfolio_analysis/data/portfolio_analysis_providers.dart';

final ValueNotifier<bool> hasSeenAnalysisWalkthrough = ValueNotifier<bool>(
  false,
);

class HomePortfolioAnalysis extends ConsumerWidget {
  const HomePortfolioAnalysis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disciplineAsync = ref.watch(portfolioDisciplineProvider);
    final allocationAsync = ref.watch(portfolioAllocationProvider);
    final performanceAsync = ref.watch(portfolioPerformanceProvider);

    final disciplineLevel = disciplineAsync.value?.level;
    final allocationLevel = allocationAsync.value?.level;
    final performanceLevel = performanceAsync.value?.level;

    // Only show unlocked cards if the user has completed the walkthrough
    // AND all three providers have real backend data
    final hasData = disciplineLevel != null && allocationLevel != null && performanceLevel != null;

    return ValueListenableBuilder<bool>(
      valueListenable: hasSeenAnalysisWalkthrough,
      builder: (context, hasSeen, child) {
        final showUnlocked = hasSeen && hasData;
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
            const SizedBox(height: 16),
            showUnlocked
                ? _buildUnlockedCards(context, disciplineLevel!, allocationLevel!, performanceLevel!)
                : _buildLockedCards(context),
          ],
        );
      },
    );
  }

  Widget _buildLockedCards(BuildContext context) {
    return Row(
      children: [
        _buildLockedCard(
          context: context,
          title: 'Discipline',
          bottomText: 'Check habit score',
          color: const Color(0xFF0278D9),
        ),
        const SizedBox(width: 8),
        _buildLockedCard(
          context: context,
          title: 'Allocation',
          bottomText: 'Check risk level',
          color: const Color(0xFFF09536),
        ),
        const SizedBox(width: 8),
        _buildLockedCard(
          context: context,
          title: 'Performance',
          bottomText: 'Compare with peers',
          color: const Color(0xFF16A34A),
        ),
      ],
    );
  }

  Widget _buildUnlockedCards(BuildContext context, DisciplineLevel disciplineLevel, AllocationLevel allocationLevel, PerformanceLevel performanceLevel) {
    return Row(
      children: [
        _buildAnalysisCard(
          context: context,
          title: 'Discipline',
          value: disciplineLevel.label,
          valueColor: disciplineLevel.color,
          bottomText: '${(disciplineLevel.score * 100).toInt()}% consistency',
          painter: _MiniDisciplinePainter(level: disciplineLevel),
          tabIndex: 0,
        ),
        const SizedBox(width: 8),
        _buildAnalysisCard(
          context: context,
          title: 'Allocation',
          value: allocationLevel.label,
          valueColor: allocationLevel.activeColor,
          bottomText: '${allocationLevel.activeSegments}/5 Risk tier',
          painter: _MiniAllocationPainter(level: allocationLevel),
          tabIndex: 1,
        ),
        const SizedBox(width: 8),
        _buildAnalysisCard(
          context: context,
          title: 'Performance',
          value: performanceLevel.label,
          valueColor: performanceLevel.activeColor,
          bottomText: '${performanceLevel.activeSegments}/5 Returns tier',
          painter: _MiniPerformancePainter(level: performanceLevel),
          tabIndex: 2,
        ),
      ],
    );
  }

  Widget _buildLockedCard({
    required BuildContext context,
    required String title,
    required String bottomText,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push('/analysis-walkthrough'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 50,
                        height: 25,
                        child: CustomPaint(
                          painter: _LockedSemiCircleGaugePainter(color: color),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 10,
                              color: Color(0xFF64748B),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Locked',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: Text(
                  bottomText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color valueColor,
    required String bottomText,
    required CustomPainter painter,
    required int tabIndex,
    Color? bottomBgColor,
    Color? bottomTextColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push('/portfolio-analysis?tab=$tabIndex'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 50,
                        height: 25,
                        child: CustomPaint(painter: painter),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: bottomBgColor ?? const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
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
