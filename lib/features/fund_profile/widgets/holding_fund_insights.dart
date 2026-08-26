import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../core/responsive/size_config.dart';
import '../../../core/widgets/animated_gradient_text.dart';
import '../../portfolio_analysis/data/portfolio_analysis_providers.dart';
import '../../portfolio_analysis/widgets/portfolio_analysis/allocation_components/spider_chart_info_sheet.dart';

class HoldingFundInsights extends ConsumerStatefulWidget {
  final bool isPositiveImpact;
  final String whatItDoesRightNow;
  final String whatBuyingMoreWillDo;
  final List<double>? currentValues;
  final List<double>? projectedValues;

  const HoldingFundInsights({
    super.key, 
    required this.isPositiveImpact,
    required this.whatItDoesRightNow,
    required this.whatBuyingMoreWillDo,
    this.currentValues,
    this.projectedValues,
  });

  @override
  ConsumerState<HoldingFundInsights> createState() => _HoldingFundInsightsState();
}

class _HoldingFundInsightsState extends ConsumerState<HoldingFundInsights> with SingleTickerProviderStateMixin {
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
    final liveDna = ref.watch(portfolioDnaProvider);
    final currentValues = (widget.currentValues != null && widget.currentValues!.length == 7)
        ? widget.currentValues!
        : liveDna;

    final projectedValues = (widget.projectedValues != null && widget.projectedValues!.length == 7)
        ? widget.projectedValues!
        : (widget.isPositiveImpact
            ? [
                (currentValues[0] + 0.08).clamp(0.1, 0.95),
                currentValues[1],
                (currentValues[2] + 0.05).clamp(0.1, 0.90),
                currentValues[3],
                currentValues[4],
                (currentValues[5] + 0.05).clamp(0.1, 0.90),
                currentValues[6],
              ]
            : [
                (currentValues[0] - 0.05).clamp(0.1, 0.95),
                currentValues[1],
                currentValues[2],
                currentValues[3],
                currentValues[4],
                currentValues[5],
                currentValues[6],
              ]);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(20),
        vertical: getProportionateScreenHeight(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedGradientShimmer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: getProportionateScreenWidth(16), color: Colors.white),
                    SizedBox(width: getProportionateScreenWidth(4)),
                    Text(
                      'INSIGHTS BY PORTFOLIO AGENT',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: getProportionateScreenWidth(10),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(8)),
              const Expanded(
                child: Divider(
                  color: Color(0xFFE2E8F0),
                  thickness: 1,
                  height: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(16)),
          Text(
            'How this fund shapes your portfolio',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: getProportionateScreenWidth(18),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: const Color(0xFF0F172A),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Current DNA', const Color(0xFF2563EB)),
              SizedBox(width: getProportionateScreenWidth(16)),
              _buildLegendItem('After Buying More', widget.isPositiveImpact ? const Color(0xFF10B981) : const Color(0xFFF43F5E)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          VisibilityDetector(
            key: const Key('HoldingFundInsightsChart'),
            onVisibilityChanged: (info) {
              if (!_hasAnimated && info.visibleFraction >= 0.15) {
                _hasAnimated = true;
                _controller.forward();
              }
            },
            child: AspectRatio(
              aspectRatio: 390 / 280,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => SpiderChartInfoSheet.show(context),
                      behavior: HitTestBehavior.opaque,
                      child: CustomPaint(
                        painter: _DualSpiderChartPainter(
                          currentValues: currentValues,
                          projectedValues: projectedValues,
                          labels: _labels,
                          animation: _animation,
                          projectedColor: widget.isPositiveImpact ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => SpiderChartInfoSheet.show(context),
                      child: Padding(
                        padding: EdgeInsets.all(getProportionateScreenWidth(8)),
                        child: Icon(Icons.info_outline_rounded, size: getProportionateScreenWidth(16), color: const Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 24),

          _buildInsightSection(
            title: 'What it does right now',
            description: widget.whatItDoesRightNow.isNotEmpty ? widget.whatItDoesRightNow : 'Anchors portfolio core equity returns with steady capital growth.',
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF10B981),
          ),
          
          const SizedBox(height: 20),
          
          _buildInsightSection(
            title: 'What buying more will do',
            description: widget.whatBuyingMoreWillDo.isNotEmpty ? widget.whatBuyingMoreWillDo : 'Further tilts your allocation toward high alpha growth and enhances compounding efficiency.',
            icon: Icons.add_chart_rounded,
            iconColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightSection({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DualSpiderChartPainter extends CustomPainter {
  final List<double> currentValues;
  final List<double> projectedValues;
  final List<String> labels;
  final Animation<double> animation;
  final Color projectedColor;

  _DualSpiderChartPainter({
    required this.currentValues,
    required this.projectedValues,
    required this.labels,
    required this.animation,
    required this.projectedColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 45;
    final int numSides = currentValues.length;
    final double angle = (2 * math.pi) / numSides;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final double r = radius * (i / 4);
      final path = Path();
      for (int j = 0; j < numSides; j++) {
        final double currentAngle = -math.pi / 2 + angle * j;
        final x = center.dx + r * math.cos(currentAngle);
        final y = center.dy + r * math.sin(currentAngle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    final axisPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int j = 0; j < numSides; j++) {
      final double currentAngle = -math.pi / 2 + angle * j;
      final x = center.dx + radius * math.cos(currentAngle);
      final y = center.dy + radius * math.sin(currentAngle);

      canvas.drawLine(center, Offset(x, y), axisPaint);

      final double labelX = center.dx + (radius + 22) * math.cos(currentAngle);
      final double labelY = center.dy + (radius + 22) * math.sin(currentAngle);

      textPainter.text = TextSpan(
        text: labels[j],
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
          height: 1.1,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
    }

    void drawPolygon(List<double> values, Color color) {
      final path = Path();
      for (int j = 0; j < numSides; j++) {
        final double currentAngle = -math.pi / 2 + angle * j;
        final double animatedValue = values[j] * animation.value; 
        final double r = radius * animatedValue;
        final x = center.dx + r * math.cos(currentAngle);
        final y = center.dy + r * math.sin(currentAngle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.15 * animation.value)
        ..style = PaintingStyle.fill;
      
      final strokePaint = Paint()
        ..color = color.withValues(alpha: animation.value)
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 2.0;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      
      final dotPaint = Paint()
        ..color = color.withValues(alpha: animation.value)
        ..style = PaintingStyle.fill;
        
      for (int j = 0; j < numSides; j++) {
        final double currentAngle = -math.pi / 2 + angle * j;
        final double animatedValue = values[j] * animation.value; 
        final double r = radius * animatedValue;
        final x = center.dx + r * math.cos(currentAngle);
        final y = center.dy + r * math.sin(currentAngle);
        canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
      }
    }

    drawPolygon(currentValues, const Color(0xFF2563EB));
    drawPolygon(projectedValues, projectedColor);
  }

  @override
  bool shouldRepaint(covariant _DualSpiderChartPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.currentValues != currentValues ||
        oldDelegate.projectedValues != projectedValues;
  }
}
