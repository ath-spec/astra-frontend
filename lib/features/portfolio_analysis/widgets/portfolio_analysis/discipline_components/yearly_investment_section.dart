import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'generic_info_sheet.dart';

class YearlyInvestmentSection extends StatefulWidget {
  const YearlyInvestmentSection({super.key});

  @override
  State<YearlyInvestmentSection> createState() =>
      _YearlyInvestmentSectionState();
}

class _YearlyInvestmentSectionState extends State<YearlyInvestmentSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _tappedIndex; // Starts null so no tooltip during animation
  bool _hasAnimated = false;

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

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _tappedIndex ??=
                5; // Select 2025 by default after animation finishes
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('YearlyInvestmentSection'),
      onVisibilityChanged: (info) {
        if (!_hasAnimated && info.visibleFraction >= 0.50) {
          _hasAnimated = true;
          _controller.forward();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Yearly Investment',
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
                        title: 'What is Yearly Investment?',
                        paragraphs: [
                          'This tracks your total investment contributions year over year.',
                          'Consistent yearly growth in your investments indicates strong financial discipline and a commitment to long-term wealth creation.',
                        ],
                      ),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: '₹-33,265 ',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -1.0,
                    ),
                  ),
                  TextSpan(
                    text: 'in 2026 so far',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your annual investment pace compared\nacross recent years.',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            // Chart
            AspectRatio(
              aspectRatio: 360 / 250,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragDown: (details) {
                  final numBars = 7;
                  final stepX = context.size!.width / numBars;
                  final index = (details.localPosition.dx / stepX)
                      .floor()
                      .clamp(0, numBars - 1);
                  setState(() => _tappedIndex = index);
                },
                onHorizontalDragUpdate: (details) {
                  final numBars = 7;
                  final stepX = context.size!.width / numBars;
                  final index = (details.localPosition.dx / stepX)
                      .floor()
                      .clamp(0, numBars - 1);
                  setState(() => _tappedIndex = index);
                },
                onTapDown: (details) {
                  final numBars = 7;
                  final stepX = context.size!.width / numBars;
                  final index = (details.localPosition.dx / stepX)
                      .floor()
                      .clamp(0, numBars - 1);
                  setState(() => _tappedIndex = index);
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _YearlyInvestmentChartPainter(
                        progress: _animation.value,
                        tappedIndex: _tappedIndex,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Pro Tip Label
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 4),
                const Text(
                  'PRO TIP BY ANALYTICS AGENT',
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
                  child: Container(height: 1, color: const Color(0xFFE2E8F0)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Pro Tip Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                      text: 'Momentum is strong ',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text:
                          'your yearly investment pattern shows positive growth trajectory. consistency is building wealth steadily.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _YearlyInvestmentChartPainter extends CustomPainter {
  final double progress;
  final int? tappedIndex;

  _YearlyInvestmentChartPainter({required this.progress, this.tappedIndex});

  String _formatIndianAmount(double value) {
    if (value == 0) return '₹0';
    final isNegative = value < 0;
    final absVal = value.abs();
    String formatted;

    if (absVal >= 10000000) {
      formatted =
          (absVal / 10000000)
              .toStringAsFixed(2)
              .replaceAll(RegExp(r'\.00$'), '') +
          'Cr';
    } else if (absVal >= 100000) {
      formatted =
          (absVal / 100000)
              .toStringAsFixed(2)
              .replaceAll(RegExp(r'\.00$'), '') +
          'L';
    } else if (absVal >= 1000) {
      formatted =
          (absVal / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '') +
          'K';
    } else {
      formatted = absVal.toInt().toString();
    }

    return (isNegative ? '-₹' : '₹') + formatted;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 360.0;
    final y0 = size.height - (40 * scale);
    final baseLine = y0 - (30 * scale);

    // Grid lines (vertical separators)
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;

    final numBars = 7;
    final stepX = size.width / numBars;
    for (int i = 0; i <= numBars; i++) {
      canvas.drawLine(
        Offset(i * stepX, 20 * scale),
        Offset(i * stepX, size.height),
        gridPaint,
      );
    }

    // Horizontal Zero line (solid)
    final zeroPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale;
    canvas.drawLine(
      Offset(0, baseLine),
      Offset(size.width, baseLine),
      zeroPaint,
    );

    final maxVal = 200000.0;
    final maxBarHeight = 120.0 * scale;

    // Horizontal AVG line (dotted green)
    final avgValue = 42570.0;
    final avgY = baseLine - (avgValue / maxVal) * maxBarHeight;

    if (progress > 0.8) {
      final avgPaint = Paint()
        ..color = const Color(0xFF38A169)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * scale;

      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, avgY),
          Offset(startX + (4 * scale), avgY),
          avgPaint,
        );
        startX += 8 * scale;
      }

      // AVG Pill
      final avgPillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, avgY),
          width: 90 * scale,
          height: 22 * scale,
        ),
        Radius.circular(11 * scale),
      );
      canvas.drawRRect(avgPillRect, Paint()..color = Colors.white);
      canvas.drawRRect(
        avgPillRect,
        Paint()
          ..color = const Color(0xFF38A169)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 * scale,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '₹42.57K AVG',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF38A169),
            letterSpacing: 1.0 * scale,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2,
          avgY - textPainter.height / 2,
        ),
      );
    }

    final data = [
      {'year': '2020', 'val': 0.0},
      {'year': '2021', 'val': 0.0},
      {'year': '2022', 'val': 0.0},
      {'year': '2023', 'val': 0.0},
      {'year': '2024', 'val': 100000.0},
      {'year': '2025', 'val': 181275.0},
      {'year': '2026', 'val': -33265.0}, // Hollow negative box
    ];

    final barWidth = 24.0 * scale;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void Function()? drawTooltipAction;

    for (int i = 0; i < numBars; i++) {
      final centerX = (i + 0.5) * stepX;
      final val = data[i]['val'] as double;
      final isNegative = val < 0;
      final isHollow = i == 6; // 2026 is hollow
      final isTapped = tappedIndex == i || (tappedIndex == null && i == 5);

      // STAGGERED PROGRESS Calculation (fills from bottom)
      final staggerStart = i * 0.1;
      final staggerEnd = staggerStart + 0.4;
      double barProgress =
          (progress - staggerStart) / (staggerEnd - staggerStart);
      barProgress = barProgress.clamp(0.0, 1.0);

      final barHeight = (val.abs() / maxVal) * maxBarHeight * barProgress;

      if (barHeight > 0 || isHollow) {
        final rect = isNegative
            ? Rect.fromLTWH(
                centerX - barWidth / 2,
                baseLine,
                barWidth,
                isHollow ? 24 * scale * barProgress : barHeight,
              )
            : Rect.fromLTWH(
                centerX - barWidth / 2,
                baseLine - barHeight,
                barWidth,
                barHeight,
              );

        if (isHollow) {
          canvas.drawRect(
            rect,
            Paint()
              ..color = const Color(0xFF0F172A)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5 * scale,
          );
        } else {
          Color color;
          if (isTapped) {
            color = isNegative ? const Color(0xFFEF4444) : const Color(0xFF1E56D0);
          } else {
            color = const Color(0xFFE2E8F0);
          }
          canvas.drawRect(
            rect,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          );
        }
      }

      // X-Axis Labels (Year and Amount)
      if (progress > 0.8) {
        textPainter.text = TextSpan(
          text: data[i]['year'] as String,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF94A3B8),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(centerX - textPainter.width / 2, y0 + (10 * scale)),
        );

        textPainter.text = TextSpan(
          text: _formatIndianAmount(data[i]['val'] as double),
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 6 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(centerX - textPainter.width / 2, y0 + (24 * scale)),
        );

        // Tooltip for tapped item
        if (isTapped && barProgress > 0.9) {
          final yearStr = data[i]['year'] as String;
          final year = int.parse(yearStr);

          double investment = 0;
          double withdrawal = 0;
          double total = val;

          if (year == 2025) {
            investment = 190199;
            withdrawal = -8923;
            total = 181275;
          } else if (year == 2026) {
            investment = 0;
            withdrawal = -33265;
            total = -33265;
          } else if (year == 2024) {
            investment = 100000;
            withdrawal = 0;
            total = 100000;
          }

          final barTopY = isNegative
              ? baseLine + (isHollow ? 24 * scale : barHeight)
              : baseLine - barHeight;
          final cb = Offset(centerX, barTopY);
          drawTooltipAction = () => _drawTooltip(
            canvas,
            year,
            investment,
            withdrawal,
            total,
            cb,
            scale,
            baseLine,
            maxBarHeight,
            size,
          );
        }
      }
    }

    // Draw tooltip on top of all bars and gridlines
    if (drawTooltipAction != null) {
      drawTooltipAction!();
    }
  }

  void _drawTooltip(
    Canvas canvas,
    int year,
    double investment,
    double withdrawal,
    double total,
    Offset barTop,
    double scale,
    double baseLine,
    double maxBarHeight,
    Size size,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final boxWidth = 160.0 * scale;
    final boxHeight = 94.0 * scale;

    // Fixed tooltip position (tip of the pointer)
    final pointerTipY = baseLine - maxBarHeight - (10 * scale);

    // Draw vertical line connecting tooltip pointer tip to bar top
    canvas.drawLine(
      Offset(barTop.dx, pointerTipY),
      barTop,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 1.0 * scale,
    );

    // Position tooltip to not go offscreen
    double left = barTop.dx - boxWidth / 2;
    if (left < 10 * scale) left = 10 * scale;
    if (left + boxWidth > size.width - (10 * scale))
      left = size.width - boxWidth - (10 * scale);

    final top = pointerTipY - (6 * scale) - boxHeight;
    final rect = Rect.fromLTWH(left, top, boxWidth, boxHeight);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(4 * scale));

    // Draw the kink (pointer) path
    final pPath = Path()
      ..moveTo(barTop.dx - (6 * scale), rect.bottom)
      ..lineTo(barTop.dx, pointerTipY)
      ..lineTo(barTop.dx + (6 * scale), rect.bottom)
      ..close();

    // Combined path for shadow and border
    final combinedPath = Path.combine(
      PathOperation.union,
      Path()..addRRect(rrect),
      pPath,
    );

    // Shadow
    canvas.drawPath(
      combinedPath.shift(Offset(0, 4 * scale)),
      Paint()
        ..color = Colors.black.withOpacity(0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * scale),
    );

    // White background
    canvas.drawRRect(rrect, Paint()..color = Colors.white);

    final isNegative = total < 0;
    final highlightBg = isNegative
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFEBF8FF); // Red 50 or Blue 50

    // Highlight for TOTAL
    final totalRect = Rect.fromLTRB(
      rect.left + (1 * scale),
      rect.bottom - (28 * scale),
      rect.right - (1 * scale),
      rect.bottom - (1 * scale),
    );
    final totalRRect = RRect.fromRectAndCorners(
      totalRect,
      bottomLeft: Radius.circular(3 * scale),
      bottomRight: Radius.circular(3 * scale),
    );
    canvas.drawRRect(totalRRect, Paint()..color = highlightBg);

    // Fill the kink with the highlight background color to merge seamlessly
    canvas.drawPath(
      pPath,
      Paint()
        ..color = highlightBg
        ..style = PaintingStyle.fill,
    );

    // Separator line above TOTAL
    canvas.drawLine(
      Offset(rect.left, totalRect.top),
      Offset(rect.right, totalRect.top),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 0.5 * scale,
    );

    // Border (Seamless)
    canvas.drawPath(
      combinedPath,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 * scale,
    );

    final leftPad = 12.0 * scale;
    final rightPad = 12.0 * scale;

    // Year
    textPainter.text = TextSpan(
      text: '$year',
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 10 * scale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF94A3B8),
        letterSpacing: 1.0 * scale,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.left + leftPad, rect.top + (10 * scale)),
    );

    // INVESTMENT Row
    textPainter.text = TextSpan(
      text: 'INVESTMENT:',
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 9 * scale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
        letterSpacing: 0.5 * scale,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.left + leftPad, rect.top + (32 * scale)),
    );

    textPainter.text = TextSpan(
      text: _formatIndianAmount(investment),
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 9 * scale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.right - rightPad - textPainter.width,
        rect.top + (32 * scale),
      ),
    );

    // WITHDRAWAL Row
    textPainter.text = TextSpan(
      text: 'WITHDRAWAL:',
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 9 * scale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
        letterSpacing: 0.5 * scale,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.left + leftPad, rect.top + (48 * scale)),
    );

    textPainter.text = TextSpan(
      text: _formatIndianAmount(withdrawal),
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 9 * scale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.right - rightPad - textPainter.width,
        rect.top + (48 * scale),
      ),
    );

    // TOTAL Row
    // Color square
    final squareRect = Rect.fromLTWH(
      rect.left + leftPad,
      totalRect.top + (10 * scale),
      6 * scale,
      6 * scale,
    );
    if (isNegative) {
      // Hollow square for negative (matches chart bar)
      canvas.drawRect(
        squareRect,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * scale,
      );
    } else {
      // Filled blue square for positive
      canvas.drawRect(
        squareRect,
        Paint()
          ..color = const Color(0xFF1E56D0)
          ..style = PaintingStyle.fill,
      );
    }

    textPainter.text = TextSpan(
      text: 'TOTAL',
      style: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 10 * scale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
        letterSpacing: 1.0 * scale,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.left + leftPad + (14 * scale), totalRect.top + (7 * scale)),
    );

    textPainter.text = TextSpan(
      text: _formatIndianAmount(total),
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
        rect.right - rightPad - textPainter.width,
        totalRect.top + (7 * scale),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _YearlyInvestmentChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.tappedIndex != tappedIndex;
  }
}
