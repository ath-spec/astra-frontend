import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'generic_info_sheet.dart';
import '../../../../../core/widgets/animated_gradient_text.dart';
import '../../../../../core/widgets/typewriter_text.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/portfolio_analysis_providers.dart';
import '../../../data/portfolio_analysis_models.dart';
import 'dart:math' as math;
import 'dart:async';

/// Compact ₹ formatter used for chart labels (e.g. ₹50K, ₹1.2L, ₹-30K).
String _fmtCompact(double v) {
  final neg = v < 0;
  final a = v.abs();
  String s;
  if (a >= 10000000) {
    s = '${(a / 10000000).toStringAsFixed(a % 10000000 == 0 ? 0 : 1)}Cr';
  } else if (a >= 100000) {
    s = '${(a / 100000).toStringAsFixed(a % 100000 == 0 ? 0 : 1)}L';
  } else if (a >= 1000) {
    s = '${(a / 1000).toStringAsFixed(a % 1000 == 0 ? 0 : 1)}K';
  } else {
    s = a.round().toString();
  }
  return '${neg ? '₹-' : '₹'}$s';
}

/// Rounds [maxAbs] up to a friendly axis step (so the 40px grid unit maps to a
/// clean number).
double _niceStep(double maxAbs) {
  if (maxAbs <= 0) return 50000;
  const candidates = <double>[
    1000, 2000, 2500, 5000, 10000, 20000, 25000, 50000,
    100000, 200000, 250000, 500000, 1000000, 2000000, 5000000
  ];
  for (final c in candidates) {
    if (maxAbs <= c * 2) return c;
  }
  return maxAbs / 2;
}

class MonthlyInvestmentSection extends ConsumerStatefulWidget {
  const MonthlyInvestmentSection({super.key});

  @override
  ConsumerState<MonthlyInvestmentSection> createState() =>
      _MonthlyInvestmentSectionState();
}

