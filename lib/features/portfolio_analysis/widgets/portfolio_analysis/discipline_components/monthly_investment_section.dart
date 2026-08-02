import 'package:flutter/material.dart';
import 'generic_info_sheet.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';

class MonthlyInvestmentSection extends StatefulWidget {
  const MonthlyInvestmentSection({super.key});

  @override
  State<MonthlyInvestmentSection> createState() =>
      _MonthlyInvestmentSectionState();
}

class _MonthlyInvestmentSectionState extends State<MonthlyInvestmentSection>
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
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 400), () {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Monthly Net Investment',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
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
                    builder: (context) => const GenericInfoSheet(
                      title: 'What is Monthly Investment?',
                      paragraphs: [
                        'This shows how your net investments have changed month to month over the last 12 months.',
                        'It helps you see whether your investing habit is steady or irregular. Maintaining a stable base contribution supports long-term compounding.',
                      ],
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: const Padding(
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
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '₹4,001',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
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
          const SizedBox(height: 12),
          const Text(
            'Steady investing reduces the impact of\nmarket swings over time.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),

          // The Graph Area
          AspectRatio(
            aspectRatio: 360 / 220,
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
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Pro Tip Section
          Row(
            children: [
              const Text(
                'PRO TIP',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
                children: [
                  TextSpan(
                    text: 'Gaps in investing flow ',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        'your investing rhythm has some breaks. keeping it steady will grow your money faster.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _MonthlyNetInvestmentPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final int hoverIndex;
  final bool isExpanded;

  _MonthlyNetInvestmentPainter({
    required this.progress,
    required this.hoverIndex,
    required this.isExpanded,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 360.0;
    final y0 = size.height * 0.65;
    final paddingX = 36.0 * scale;
    final chartWidth = size.width - paddingX * 2;

    // Background Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
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
      ..color = const Color(0xFF94A3B8)
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
          color: const Color(0xFF94A3B8),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    drawLabel('₹1L', y0 - (80 * scale));
    drawLabel('₹50K', y0 - (40 * scale));
    drawLabel('₹0', y0);
    drawLabel('₹-50K', y0 + (40 * scale));

    // Graph Data Points (Scaled)
    final points = [
      Offset(paddingX + 0 * stepX, y0 - (10 * scale)),
      Offset(paddingX + 1 * stepX, y0 - (50 * scale)),
      Offset(paddingX + 2 * stepX, y0 - (10 * scale)),
      Offset(paddingX + 3 * stepX, y0 - (5 * scale)),
      Offset(paddingX + 4 * stepX, y0 + (30 * scale)),
      Offset(paddingX + 5 * stepX, y0),
      Offset(paddingX + 6 * stepX, y0),
      Offset(paddingX + 7 * stepX, y0),
      Offset(paddingX + 8 * stepX, y0),
    ];

    final labels = [
      "AUG'25",
      "SEP'25",
      "OCT'25",
      "NOV'25",
      "DEC'25",
      "JAN'26",
      "FEB'26",
      "MAR'26",
      "AUG'26",
    ];
    final netValues = [
      "₹10K",
      "₹50K",
      "₹10K",
      "₹5K",
      "₹-30K",
      "₹0",
      "₹0",
      "₹0",
      "₹0",
    ];
    final buyValues = [
      "₹20K",
      "₹50K",
      "₹20K",
      "₹15K",
      "₹0",
      "₹0",
      "₹0",
      "₹0",
      "₹0",
    ];
    final sellValues = [
      "₹10K",
      "₹0",
      "₹10K",
      "₹10K",
      "₹30K",
      "₹0",
      "₹0",
      "₹0",
      "₹0",
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
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    canvas.drawPath(path, linePaint);

    // Draw AVG Pill
    if (progress > 0.8 && hoverIndex == 8 && !isExpanded) {
      final avgPillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(paddingX + 4 * stepX, y0 - (2 * scale)),
          width: 70 * scale,
          height: 20 * scale,
        ),
        Radius.circular(10 * scale),
      );
      final pillPaint = Paint()..color = Colors.white;
      final pillBorderPaint = Paint()
        ..color = const Color(0xFF38A169)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * scale;

      canvas.drawRRect(avgPillRect, pillPaint);
      canvas.drawRRect(avgPillRect, pillBorderPaint);

      textPainter.text = TextSpan(
        text: '₹4K AVG',
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 10 * scale,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF38A169),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (paddingX + 4 * stepX) - textPainter.width / 2,
          y0 - (2 * scale) - textPainter.height / 2,
        ),
      );
    }

    // Draw Bottom Axis Tags Always
    if (progress > 0.9) {
      _drawAxisTag(
        canvas,
        'AUG\'25',
        Offset(paddingX, size.height - (12 * scale)),
        size,
        scale,
      );
      _drawAxisTag(
        canvas,
        'AUG\'26',
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
          ..color = const Color(0xFF94A3B8)
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
          fontSize: 9 * scale,
          fontWeight: FontWeight.w700,
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
        ..strokeWidth = 1.5 * scale,
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
        ..strokeWidth = 1.5 * scale,
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
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: value,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 10 * scale,
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
        fontSize: 9 * scale,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
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
        ..strokeWidth = 1.5 * scale,
    );

    // Title
    textPainter.text = TextSpan(
      text: title,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 9 * scale,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
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
        fontSize: 10 * scale,
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
        ..strokeWidth = 1.5 * scale,
    );
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
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
    final boxWidth = 160.0 * scale;
    final boxHeight = 90.0 * scale;

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
        ..strokeWidth = 1.5 * scale,
    );

    // Bottom shaded section for Net
    final shadedRect = Rect.fromLTWH(
      left,
      top + boxHeight - (28 * scale),
      boxWidth,
      28 * scale,
    );
    canvas.drawRect(shadedRect, Paint()..color = const Color(0xFFF1F5F9));
    // Redraw border over shade
    canvas.drawRRect(rrect, Paint()..color = Colors.transparent);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * scale,
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
        ..strokeWidth = 1.5 * scale,
    );
    canvas.drawPath(
      pPath,
      Paint()
        ..color = const Color(0xFFF1F5F9)
        ..style = PaintingStyle.fill,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawRow(String label, String value, double y, bool boldLabel) {
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 10 * scale,
          fontWeight: boldLabel ? FontWeight.w700 : FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(left + (12 * scale), y));

      textPainter.text = TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 10 * scale,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
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
        fontSize: 9 * scale,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(left + (12 * scale), top + (10 * scale)));

    drawRow('BUY', buy, top + (30 * scale), true);
    drawRow('SELL', sell, top + (46 * scale), true);

    // Net Row with circle icon
    canvas.drawCircle(
      Offset(left + (16 * scale), top + boxHeight - (14 * scale)),
      3 * scale,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(left + (16 * scale), top + boxHeight - (14 * scale)),
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
        fontSize: 10 * scale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(left + (26 * scale), top + boxHeight - (20 * scale)),
    );

    textPainter.text = TextSpan(
      text: net,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 10 * scale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        left + boxWidth - (12 * scale) - textPainter.width,
        top + boxHeight - (20 * scale),
      ),
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint,
    double scale,
  ) {
    final distance = (p2 - p1).distance;
    final direction = (p2 - p1) / distance;
    double dashWidth = 4 * scale;
    double dashSpace = 4 * scale;
    double start = 0;

    while (start < distance) {
      canvas.drawLine(
        p1 + direction * start,
        p1 + direction * math.min(start + dashWidth, distance),
        paint,
      );
      start += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyNetInvestmentPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hoverIndex != hoverIndex ||
        oldDelegate.isExpanded != isExpanded;
  }
}
