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
  ConsumerState<PortfolioGenomeChart> createState() =>
      _PortfolioGenomeChartState();
}

class _PortfolioGenomeChartState extends ConsumerState<PortfolioGenomeChart>
    with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1500),
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
    final List<double> dnaValues = ref.watch(portfolioDnaProvider);
    final List<double> values = widget.customValues ?? dnaValues;

    return VisibilityDetector(
      key: const Key('PortfolioGenomeChart'),
      onVisibilityChanged: (info) {
        if (!_hasAnimated && info.visibleFraction >= 0.15) {
          _hasAnimated = true;
          _controller.forward();
        }
      },
      child: AspectRatio(
        aspectRatio: 390 / 330,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double size = math.min(constraints.maxWidth, constraints.maxHeight);
            return Center(
              child: SizedBox(
                width: size,
                height: size,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const SpiderChartInfoSheet(),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: CustomPaint(
                    painter: _SpiderChartPainter(
                      values: values,
                      labels: _labels,
                      animation: _animation,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
    final radius = (size.width / 2) * 0.55;
    final int numSides = labels.length;
    final double angle = (2 * math.pi) / numSides;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisGridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const int rings = 3;
    for (int i = 1; i <= rings; i++) {
      final r = radius * (i / rings);
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

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int j = 0; j < numSides; j++) {
      final double currentAngle = -math.pi / 2 + angle * j;
      final x = center.dx + radius * math.cos(currentAngle);
      final y = center.dy + radius * math.sin(currentAngle);

      canvas.drawLine(center, Offset(x, y), axisGridPaint);

      final double labelX = center.dx +
          (radius + getProportionateScreenWidth(24)) * math.cos(currentAngle);
      final double labelY = center.dy +
          (radius + getProportionateScreenWidth(24)) * math.sin(currentAngle);

      textPainter.text = TextSpan(
        text: labels[j],
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: getProportionateScreenWidth(10),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
          height: 1.1,
        ),
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(
              labelX - textPainter.width / 2, labelY - textPainter.height / 2));
    }

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
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.15 * animation.value)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, strokePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    final dotBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int j = 0; j < numSides; j++) {
      final double currentAngle = -math.pi / 2 + angle * j;
      final double animatedValue = values[j] * animation.value;
      final double r = radius * animatedValue;
      final x = center.dx + r * math.cos(currentAngle);
      final y = center.dy + r * math.sin(currentAngle);

      canvas.drawCircle(Offset(x, y), 4.0, dotBgPaint);
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
