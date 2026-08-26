import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../core/responsive/size_config.dart';
import '../../../data/portfolio_analysis_providers.dart';
import 'spider_chart_info_sheet.dart';

class PortfolioGenomeChart extends ConsumerStatefulWidget {
  final List<double>? customValues;

  const PortfolioGenomeChart({super.key, this.customValues});

  @override
  ConsumerState<PortfolioGenomeChart> createState() => _PortfolioGenomeChartState();
}

class _PortfolioGenomeChartState extends ConsumerState<PortfolioGenomeChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  final List<String> _labels = [
    'Growth',
    'Income',
    'Capital\nPreservation',
    'Inflation\nDefense',
    'Liquidity',
    'Sustainability',
    'Real Assets'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allocAsync = ref.watch(portfolioAllocationProvider);
    final alloc = allocAsync.value;

    List<double> currentValues;
    if (widget.customValues != null) {
      currentValues = widget.customValues!;
    } else if (alloc != null) {
      final equityFactor = (alloc.equityPct / 100).clamp(0.15, 0.95);
      final debtFactor = (alloc.debtPct / 100).clamp(0.10, 0.85);
      final otherFactor = (alloc.otherPct / 100).clamp(0.08, 0.75);

      currentValues = [
        equityFactor,                                        // Growth
        debtFactor > 0.05 ? debtFactor : 0.30,              // Income
        debtFactor > 0.05 ? (debtFactor * 0.9) : 0.20,      // Capital Preservation
        otherFactor > 0.05 ? (otherFactor * 2.0).clamp(0.1, 0.9) : 0.40, // Inflation Defense
        0.80,                                               // Liquidity
        0.55,                                               // Sustainability
        otherFactor > 0.05 ? (otherFactor * 1.5).clamp(0.1, 0.85) : 0.15, // Real Assets
      ];
    } else {
      currentValues = [0.85, 0.30, 0.15, 0.40, 0.80, 0.50, 0.10];
    }

    return VisibilityDetector(
      key: const Key('PortfolioGenomeChart'),
      onVisibilityChanged: (info) {
        if (!_hasAnimated && info.visibleFraction >= 0.2) {
          _hasAnimated = true;
          _controller.forward();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PORTFOLIO GENOME',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => const SpiderChartInfoSheet(),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              const _DottedDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Center(
                  child: SizedBox(
                    height: 300,
                    width: 300,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _RadarChartPainter(
                            labels: _labels,
                            values: currentValues,
                            animationProgress: _animation.value,
                          ),
                        );
                      },
                    ),
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

class _RadarChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final double animationProgress;

  _RadarChartPainter({
    required this.labels,
    required this.values,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.72;
    final int sides = labels.length;
    final double angleStep = (math.pi * 2) / sides;
    const double startAngle = -math.pi / 2;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw 4 concentric polygon rings
    for (int ring = 1; ring <= 4; ring++) {
      final ringRadius = radius * (ring / 4);
      final ringPath = Path();
      for (int i = 0; i < sides; i++) {
        final angle = startAngle + (i * angleStep);
        final x = center.dx + ringRadius * math.cos(angle);
        final y = center.dy + ringRadius * math.sin(angle);
        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // Draw radial axes and label positioning
    for (int i = 0; i < sides; i++) {
      final angle = startAngle + (i * angleStep);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(endX, endY), axisPaint);

      // Draw label
      final labelRadius = radius + 24.0;
      final labelX = center.dx + labelRadius * math.cos(angle);
      final labelY = center.dy + labelRadius * math.sin(angle);

      final textSpan = TextSpan(
        text: labels[i],
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
          height: 1.15,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final textOffset = Offset(
        labelX - (textPainter.width / 2),
        labelY - (textPainter.height / 2),
      );
      textPainter.paint(canvas, textOffset);
    }

    // Draw data polygon
    final dataPath = Path();
    final dataFillPaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.18 * animationProgress)
      ..style = PaintingStyle.fill;

    final dataStrokePaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: animationProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < sides; i++) {
      final angle = startAngle + (i * angleStep);
      final val = values[i] * animationProgress;
      final pointRadius = radius * val;
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);

      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, dataFillPaint);
    canvas.drawPath(dataPath, dataStrokePaint);

    // Draw data vertices
    final vertexPaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: animationProgress)
      ..style = PaintingStyle.fill;

    final vertexInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < sides; i++) {
      final angle = startAngle + (i * angleStep);
      final val = values[i] * animationProgress;
      final pointRadius = radius * val;
      final x = center.dx + pointRadius * math.cos(angle);
      final y = center.dy + pointRadius * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 4.0, vertexPaint);
      canvas.drawCircle(Offset(x, y), 2.0, vertexInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return animationProgress != oldDelegate.animationProgress ||
        values != oldDelegate.values;
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFFF1F5F9),
    );
  }
}
