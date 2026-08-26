// ============================================================
// FILE: lib/features/analytics/widgets/category_allocation_card.dart
// Rounded "petal/wedge" radial chart — ported geometry from
// zeyro_new_ui's _WedgeChartPainter, re-skinned to astra's
// DMSans/DMSans and slate/azure palette.
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/analytics_models.dart';

class CategoryAllocationCard extends StatefulWidget {
  final List<CategoryAllocation> allocations;
  final VoidCallback? onTap;

  const CategoryAllocationCard({super.key, required this.allocations, this.onTap});

  @override
  State<CategoryAllocationCard> createState() => _CategoryAllocationCardState();
}

class _CategoryAllocationCardState extends State<CategoryAllocationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _curvedAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _curvedAnim = CurvedAnimation(
      parent: _animController,
      curve: const Cubic(0.23, 1.0, 0.32, 1.0),
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant CategoryAllocationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allocations != widget.allocations) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _headerTitle() {
    if (widget.allocations.isEmpty) return '';
    final sorted = [...widget.allocations]..sort((a, b) => b.actualSpent.compareTo(a.actualSpent));
    final total = widget.allocations.fold<double>(0, (s, c) => s + c.actualSpent);
    if (total == 0) return '';
    final top1 = sorted[0];
    final topPercent = (top1.actualSpent / total * 100).round();
    return '$topPercent% on ${top1.categoryName.toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final top5 = ([...widget.allocations]..sort((a, b) => b.actualSpent.compareTo(a.actualSpent))).take(5).toList();
    if (top5.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top spending category',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _headerTitle(),
            style: const TextStyle(fontFamily: 'DMSans', fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = constraints.maxWidth < 220 ? constraints.maxWidth : 220.0;
                return SizedBox(
                  width: side,
                  height: side,
                  child: AnimatedBuilder(
                    animation: _curvedAnim,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _WedgeChartPainter(
                          categories: top5,
                          animationProgress: _curvedAnim.value,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WedgeChartPainter extends CustomPainter {
  final List<CategoryAllocation> categories;
  final double animationProgress;

  const _WedgeChartPainter({
    required this.categories,
    this.animationProgress = 1.0,
  });

  static const _fill = Color(0xFFDCE9FB); // light azure fill
  static const _valueColor = Color(0xFF0F172A);
  static const _labelColor = Color(0xFF64748B);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.95;
    final minRadius = maxRadius * 0.15;

    final count = categories.length;
    final sweepAngle = (2 * pi) / count;
    const gap = 6.0;

    final filledPaint = Paint()
      ..color = _fill
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10 * animationProgress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    var maxVal = categories.isEmpty ? 1 : categories.map((c) => c.actualSpent).reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) maxVal = 1;

    for (var i = 0; i < count; i++) {
      final centerAngle = i * sweepAngle - pi / 2;

      final rawRatio = categories[i].actualSpent / maxVal;
      var visualRatio = 0.45 + (sqrt(rawRatio) * 0.55);
      visualRatio = visualRatio.clamp(0.45, 1.0);

      final targetFillRadius = minRadius + (maxRadius - minRadius) * visualRatio;

      final wedgeStart = (i * 0.05).clamp(0.0, 0.4);
      final wedgeProgress = ((animationProgress - wedgeStart) / (1.0 - wedgeStart)).clamp(0.0, 1.0);
      final currentFillRadius = minRadius + (targetFillRadius - minRadius) * wedgeProgress;

      if (wedgeProgress > 0.01) {
        _drawRoundedWedge(
          canvas,
          center,
          minRadius * 0.8,
          currentFillRadius,
          centerAngle,
          sweepAngle,
          gap,
          filledPaint,
          shadowPaint: shadowPaint,
        );
      }

      if (animationProgress > 0.3) {
        final labelAlpha = ((animationProgress - 0.3) / 0.7).clamp(0.0, 1.0);
        final labelScale = 0.92 + (0.08 * labelAlpha);
        final textRadius = maxRadius + 20.0;
        final textCenter = Offset(center.dx + textRadius * cos(centerAngle), center.dy + textRadius * sin(centerAngle));

        var textRotation = centerAngle + pi / 2;
        if (textRotation > pi / 2 && textRotation < 3 * pi / 2) textRotation += pi;

        canvas.save();
        canvas.translate(textCenter.dx, textCenter.dy);
        canvas.rotate(textRotation);
        canvas.scale(labelScale, labelScale);

        final valueSpan = TextSpan(
          text: '₹${categories[i].actualSpent.toInt()}\n',
          style: TextStyle(
            fontFamily: 'DMSans',
            color: _valueColor.withValues(alpha: labelAlpha),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(
              text: categories[i].categoryName.toUpperCase(),
              style: TextStyle(
                fontFamily: 'DMSans',
                color: _labelColor.withValues(alpha: labelAlpha),
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ],
        );

        final textPainter = TextPainter(text: valueSpan, textAlign: TextAlign.center, textDirection: TextDirection.ltr)..layout();
        textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

        canvas.restore();
      }
    }
  }

  void _drawRoundedWedge(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
    double centerAngle,
    double wedgeSweepAngle,
    double gap,
    Paint paint, {
    Paint? shadowPaint,
  }) {
    const cornerRadius = 26.0;
    final strokeOffset = cornerRadius / 2;
    final pathInnerRadius0 = innerRadius + strokeOffset;
    var pathOuterRadius = outerRadius - strokeOffset;

    if (pathOuterRadius <= pathInnerRadius0) return;

    final pathGap = gap + cornerRadius;
    final halfGap = pathGap / 2.0;

    var pathInnerRadius = pathInnerRadius0;
    if (pathInnerRadius <= halfGap) pathInnerRadius = halfGap + 1.0;
    if (pathOuterRadius <= halfGap) return;

    final outerOffset = asin((halfGap / pathOuterRadius).clamp(-1.0, 1.0));
    final outerStart = (centerAngle - wedgeSweepAngle / 2) + outerOffset;
    final outerSweep = wedgeSweepAngle - 2 * outerOffset;

    final innerOffset = asin((halfGap / pathInnerRadius).clamp(-1.0, 1.0));
    final innerStart = (centerAngle - wedgeSweepAngle / 2) + innerOffset;
    final innerSweep = wedgeSweepAngle - 2 * innerOffset;

    final path = Path();
    path.addArc(Rect.fromCircle(center: center, radius: pathOuterRadius), outerStart, outerSweep);
    path.arcTo(Rect.fromCircle(center: center, radius: pathInnerRadius), innerStart + innerSweep, -innerSweep, false);
    path.close();

    final strokePaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerRadius
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    if (shadowPaint != null) canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, strokePaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WedgeChartPainter oldDelegate) =>
      oldDelegate.categories != categories ||
      oldDelegate.animationProgress != animationProgress;
}
