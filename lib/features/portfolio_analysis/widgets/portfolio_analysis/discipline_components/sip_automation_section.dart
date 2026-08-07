import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/material.dart';
import 'generic_info_sheet.dart';

class SipAutomationSection extends StatefulWidget {
  const SipAutomationSection({super.key});

  @override
  State<SipAutomationSection> createState() => _SipAutomationSectionState();
}

class _SipAutomationSectionState extends State<SipAutomationSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                'SIP Automation',
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
                    builder: (context) => const GenericInfoSheet(
                      title: 'What is SIP Automation?',
                      paragraphs: [
                        'SIP Automation shows what share of your monthly investments is made through automated SIPs.',
                        'A higher automation share reduces missed contributions and limits emotional decision-making.',
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
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '0% ',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextSpan(
                  text: 'of your monthly investments are automated via SIP',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Higher SIP contributions reduces missed\ncontributions and emotional decisions.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              height: 1.5,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.person, size: 16, color: Color(0xFF475569)),
                  SizedBox(width: 8),
                  Text(
                    'You',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '0%',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 20,
                    child: Stack(
                      children: const [
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xFFD6BCFA),
                            child: Icon(
                              Icons.person,
                              size: 12,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xFF9AE6B4),
                            child: Icon(
                              Icons.person,
                              size: 12,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Investors like you',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _AnimatedPercentageBar(percentage: 0.58),
            ],
          ),

          const SizedBox(height: 32),

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  _controller.forward(from: 0);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    _isExpanded ? 'Hide your SIP trend' : 'View your SIP trend',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3182CE),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 14,
                    color: const Color(0xFF3182CE),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_isExpanded
                ? const SizedBox(width: double.infinity, height: 0)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: _DottedLinePainter(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Icon(
                            Icons.bar_chart,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Past 12M trend',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _SipTrendPainter(
                                progress: _animation.value,
                              ),
                            );
                          },
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

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    double dashWidth = 2;
    double dashSpace = 6;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SipTrendPainter extends CustomPainter {
  final double progress;

  _SipTrendPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final y0 = size.height - 40;
    final paddingX = 32.0;
    final chartWidth = size.width - paddingX * 2;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    void drawLabel(String text, double y) {
      textPainter.text = TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    drawLabel('100%', y0 - 100);
    drawLabel('0%', y0);

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final numCols = 8;
    final stepX = chartWidth / numCols;
    for (int i = 0; i <= numCols; i++) {
      final x = paddingX + i * stepX;
      canvas.drawLine(
        Offset(x, y0 - 120),
        Offset(x, size.height - 40),
        gridPaint,
      );
    }

    final zeroPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(paddingX, y0),
      Offset(size.width - paddingX, y0),
      zeroPaint,
    );

    if (progress > 0) {
      final path = Path();
      path.moveTo(paddingX, y0);
      path.lineTo(paddingX + (size.width - paddingX * 2) * progress, y0);
      canvas.drawPath(path, zeroPaint);
    }

    if (progress > 0.8) {
      final endX = size.width - paddingX;

      canvas.drawCircle(
        Offset(endX, y0),
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(endX, y0),
        4,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      final dashPaint = Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      double currentY = y0 - 8;
      final targetY = y0 - 80;
      while (currentY > targetY) {
        canvas.drawLine(
          Offset(endX, currentY),
          Offset(endX, currentY - 3),
          dashPaint,
        );
        currentY -= 6;
      }

      _drawTooltip(canvas, "AUG'26", "0%", Offset(endX, targetY - 4));

      _drawAxisBox(canvas, "SEP'25", Offset(paddingX, size.height - 24));
      _drawAxisBox(
        canvas,
        "AUG'26",
        Offset(size.width - paddingX, size.height - 24),
      );
    }
  }

  void _drawAxisBox(Canvas canvas, String text, Offset center) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: text,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
    );
    textPainter.layout();

    final rect = Rect.fromCenter(
      center: center,
      width: textPainter.width + 16,
      height: 24,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final pPath = Path()
      ..moveTo(center.dx - 4, rect.top)
      ..lineTo(center.dx, rect.top - 4)
      ..lineTo(center.dx + 4, rect.top);
    canvas.drawPath(
      pPath,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  void _drawTooltip(
    Canvas canvas,
    String title,
    String value,
    Offset centerBottom,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: title,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
    textPainter.layout();
    final titleWidth = textPainter.width;

    textPainter.text = TextSpan(
      text: value,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    final valueWidth = textPainter.width;

    final boxWidth = titleWidth + valueWidth + 32;
    final boxHeight = 24.0;

    final rect = Rect.fromLTWH(
      centerBottom.dx - boxWidth + 12,
      centerBottom.dy - boxHeight - 4,
      boxWidth,
      boxHeight,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    textPainter.text = TextSpan(
      text: title,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.left + 8, rect.center.dy - textPainter.height / 2),
    );

    textPainter.text = TextSpan(
      text: value,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.right - textPainter.width - 8,
        rect.center.dy - textPainter.height / 2,
      ),
    );

    final pX = centerBottom.dx;
    final pPath = Path()
      ..moveTo(pX - 4, rect.bottom)
      ..lineTo(pX, rect.bottom + 4)
      ..lineTo(pX + 4, rect.bottom);
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawPath(
      pPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SipTrendPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _AnimatedPercentageBar extends StatefulWidget {
  final double percentage;
  const _AnimatedPercentageBar({required this.percentage});

  @override
  State<_AnimatedPercentageBar> createState() => _AnimatedPercentageBarState();
}

class _AnimatedPercentageBarState extends State<_AnimatedPercentageBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.23, 1.0, 0.32, 1.0),
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
      key: const Key('animated-percentage-bar'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          _isVisible = true;
          _controller.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Proportionally scale width: if 25% = 100px, 58% = 232px
          return Row(
            children: [
              Container(
                height: 8,
                width: 232 * _animation.value,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(widget.percentage * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}