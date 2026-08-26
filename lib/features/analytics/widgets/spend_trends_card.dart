// ============================================================
// FILE: lib/features/analytics/widgets/spend_trends_card.dart
// Month-over-month spend bar chart — ported geometry from
// zeyro_new_ui's _SpendTrendsPainter (dashed grid, average line
// + pill, tappable bars, tooltip), re-skinned to astra's
// DMSans/DMSans and slate/azure palette.
// ============================================================

import 'package:flutter/material.dart';
import '../models/analytics_models.dart';

class SpendTrendsCard extends StatefulWidget {
  final List<SpendTrend> trends;

  const SpendTrendsCard({super.key, required this.trends});

  @override
  State<SpendTrendsCard> createState() => _SpendTrendsCardState();
}

class _SpendTrendsCardState extends State<SpendTrendsCard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = -1;
  late AnimationController _animController;
  late Animation<double> _curvedAnim;

  @override
  void initState() {
    super.initState();
    if (widget.trends.isNotEmpty) _selectedIndex = widget.trends.length - 1;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _curvedAnim = CurvedAnimation(
      parent: _animController,
      curve: const Cubic(0.23, 1.0, 0.32, 1.0),
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(SpendTrendsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex == -1 && widget.trends.isNotEmpty) {
      _selectedIndex = widget.trends.length - 1;
    }
    if (oldWidget.trends != widget.trends) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trends = widget.trends;
    if (trends.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No trend data yet', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF94A3B8))),
        ),
      );
    }

    final maxVal = trends.map((e) => e.totalSpent).reduce((a, b) => a > b ? a : b);
    final values = trends.map((e) => maxVal > 0 ? (e.totalSpent / maxVal) * 0.7 : 0.0).toList();
    final average = trends.fold<double>(0, (s, e) => s + e.totalSpent) / trends.length;

    double percentageChange = 0;
    var isUp = false;
    if (trends.length >= 2) {
      final last = trends.last.totalSpent;
      final prev = trends[trends.length - 2].totalSpent;
      if (prev > 0) {
        percentageChange = ((last - prev) / prev * 100).abs();
        isUp = last > prev;
      }
    }

    final safeIndex = _selectedIndex.clamp(0, values.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          const Text(
            'Spend trend',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -1.0,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${percentageChange.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                color: isUp ? const Color(0xFFF43F5E) : const Color(0xFF22C55E),
                size: 34,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isUp
                ? 'You are spending more than last month — might want to keep an eye on it.'
                : 'Currently spending less than usual — there is room for a little extra treat.',
            style: const TextStyle(fontFamily: 'DMSans', fontSize: 11.5, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 190,
                width: double.infinity,
                child: Stack(
                  children: [
                    Row(
                      children: List.generate(
                        trends.length,
                        (index) => Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _selectedIndex = index),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _curvedAnim,
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(constraints.maxWidth, 190),
                            painter: _SpendTrendsPainter(
                              trends: trends,
                              values: values,
                              selectedIndex: safeIndex,
                              averageValue: average,
                              animationProgress: _curvedAnim.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SpendTrendsPainter extends CustomPainter {
  final List<SpendTrend> trends;
  final List<double> values;
  final int selectedIndex;
  final double averageValue;
  final double animationProgress;

  const _SpendTrendsPainter({
    required this.trends,
    required this.values,
    required this.selectedIndex,
    required this.averageValue,
    this.animationProgress = 1.0,
  });

  static const _selectedBar = Color(0xFF0F172A);
  static const _unselectedBar = Color(0xFFE2E8F0);
  static const _avgLine = Color(0xFFA7D8CD);
  static const _avgText = Color(0xFF16A34A);
  static const _labelInactive = Color(0xFF94A3B8);

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - 34;
    final chartWidth = size.width;
    final spacing = chartWidth / trends.length;
    final barWidth = (spacing * 0.5).clamp(14.0, 26.0);

    final gridAlpha = (animationProgress * 1.5).clamp(0.0, 1.0);
    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05 * gridAlpha)
      ..strokeWidth = 1;
    for (var i = 0; i < trends.length; i++) {
      final x = (i + 0.5) * spacing;
      _drawDashedLine(canvas, Offset(x, 0), Offset(x, chartHeight), gridPaint);
    }

    for (var i = 0; i < trends.length; i++) {
      final x = (i + 0.5) * spacing;
      final val = values[i];
      if (val > 0) {
        // Staggered bar growth
        final barStart = (i * 0.05).clamp(0.0, 0.4);
        final barProgress = ((animationProgress - barStart) / (1.0 - barStart)).clamp(0.0, 1.0);
        final barHeight = chartHeight * val * barProgress;
        if (barHeight > 0) {
          final barRect = RRect.fromRectAndCorners(
            Rect.fromLTWH(x - barWidth / 2, chartHeight - barHeight, barWidth, barHeight),
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
          );
          canvas.drawRRect(barRect, Paint()..color = i == selectedIndex ? _selectedBar : _unselectedBar);
        }
      }

      final labelPainter = TextPainter(
        text: TextSpan(
          text: trends[i].monthLabel,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: i == selectedIndex ? FontWeight.w800 : FontWeight.w600,
            color: (i == selectedIndex ? const Color(0xFF0F172A) : _labelInactive).withValues(alpha: gridAlpha),
            letterSpacing: 0.4,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas, Offset(x - labelPainter.width / 2, chartHeight + 12));
    }

    // Average line + pill.
    final maxRaw = trends.map((e) => e.totalSpent).reduce((a, b) => a > b ? a : b);
    final avgRatio = maxRaw > 0 ? (averageValue / maxRaw) * 0.7 : 0.45;
    final avgY = chartHeight - (chartHeight * avgRatio);

    final lineAlpha = (animationProgress * 1.3).clamp(0.0, 1.0);
    final avgLinePaint = Paint()
      ..color = _avgLine.withValues(alpha: _avgLine.a * lineAlpha)
      ..strokeWidth = 1.2;
    _drawDashedLine(
      canvas,
      Offset(0, avgY),
      Offset(chartWidth * animationProgress.clamp(0.0, 1.0), avgY),
      avgLinePaint,
      dashWidth: 4,
      dashSpace: 4,
    );

    if (animationProgress > 0.4) {
      final pillAlpha = ((animationProgress - 0.4) / 0.6).clamp(0.0, 1.0);
      final avgLabel = averageValue >= 1000 ? 'avg ₹${(averageValue / 1000).toStringAsFixed(1)}K' : 'avg ₹${averageValue.toInt()}';
      final avgPainter = TextPainter(
        text: TextSpan(
          text: avgLabel,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _avgText.withValues(alpha: pillAlpha),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      const padH = 10.0, padV = 4.0;
      final pillW = avgPainter.width + padH * 2;
      final pillH = avgPainter.height + padV * 2;
      final pillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(chartWidth - pillW / 2 - 4, avgY), width: pillW, height: pillH),
        const Radius.circular(4),
      );
      canvas.drawRRect(pillRect, Paint()..color = Colors.white.withValues(alpha: pillAlpha));
      canvas.drawRRect(
        pillRect,
        Paint()
          ..color = _avgLine.withValues(alpha: pillAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      avgPainter.paint(canvas, Offset(pillRect.center.dx - avgPainter.width / 2, pillRect.center.dy - avgPainter.height / 2));
    }

    // Selected-bar tooltip.
    if (selectedIndex < 0 || selectedIndex >= trends.length || animationProgress <= 0.4) return;
    final tooltipAlpha = ((animationProgress - 0.4) / 0.6).clamp(0.0, 1.0);
    final xSelected = (selectedIndex + 0.5) * spacing;
    final barStart = (selectedIndex * 0.05).clamp(0.0, 0.4);
    final barProgress = ((animationProgress - barStart) / (1.0 - barStart)).clamp(0.0, 1.0);
    final barHeightSelected = chartHeight * values[selectedIndex] * barProgress;
    final realVal = trends[selectedIndex].totalSpent;
    final amountStr = realVal >= 1000 ? '₹${(realVal / 1000).toStringAsFixed(1)}K' : '₹${realVal.toInt()}';
    _drawTooltip(canvas, Offset(xSelected, chartHeight - barHeightSelected - 10), amountStr, tooltipAlpha);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, {double dashWidth = 3, double dashSpace = 3}) {
    final distance = (p1 - p2).distance;
    if (distance == 0) return;
    final direction = (p2 - p1) / distance;
    var current = 0.0;
    while (current < distance) {
      canvas.drawLine(p1 + direction * current, p1 + direction * (current + dashWidth), paint);
      current += dashWidth + dashSpace;
    }
  }

  void _drawTooltip(Canvas canvas, Offset position, String text, double alpha) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: alpha),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const padding = 8.0;
    final tw = tp.width + padding * 2;
    final th = tp.height + padding;
    final rect = Rect.fromCenter(center: Offset(position.dx, position.dy - th / 2), width: tw, height: th);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)));

    const tail = 6.0;
    path
      ..moveTo(position.dx - tail, rect.bottom)
      ..lineTo(position.dx, rect.bottom + tail)
      ..lineTo(position.dx + tail, rect.bottom)
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFF0F172A).withValues(alpha: alpha));
    tp.paint(canvas, Offset(rect.left + padding, rect.top + padding / 2));
  }

  @override
  bool shouldRepaint(covariant _SpendTrendsPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.animationProgress != animationProgress ||
      oldDelegate.trends != trends;
}
