// ============================================================
// FILE: lib/features/analytics/widgets/focus_level_chart_card.dart
// "Focus level" spend-over-time line chart — geometry ported 1:1
// from zeyro_new_ui's FocusChartPainter/FocusLevelChart (plain ink
// line, dashed gridlines only at label ticks, red peak glow, white
// tooltip with pointer tail, day/date header) re-skinned to astra's
// DMSans typography. Includes the cycle switcher ("the calendar")
// that was missing — This week / This month / This year / Custom,
// via FocusCycleSheet, exactly like zeyro's AnalyticsFilterSheet.
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../data/analytics_repository.dart';
import '../models/analytics_models.dart';

class FocusLevelChartCard extends StatefulWidget {
  final String selectedCycle;
  final DateTime? customFromDate;
  final DateTime? customToDate;

  const FocusLevelChartCard({
    super.key,
    this.selectedCycle = 'This month',
    this.customFromDate,
    this.customToDate,
  });

  @override
  State<FocusLevelChartCard> createState() => _FocusLevelChartCardState();
}

class _FocusLevelChartCardState extends State<FocusLevelChartCard>
    with SingleTickerProviderStateMixin {
  final _repo = AnalyticsRepository.instance;

  List<FocusDataPoint>? _data;
  bool _loading = true;
  int? _hoveredIndex;

  late Timer _timer;
  late DateTime _now;
  late AnimationController _animController;
  late Animation<double> _curvedAnim;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _curvedAnim = CurvedAnimation(
      parent: _animController,
      curve: const Cubic(0.23, 1.0, 0.32, 1.0),
    );
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      final newTime = DateTime.now();
      if (newTime.minute != _now.minute && mounted) setState(() => _now = newTime);
    });
    _load();
  }

  @override
  void didUpdateWidget(covariant FocusLevelChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCycle != widget.selectedCycle ||
        oldWidget.customFromDate != widget.customFromDate ||
        oldWidget.customToDate != widget.customToDate) {
      _load();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final peeked = _repo.peekFocusLevelData(
      cycle: widget.selectedCycle,
      fromDate: widget.customFromDate,
      toDate: widget.customToDate,
    );
    if (peeked != null) {
      setState(() {
        _data = peeked;
        _loading = false;
        _hoveredIndex = _defaultHoverIndex(peeked);
      });
      _animController.forward(from: 0.0);
    } else {
      setState(() => _loading = true);
    }
    final data = await _repo.getFocusLevelData(
      cycle: widget.selectedCycle,
      fromDate: widget.customFromDate,
      toDate: widget.customToDate,
    );
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
      _hoveredIndex = _defaultHoverIndex(data);
    });
    _animController.forward(from: 0.0);
  }

  int _defaultHoverIndex(List<FocusDataPoint> data) {
    if (data.isEmpty) return 0;
    return _getTodayIndex(data).clamp(0, data.length - 1);
  }

  void _updateHover(double localX, double width, int count) {
    if (width == 0 || count == 0) return;
    const leftMargin = 10.0;
    const rightMargin = 50.0;
    final graphWidth = width - leftMargin - rightMargin;

    var closest = -1;
    var minDiff = double.infinity;
    for (var i = 0; i < count; i++) {
      final x = leftMargin + (count > 1 ? (i / (count - 1)) * graphWidth : 0.0);
      final diff = (x - localX).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = i;
      }
    }
    if (closest != _hoveredIndex) setState(() => _hoveredIndex = closest);
  }

  // ── Cycle-aware windowing, ported from zeyro's FocusLevelChart ──

  List<String> _getDisplayLabels(List<FocusDataPoint> data) {
    final cycle = widget.selectedCycle.toLowerCase();
    if (cycle == 'this month') {
      final daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
      if (daysInMonth <= 1) return ['1'];
      return List.generate(6, (i) => ((i * (daysInMonth - 1) / 5).round() + 1).toString());
    } else if (cycle == 'this year') {
      return const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    } else if (cycle == 'custom') {
      if (widget.customFromDate != null && widget.customToDate != null) {
        final duration = widget.customToDate!.difference(widget.customFromDate!).inDays;
        if (duration <= 14) {
          return List.generate(duration + 1, (i) => DateFormat('d').format(widget.customFromDate!.add(Duration(days: i))));
        }
        return List.generate(5, (i) {
          final idx = (i * duration / 4).round();
          return DateFormat('d MMM').format(widget.customFromDate!.add(Duration(days: idx)));
        });
      }
      return const ['Start', 'End'];
    }
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }

  int _getTotalPoints(List<FocusDataPoint> data) {
    final cycle = widget.selectedCycle.toLowerCase();
    if (cycle == 'this month') return DateTime(_now.year, _now.month + 1, 0).day;
    if (cycle == 'this year') return 12;
    if (cycle == 'this week') return 7;
    if (cycle == 'custom' && widget.customFromDate != null && widget.customToDate != null) {
      return widget.customToDate!.difference(widget.customFromDate!).inDays + 1;
    }
    return data.length.clamp(1, 999);
  }

  List<int> _getAxisDataIndices(List<FocusDataPoint> data) {
    final cycle = widget.selectedCycle.toLowerCase();
    final total = _getTotalPoints(data);
    if (cycle == 'this month') return List.generate(6, (i) => (i * (total - 1) / 5).round());
    if (cycle == 'this year') return List.generate(12, (i) => i);
    if (cycle == 'custom') {
      if (total <= 14) return List.generate(total, (i) => i);
      return List.generate(5, (i) => (i * (total - 1) / 4).round());
    }
    return List.generate(total, (i) => i);
  }

  int _getTodayIndex(List<FocusDataPoint> data) {
    final cycle = widget.selectedCycle.toLowerCase();
    final total = _getTotalPoints(data);
    if (cycle == 'this month') return (_now.day - 1).clamp(0, total - 1);
    if (cycle == 'this year') return (_now.month - 1).clamp(0, 11);
    if (cycle == 'this week') return (_now.weekday - 1).clamp(0, 6);
    return total - 1;
  }

  List<String> _getAllDayLabels(List<FocusDataPoint> data) {
    if (widget.selectedCycle.toLowerCase() == 'this year') {
      return const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    }
    return data.map((e) => e.label).toList();
  }

  List<double> _getAllDayData(List<FocusDataPoint> data) {
    final rawData = data.map((e) => e.value).toList();
    if (widget.selectedCycle.toLowerCase() == 'this year' && rawData.length > 20) {
      final monthlyTotals = List.filled(12, 0.0);
      final rawLabels = data.map((e) => e.label.toLowerCase()).toList();
      const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
      for (var i = 0; i < rawData.length; i++) {
        final mIdx = months.indexWhere((m) => rawLabels[i].contains(m));
        if (mIdx != -1) monthlyTotals[mIdx] += rawData[i];
      }
      return monthlyTotals;
    }
    return rawData;
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final currentDay = DateFormat('EEEE').format(_now);
    final currentDateAndTime = DateFormat('d MMM, HH:mm').format(_now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentDay,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.0,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          currentDateAndTime,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: (data == null || data.isEmpty)
              ? Center(child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const SizedBox.shrink())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final allDayData = _getAllDayData(data);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanDown: (d) => _updateHover(d.localPosition.dx, width, allDayData.length),
                      onPanUpdate: (d) => _updateHover(d.localPosition.dx, width, allDayData.length),
                      child: AnimatedBuilder(
                        animation: _curvedAnim,
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(width, 200),
                            painter: _FocusChartPainter(
                              displayLabels: _getDisplayLabels(data),
                              allDayLabels: _getAllDayLabels(data),
                              dataView: allDayData,
                              axisDataIndices: _getAxisDataIndices(data),
                              todayIndex: _getTodayIndex(data),
                              totalPoints: _getTotalPoints(data),
                              hoveredIndex: _hoveredIndex,
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
    );
  }
}

class _FocusChartPainter extends CustomPainter {
  final List<String> displayLabels;
  final List<String> allDayLabels;
  final List<double> dataView;
  final List<int> axisDataIndices;
  final int todayIndex;
  final int totalPoints;
  final int? hoveredIndex;
  final double animationProgress;

  const _FocusChartPainter({
    required this.displayLabels,
    required this.allDayLabels,
    required this.dataView,
    required this.axisDataIndices,
    required this.todayIndex,
    required this.totalPoints,
    this.hoveredIndex,
    this.animationProgress = 1.0,
  });

  static const _ink = Color(0xFF0F172A);
  static const _axisLabel = Color(0xFF94A3B8);
  static const _dash = Color(0x1F0F172A);
  static const _peak = Color(0xFFF43F5E);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataView.isEmpty) return;

    const leftMargin = 10.0;
    const rightMargin = 50.0;
    final graphWidth = size.width - leftMargin - rightMargin;

    final drawCount = dataView.length.clamp(0, totalPoints);
    final lineEnd = todayIndex.clamp(0, drawCount - 1);
    final realData = dataView.sublist(0, lineEnd + 1);

    var maxVal = realData.isEmpty ? 1.0 : realData.reduce((a, b) => a > b ? a : b);
    var minVal = realData.isEmpty ? 0.0 : realData.reduce((a, b) => a < b ? a : b);
    if (maxVal == minVal || (maxVal - minVal) < (maxVal * 0.05)) {
      minVal = 0;
      maxVal = maxVal == 0 ? 1000 : maxVal * 1.5;
    } else {
      maxVal *= 1.15;
      minVal = (minVal > 0 && minVal < maxVal * 0.1) ? 0 : minVal * 0.9;
    }

    final points = <Offset>[];
    final actualTotal = totalPoints > 1 ? totalPoints : 2;
    for (var i = 0; i < drawCount; i++) {
      final x = leftMargin + (i / (actualTotal - 1)) * graphWidth;
      final normalized = (dataView[i] - minVal) / (maxVal - minVal);
      final yRatio = 0.85 - (normalized.clamp(0.0, 1.0) * 0.70);
      points.add(Offset(x, yRatio * size.height));
    }

    final gridAlpha = (animationProgress * 1.4).clamp(0.0, 1.0);
    final dashedPaint = Paint()
      ..color = _dash.withValues(alpha: _dash.a * gridAlpha)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < displayLabels.length && i < axisDataIndices.length; i++) {
      final dataIdx = axisDataIndices[i];
      final x = leftMargin + (dataIdx / (actualTotal - 1)) * graphWidth;

      final tp = TextPainter(
        text: TextSpan(
          text: displayLabels[i],
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            color: _axisLabel.withValues(alpha: _axisLabel.a * gridAlpha),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 26));

      var dY = 0.0;
      const dashHeight = 4.0;
      const dashSpace = 4.0;
      while (dY < size.height - 36) {
        canvas.drawLine(Offset(x, dY), Offset(x, dY + dashHeight), dashedPaint);
        dY += dashHeight + dashSpace;
      }
    }

    // Y-axis labels.
    final yVals = [maxVal, minVal + (maxVal - minVal) * 0.66, minVal + (maxVal - minVal) * 0.33, minVal];
    const yRatios = [0.15, 0.383, 0.616, 0.85];
    for (var i = 0; i < yVals.length; i++) {
      final v = yVals[i].toInt();
      final label = v >= 1000 ? '${(v / 1000).toStringAsFixed(1).replaceAll('.0', '')}k' : v.toString();
      final tp = TextPainter(
        text: TextSpan(
          text: '₹$label',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            color: _axisLabel.withValues(alpha: _axisLabel.a * gridAlpha),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width, size.height * yRatios[i] - tp.height / 2));
    }

    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = _ink
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fullPath = Path();
    final drawUntil = (lineEnd + 1).clamp(1, points.length);
    for (var i = 0; i < drawUntil; i++) {
      if (i == 0) {
        fullPath.moveTo(points[i].dx, points[i].dy);
      } else {
        fullPath.lineTo(points[i].dx, points[i].dy);
      }
    }

    // Draw progressive path metrics animation
    final animatedPath = Path();
    for (final metric in fullPath.computeMetrics()) {
      final extractLen = metric.length * animationProgress.clamp(0.0, 1.0);
      animatedPath.addPath(metric.extractPath(0.0, extractLen), Offset.zero);
    }
    canvas.drawPath(animatedPath, linePaint);

    var peakIndex = 0;
    var currentMax = realData.isNotEmpty ? realData[0] : 0.0;
    for (var i = 1; i <= lineEnd; i++) {
      if (dataView[i] > currentMax) {
        currentMax = dataView[i];
        peakIndex = i;
      }
    }
    if (peakIndex < points.length) {
      final peakPosRatio = lineEnd > 0 ? (peakIndex / lineEnd) : 0.0;
      if (animationProgress >= peakPosRatio) {
        final glowProgress = ((animationProgress - peakPosRatio) / (1.0 - peakPosRatio + 0.001)).clamp(0.0, 1.0);
        final pp = points[peakIndex];
        canvas.drawCircle(
          pp,
          10 * glowProgress,
          Paint()
            ..color = _peak.withValues(alpha: 0.5 * glowProgress)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        canvas.drawCircle(
          pp,
          6 * glowProgress,
          Paint()
            ..color = _peak.withValues(alpha: 0.6 * glowProgress)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    if (hoveredIndex != null && hoveredIndex! < points.length && animationProgress > 0.4) {
      final tooltipAlpha = ((animationProgress - 0.4) / 0.6).clamp(0.0, 1.0);
      final pt = points[hoveredIndex!];
      final val = dataView[hoveredIndex!];
      const tw = 85.0;
      const th = 34.0;
      const ph = 5.0;
      const pw = 8.0;
      const sy = -35.0;
      final sx = (pt.dx - tw / 2).clamp(0.0, size.width - tw);

      canvas.drawLine(
        Offset(pt.dx, sy + th + ph),
        Offset(pt.dx, size.height - 40),
        Paint()..color = _ink.withValues(alpha: _ink.a * tooltipAlpha)..strokeWidth = 1.0,
      );
      canvas.drawCircle(pt, 4, Paint()..color = _ink.withValues(alpha: _ink.a * tooltipAlpha));
      canvas.drawCircle(pt, 2.5, Paint()..color = Colors.white.withValues(alpha: tooltipAlpha));

      final boxPath = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(sx, sy, tw, th), const Radius.circular(4)));
      final al = (pt.dx - pw / 2).clamp(sx + 4, sx + tw - 4 - pw);
      boxPath
        ..moveTo(al, sy + th)
        ..lineTo(pt.dx, sy + th + ph)
        ..lineTo(al + pw, sy + th);

      canvas.drawShadow(boxPath, Colors.black.withValues(alpha: 0.35 * tooltipAlpha), 3, true);
      canvas.drawPath(boxPath, Paint()..color = Colors.white.withValues(alpha: tooltipAlpha)..style = PaintingStyle.fill);
      canvas.drawPath(boxPath, Paint()..color = _ink.withValues(alpha: _ink.a * tooltipAlpha)..style = PaintingStyle.stroke..strokeWidth = 0.7);

      final labelTp = TextPainter(
        text: TextSpan(
          text: 'spent on',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: _ink.withValues(alpha: 0.55 * tooltipAlpha),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(canvas, Offset(sx + 5, sy + 4));

      final dateStr = hoveredIndex! < allDayLabels.length ? allDayLabels[hoveredIndex!] : '';
      final dateTp = TextPainter(
        text: TextSpan(
          text: dateStr,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: _ink.withValues(alpha: _ink.a * tooltipAlpha),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dateTp.paint(canvas, Offset(sx + 5, sy + 15));

      final amountStr = val >= 1000 ? '₹${(val / 1000).toStringAsFixed(2)}k' : '₹${val.toStringAsFixed(0)}';
      final amountTp = TextPainter(
        text: TextSpan(
          text: amountStr,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: _ink.withValues(alpha: _ink.a * tooltipAlpha),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      amountTp.paint(canvas, Offset(sx + tw - 5 - amountTp.width, sy + 15));
    }
  }

  @override
  bool shouldRepaint(covariant _FocusChartPainter oldDelegate) =>
      oldDelegate.animationProgress != animationProgress ||
      oldDelegate.hoveredIndex != hoveredIndex ||
      oldDelegate.dataView != dataView;
}
