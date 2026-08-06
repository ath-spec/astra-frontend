import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../portfolio_analysis/widgets/portfolio_analysis/allocation_components/spider_chart_info_sheet.dart';
import '../../../core/responsive/size_config.dart';

class HoldingFundInsights extends StatefulWidget {
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
  State<HoldingFundInsights> createState() => _HoldingFundInsightsState();
}

class _HoldingFundInsightsState extends State<HoldingFundInsights> with SingleTickerProviderStateMixin {
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

  late List<double> _currentValues;
  late List<double> _projectedValues;

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
    
    // Use provided values or defaults
    _currentValues = widget.currentValues ?? [0.50, 0.40, 0.60, 0.30, 0.70, 0.40, 0.20];
    _projectedValues = widget.projectedValues ?? (
        widget.isPositiveImpact 
            ? [0.75, 0.45, 0.70, 0.35, 0.75, 0.50, 0.25] 
            : [0.95, 0.20, 0.30, 0.20, 0.80, 0.30, 0.10]
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(width: 4),
              Text(
                'INSIGHTS BY DISCOVER AGENT',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: 8),
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQaBlock(
                  'What does this fund do right now?',
                  widget.whatItDoesRightNow
                ),
                const SizedBox(height: 16),
                
                _buildQaBlock(
                  'What will buying more do to your portfolio?',
                  widget.whatBuyingMoreWillDo
                ),
                
                const SizedBox(height: 32),
                
                // Spider Chart Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Current DNA', const Color(0xFF2563EB)),
                    SizedBox(width: getProportionateScreenWidth(16)),
                    _buildLegendItem('After Investing', widget.isPositiveImpact ? const Color(0xFF10B981) : const Color(0xFFF43F5E)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                VisibilityDetector(
                  key: const Key('MfFundInsightsChart'),
                  onVisibilityChanged: (info) {
                    if (!_hasAnimated && info.visibleFraction >= 0.6) {
                      _hasAnimated = true;
                      _controller.forward();
                    }
                  },
                  child: SizedBox(
                    height: getProportionateScreenHeight(240),
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => SpiderChartInfoSheet.show(context),
                            behavior: HitTestBehavior.opaque,
                            child: CustomPaint(
                              painter: _DualSpiderChartPainter(
                                currentValues: _currentValues,
                                projectedValues: _projectedValues,
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
              ],
            ),
          ),
        ],
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
            color: color.withOpacity(0.2),
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

  Widget _buildQaBlock(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            height: 1.5,
            color: Color(0xFF475569),
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

    // 1. Draw grid
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
        if (j == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 2. Draw axes and labels
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int j = 0; j < numSides; j++) {
      final double currentAngle = -math.pi / 2 + angle * j;
      final x = center.dx + radius * math.cos(currentAngle);
      final y = center.dy + radius * math.sin(currentAngle);
      canvas.drawLine(center, Offset(x, y), gridPaint);

      final double labelX = center.dx + (radius + 20) * math.cos(currentAngle);
      final double labelY = center.dy + (radius + 20) * math.sin(currentAngle);
      
      textPainter.text = TextSpan(
        text: labels[j],
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: getProportionateScreenWidth(10),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2)
      );
    }

    // Function to draw a polygon
    void drawPolygon(List<double> values, Color color) {
      final path = Path();
      for (int j = 0; j < numSides; j++) {
        final double currentAngle = -math.pi / 2 + angle * j;
        final double animatedValue = values[j] * animation.value; 
        final double r = radius * animatedValue;
        final x = center.dx + r * math.cos(currentAngle);
        final y = center.dy + r * math.sin(currentAngle);
        if (j == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();

      final fillPaint = Paint()
        ..color = color.withOpacity(0.15 * animation.value)
        ..style = PaintingStyle.fill;
      
      final strokePaint = Paint()
        ..color = color.withOpacity(animation.value)
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 2.0;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
      
      final dotPaint = Paint()
        ..color = color.withOpacity(animation.value)
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

    // 3. Draw Current Values (Blue)
    drawPolygon(currentValues, const Color(0xFF2563EB));
    
    // 4. Draw Projected Values
    drawPolygon(projectedValues, projectedColor);
  }

  @override
  bool shouldRepaint(covariant _DualSpiderChartPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}
