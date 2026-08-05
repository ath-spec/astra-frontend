import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../core/responsive/size_config.dart';
import 'spider_chart_info_sheet.dart';

class PortfolioGenomeChart extends StatefulWidget {
  const PortfolioGenomeChart({super.key});

  @override
  State<PortfolioGenomeChart> createState() => _PortfolioGenomeChartState();
}

class _PortfolioGenomeChartState extends State<PortfolioGenomeChart> with SingleTickerProviderStateMixin {
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

  final List<double> _values = [
    0.85, // Growth
    0.30, // Income
    0.15, // Capital Preservation
    0.40, // Inflation Protection
    0.80, // Liquidity
    0.50, // Sustainability
    0.10, // Real Asset Exposure
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
    return VisibilityDetector(
      key: const Key('PortfolioGenomeChart'),
      onVisibilityChanged: (info) {
        if (!_hasAnimated && info.visibleFraction >= 0.6) {
          _hasAnimated = true;
          _controller.forward();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: getProportionateScreenHeight(250),
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => SpiderChartInfoSheet.show(context),
                    behavior: HitTestBehavior.opaque,
                    child: CustomPaint(
                      painter: _SpiderChartPainter(
                        values: _values,
                        labels: _labels,
                        animation: _animation,
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
        ],
      ),
    );
  }
}

class _SpiderChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Animation<double> animation;

  _SpiderChartPainter({
    required this.values,
    required this.labels,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Allow padding for labels
    final radius = math.min(size.width / 2, size.height / 2) - 45;

    final int numSides = values.length;
    final double angle = (2 * math.pi) / numSides;

    // 1. Draw background grid (concentric polygons)
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

    // 2. Draw axes lines and labels
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int j = 0; j < numSides; j++) {
      final double currentAngle = -math.pi / 2 + angle * j;
      final x = center.dx + radius * math.cos(currentAngle);
      final y = center.dy + radius * math.sin(currentAngle);
      
      canvas.drawLine(center, Offset(x, y), gridPaint);

      // Label position
      final double labelX = center.dx + (radius + getProportionateScreenWidth(24)) * math.cos(currentAngle);
      final double labelY = center.dy + (radius + getProportionateScreenWidth(24)) * math.sin(currentAngle);
      
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

    // 3. Draw animated value polygon
    final valuePath = Path();
    for (int j = 0; j < numSides; j++) {
      final double currentAngle = -math.pi / 2 + angle * j;
      final double animatedValue = values[j] * animation.value; 
      final double r = radius * animatedValue;
      final x = center.dx + r * math.cos(currentAngle);
      final y = center.dy + r * math.sin(currentAngle);
      if (j == 0) {
        valuePath.moveTo(x, y);
      } else {
        valuePath.lineTo(x, y);
      }
    }
    valuePath.close();

    final fillPaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.15 * animation.value)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(animation.value)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, strokePaint);
    
    // 4. Draw dots at the vertices
    final dotPaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(animation.value)
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

  @override
  bool shouldRepaint(covariant _SpiderChartPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}