class _MonthlyInvestmentSectionState
    extends ConsumerState<MonthlyInvestmentSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _hoverIndex = 8;
  bool _isExpanded = false;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleTouch(Offset localPosition, double totalWidth) {
    if (localPosition.dx < 0 || localPosition.dx > totalWidth) return;

    final paddingX = 36.0;
    final chartWidth = totalWidth - paddingX * 2;
    final numCols = 8;
    final stepX = chartWidth / numCols;

    double adjX = localPosition.dx - paddingX;
    if (adjX < 0) adjX = 0;
    if (adjX > chartWidth) adjX = chartWidth;

    final int index = (adjX / stepX).round().clamp(0, 8);

    if (_hoverIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _hoverIndex = index;
        _isExpanded = true;
      });
    } else if (!_isExpanded) {
      setState(() {
        _isExpanded = true;
      });
    }
  }

  void _handleTouchEnd() {
    _holdTimer?.cancel(); // In case any exist from older code
    setState(() {
      _isExpanded = false;
      _hoverIndex = 8;
    });
  }

  String _fmtInrFull(double value) {
    final rounded = value.round();
    final neg = rounded < 0;
    final digits = rounded.abs().toString();
    String out;
    if (digits.length <= 3) {
      out = digits;
    } else {
      final head = digits.substring(0, digits.length - 3);
      final tail = digits.substring(digits.length - 3);
      out =
          '${head.replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+(?!\d))'), (m) => '${m[1]},')},$tail';
    }
    return '${neg ? '-₹' : '₹'}$out';
  }

  @override
  Widget build(BuildContext context) {
    final discAsync = ref.watch(portfolioDisciplineProvider);
    final disc = discAsync.value;

    if (disc == null) {
      return discAsync.isLoading
          ? const _MonthlyInvestmentSkeleton()
          : const SizedBox.shrink();
    }

    // Chart shows the most recent 9 months (8 columns).
    final full = disc.monthlyHistory;
    final months =
        full.length > 9 ? full.sublist(full.length - 9) : full;
    final proTip = disc.missedMonths > 0
        ? 'Gaps in investing flow your investing rhythm has some breaks. keeping it steady will grow your money faster.'
        : 'Steady rhythm your contributions have been consistent month after month. keep it going.';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Monthly Net Investment',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => GenericInfoSheet(
                      title: 'What is Monthly Investment?',
                      paragraphs: [
                        'This shows how your net investments have changed month to month over the last 12 months.',
                        'It helps you see whether your investing habit is steady or irregular. Maintaining a stable base contribution supports long-term compounding.',
                      ],
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _fmtInrFull(disc.avgMonthlyInvested),
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'average invested per month',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          Text(
            'Steady investing reduces the impact of\nmarket swings over time.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),

          // The Graph Area
          AspectRatio(
            aspectRatio: 360 / 200,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragDown: (details) =>
                  _handleTouch(details.localPosition, context.size!.width),
              onHorizontalDragUpdate: (details) =>
                  _handleTouch(details.localPosition, context.size!.width),
              onHorizontalDragEnd: (_) => _handleTouchEnd(),
              onHorizontalDragCancel: () => _handleTouchEnd(),
              onTapDown: (details) =>
                  _handleTouch(details.localPosition, context.size!.width),
              onTapUp: (_) => _handleTouchEnd(),
              onTapCancel: () => _handleTouchEnd(),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _MonthlyNetInvestmentPainter(
                      progress: _animation.value,
                      hoverIndex: _hoverIndex,
                      isExpanded: _isExpanded,
                      months: months,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: 32),

          // Pro Tip Section
          Row(
            children: [
              AnimatedGradientShimmer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'PRO TIP BY BEHAVIOUR AGENT',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedGradientShimmer(
              child: TypewriterText(
                text: proTip,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyNetInvestmentPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final int hoverIndex;
  final bool isExpanded;
  final List<MonthlyInvestmentData> months;

  _MonthlyNetInvestmentPainter({
    required this.progress,
    required this.hoverIndex,
    required this.isExpanded,
    required this.months,
  });

  static String _ymLabel(String ym) {
    final parts = ym.split('-');
    if (parts.length < 2) return ym;
    const abbr = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final m = (int.tryParse(parts[1]) ?? 1).clamp(1, 12) - 1;
    final yy = parts[0].length >= 2 ? parts[0].substring(parts[0].length - 2) : parts[0];
    return "${abbr[m]}'$yy";
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 360.0;
    final textScale = math.max(scale, 0.85);
    // Adjust y0 to shift graph up, creating more space for labels below
    final y0 = size.height * 0.55;
    final paddingX = 36.0 * scale;
    final chartWidth = size.width - paddingX * 2;

    // Background Grid lines
    final gridPaint = Paint()
      ..color = Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;

    final numCols = 8;
    final stepX = chartWidth / numCols;
    for (int i = 0; i <= numCols; i++) {
      final x = paddingX + i * stepX;
      canvas.drawLine(
        Offset(x, 20 * scale),
        Offset(x, size.height - (20 * scale)),
        gridPaint,
      );
    }

    // Zero Baseline (Dotted)
    final zeroPaint = Paint()
      ..color = Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;
    _drawDashedLine(
      canvas,
      Offset(paddingX, y0),
      Offset(size.width - paddingX, y0),
      zeroPaint,
      scale,
    );

    // Y Axis Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawLabel(String text, double y) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 10 * scale,
          color: Color(0xFF94A3B8),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // Y axis step: 40px grid unit maps to a friendly rounded value derived
    // from the largest monthly net figure in the window.
    double maxAbsNet = 0;
    for (final m in months) {
      final a = m.netAmount.abs();
      if (a > maxAbsNet) maxAbsNet = a;
    }
    final step = _niceStep(maxAbsNet);

    drawLabel(_fmtCompact(step * 2), y0 - (80 * scale));
    drawLabel(_fmtCompact(step), y0 - (40 * scale));
    drawLabel('₹0', y0);
    drawLabel(_fmtCompact(-step), y0 + (40 * scale));

    // Graph Data Points (from live monthly net, mapped onto the 40px/step grid)
    double netAt(int i) => i < months.length ? months[i].netAmount : 0.0;
    double buyAt(int i) => i < months.length ? months[i].buyAmount : 0.0;
    double sellAt(int i) => i < months.length ? months[i].sellAmount : 0.0;

    final points = [
      for (int i = 0; i <= 8; i++)
        Offset(paddingX + i * stepX, y0 - (netAt(i) / step) * 40 * scale),
    ];

    final labels = [
      for (int i = 0; i <= 8; i++)
        i < months.length ? _ymLabel(months[i].yearMonth) : '',
    ];
    final netValues = [
      for (int i = 0; i <= 8; i++) _fmtCompact(netAt(i)),
    ];
    final buyValues = [
      for (int i = 0; i <= 8; i++) _fmtCompact(buyAt(i)),
    ];
    final sellValues = [
      for (int i = 0; i <= 8; i++) _fmtCompact(sellAt(i)),
    ];

    if (progress == 0) return;

    final path = Path();
    path.moveTo(points.first.dx, y0 + (points.first.dy - y0) * progress);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, y0 + (points[i].dy - y0) * progress);
    }

    // Draw shaded area
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, y0)
      ..lineTo(points.first.dx, y0)
      ..close();

    final fillPaint = Paint()
      ..color = Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;
    canvas.drawPath(path, linePaint);

    // Draw AVG Pill and Line
    if (progress > 0.8 && hoverIndex == 8 && !isExpanded) {
      final avgLinePaint = Paint()
        ..color = const Color(0xFF38A169)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.5 * scale;
      _drawDashedLine(
        canvas,
        Offset(paddingX, y0 - (4 * scale)),
        Offset(size.width - paddingX, y0 - (4 * scale)),
        avgLinePaint,
        scale,
        dashWidth: 0.1 * scale,
        dashSpace: 3.5 * scale,
      );

      textPainter.text = TextSpan(
        text:
            '${_fmtCompact(months.isEmpty ? 0 : months.map((m) => m.netAmount).reduce((a, b) => a + b) / months.length)} AVG',
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 8 * textScale,
          fontWeight: FontWeight.w600,
          color: Color(0xFF38A169),
        ),
      );
      textPainter.layout();

      final pillWidth = textPainter.width + (16 * textScale);
      final pillHeight = textPainter.height + (8 * textScale);

      final avgPillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(paddingX + 4 * stepX, y0 - (4 * scale)),
          width: pillWidth,
          height: pillHeight,
        ),
        Radius.circular(pillHeight / 2),
      );
      
      final pillPaint = Paint()..color = Colors.white;
      final pillBorderPaint = Paint()
        ..color = Color(0xFF38A169)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * scale;

      canvas.drawRRect(avgPillRect, pillPaint);
      canvas.drawRRect(avgPillRect, pillBorderPaint);

      textPainter.paint(
        canvas,
        Offset(
          (paddingX + 4 * stepX) - textPainter.width / 2,
          y0 - (4 * scale) - textPainter.height / 2,
        ),
      );
    }

    // Draw Bottom Axis Tags Always
    if (progress > 0.9) {
      _drawAxisTag(
        canvas,
        labels.first,
        Offset(paddingX, size.height - (12 * scale)),
        size,
        scale,
      );
      _drawAxisTag(
        canvas,
        months.isEmpty ? '' : _ymLabel(months.last.yearMonth),
        Offset(paddingX + 8 * stepX, size.height - (12 * scale)),
        size,
        scale,
      );

      // Hover View
      final pt = points[hoverIndex];

      final tooltipBaseY = 40.0 * scale;
      final tooltipPoint = Offset(pt.dx, tooltipBaseY);

      // Vertical line
      canvas.drawLine(
        Offset(pt.dx, tooltipBaseY),
        Offset(pt.dx, size.height - (20 * scale)),
        Paint()
          ..color = Color(0xFF94A3B8)
          ..strokeWidth = 1 * scale,
      );

      // Dot on graph
      canvas.drawCircle(pt, 5 * scale, Paint()..color = Colors.white);
      canvas.drawCircle(
        pt,
        5 * scale,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * scale,
      );

      if (isExpanded) {
        _drawExpandedTooltip(
          canvas,
          labels[hoverIndex],
          buyValues[hoverIndex],
          sellValues[hoverIndex],
          netValues[hoverIndex],
          tooltipPoint,
          size,
          scale,
        );
      } else {
        _drawValueTooltip(
          canvas,
          labels[hoverIndex],
          '${netValues[hoverIndex]} >',
          tooltipPoint,
          size,
          scale,
        );
      }
    }
  }

  void _drawAxisTag(
    Canvas canvas,
    String text,
    Offset center,
    Size size,
    double scale,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 8 * scale,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final boxWidth = textPainter.width + (16 * scale);
    final boxHeight = 20.0 * scale;

    double left = center.dx - boxWidth / 2;
    if (left < 0) left = 0;
    if (left + boxWidth > size.width) left = size.width - boxWidth;

    final rect = Rect.fromLTWH(
      left,
      center.dy - boxHeight / 2,
      boxWidth,
      boxHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(4 * scale)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(4 * scale)),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * scale,
    );

    // Draw upward pointer
    final pointerX = center.dx;
    final pointerY = rect.top;
    final pPath = Path()
      ..moveTo(pointerX - (4 * scale), pointerY)
      ..lineTo(pointerX, pointerY - (4 * scale))
      ..lineTo(pointerX + (4 * scale), pointerY);

    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * scale,
    );
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawValueTooltip(
    Canvas canvas,
    String title,
    String value,
    Offset point,
    Size size,
    double scale,
  ) {
    canvas.save();
    
    // Clamp the effective scale so it never drops below 0.85
    final effectiveScale = math.max(scale * 0.75, 0.85);
    final tooltipScale = effectiveScale / scale;
    
    canvas.translate(point.dx, point.dy);
    canvas.scale(tooltipScale, tooltipScale);
    canvas.translate(-point.dx, -point.dy);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: value,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 8.5 * scale,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    final valueWidth = textPainter.width;

    textPainter.text = TextSpan(
      text: title,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 7.5 * scale,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
    textPainter.layout();
    final titleWidth = textPainter.width;

    final boxWidth = titleWidth + valueWidth + (24 * scale);

    // Position tooltip to not go offscreen
    double left = point.dx - boxWidth / 2;
    if (left < 0) left = 0;
    if (left + boxWidth > size.width) left = size.width - boxWidth;

    final top = point.dy - (35 * scale);
    final rect = Rect.fromLTWH(left, top, boxWidth, 24 * scale);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(4 * scale));

    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * scale,
    );

    // Title
    textPainter.text = TextSpan(
      text: title,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 7.5 * scale,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.left + (8 * scale), rect.center.dy - textPainter.height / 2),
    );

    // Value
    textPainter.text = TextSpan(
      text: value,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 8.5 * scale,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.right - textPainter.width - (8 * scale),
        rect.center.dy - textPainter.height / 2,
      ),
    );

    // Pointer
    final pPath = Path()
      ..moveTo(point.dx - (6 * scale), rect.bottom)
      ..lineTo(point.dx, rect.bottom + (6 * scale))
      ..lineTo(point.dx + (6 * scale), rect.bottom);
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * scale,
    );
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  void _drawExpandedTooltip(
    Canvas canvas,
    String title,
    String buy,
    String sell,
    String net,
    Offset point,
    Size size,
    double scale,
  ) {
    canvas.save();
    
    // Clamp the effective scale so it never drops below 0.85
    final effectiveScale = math.max(scale * 0.75, 0.85);
    final tooltipScale = effectiveScale / scale;
    
    canvas.translate(point.dx, point.dy);
    canvas.scale(tooltipScale, tooltipScale);
    canvas.translate(-point.dx, -point.dy);

    final boxWidth = 145.0 * scale;
    final boxHeight = 68.0 * scale;

    double left = point.dx - boxWidth / 2;
    if (left < 0) left = 0;
    if (left + boxWidth > size.width) left = size.width - boxWidth;

    final top = point.dy - boxHeight - (10 * scale);
    final rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(4 * scale));

    // Background and border
    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * scale,
    );

    // Bottom shaded section for Net
    final shadedRect = Rect.fromLTWH(
      left,
      top + boxHeight - (20 * scale),
      boxWidth,
      20 * scale,
    );
    canvas.drawRect(shadedRect, Paint()..color = Color(0xFFF1F5F9));
    // Redraw border over shade
    canvas.drawRRect(rrect, Paint()..color = Colors.transparent);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * scale,
    );

    // Pointer
    final pPath = Path()
      ..moveTo(point.dx - (6 * scale), rect.bottom)
      ..lineTo(point.dx, rect.bottom + (6 * scale))
      ..lineTo(point.dx + (6 * scale), rect.bottom);
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * scale,
    );
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Color(0xFFF1F5F9)
        ..style = PaintingStyle.fill,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawRow(String label, String value, double y, bool boldLabel) {
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 8.5 * scale,
          fontWeight: boldLabel ? FontWeight.w700 : FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(left + (12 * scale), y));

      textPainter.text = TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 8.5 * scale,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(left + boxWidth - (12 * scale) - textPainter.width, y),
      );
    }

    // Title
    textPainter.text = TextSpan(
      text: title,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 7.5 * scale,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(left + (12 * scale), top + (6 * scale)));

    drawRow('BUY', buy, top + (22 * scale), true);
    drawRow('SELL', sell, top + (34 * scale), true);

    // Net Row with circle icon
    canvas.drawCircle(
      Offset(left + (16 * scale), top + boxHeight - (10 * scale)),
      3 * scale,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(left + (16 * scale), top + boxHeight - (10 * scale)),
      3 * scale,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale,
    );

    textPainter.text = TextSpan(
      text: 'NET',
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 8.5 * scale,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(left + (26 * scale), top + boxHeight - (16 * scale)),
    );

    textPainter.text = TextSpan(
      text: net,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 8.5 * scale,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        left + boxWidth - (12 * scale) - textPainter.width,
        top + boxHeight - (16 * scale),
      ),
    );

    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, double scale, {double? dashWidth, double? dashSpace}) {
    final distance = (p2 - p1).distance;
    final direction = (p2 - p1) / distance;
    double w = dashWidth ?? (4 * scale);
    double s = dashSpace ?? (4 * scale);
    double start = 0;
    
    while (start < distance) {
      canvas.drawLine(p1 + direction * start, p1 + direction * math.min(start + w, distance), paint);
      start += w + s;
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyNetInvestmentPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hoverIndex != hoverIndex ||
        oldDelegate.isExpanded != isExpanded ||
        !identical(oldDelegate.months, months);
  }
}

/// Loading placeholder for [MonthlyInvestmentSection] — header + chart-area
/// shimmer so no fabricated figures are shown while data loads.
class _MonthlyInvestmentSkeleton extends StatelessWidget {
  const _MonthlyInvestmentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBar(width: 200, height: 20),
          const SizedBox(height: 16),
          const ShimmerBar(width: 150, height: 22),
          const SizedBox(height: 12),
          const ShimmerBar(width: 220, height: 12),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 360 / 200,
            child: ShimmerBar(
              width: MediaQuery.of(context).size.width,
              height: 200,
              borderRadius: 8,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
