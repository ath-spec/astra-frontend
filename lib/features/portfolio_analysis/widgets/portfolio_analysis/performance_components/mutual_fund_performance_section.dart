import 'package:flutter/material.dart';
import 'dart:math' as math;

class MutualFundPerformanceSection extends StatefulWidget {
  const MutualFundPerformanceSection({super.key});

  @override
  State<MutualFundPerformanceSection> createState() => _MutualFundPerformanceSectionState();
}

class _MutualFundPerformanceSectionState extends State<MutualFundPerformanceSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Mutual Fund Performance',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '₹3,45,126',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Breakdown of your mutual fund holdings based on how each fund has performed against its own benchmark.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        const SizedBox(height: 48),
        
        // 3D Chart
        SizedBox(
          height: 240,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _Performance3DBarPainter(progress: _animation.value),
              );
            },
          ),
        ),
        const SizedBox(height: 40),
        
        // List
        const _DottedDivider(),
        _buildFundListItem(
          color: const Color(0xFFE53E3E),
          title: 'Under-performing funds',
          percentage: '0%',
          amount: '₹0',
        ),
        const _DottedDivider(),
        _buildFundListItem(
          color: const Color(0xFF4ADE80), // Light green
          title: 'In line performing funds',
          percentage: '31%',
          amount: '₹1,08,587',
        ),
        const _DottedDivider(),
        _buildFundListItem(
          color: const Color(0xFF16A34A), // Dark green
          title: 'Out-performing funds',
          percentage: '68%',
          amount: '₹2,36,538',
        ),
        
        const SizedBox(height: 24),
        
        // Insights Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INSIGHTS',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 12),
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
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF64748B),
                    ),
                    children: [
                      TextSpan(
                        text: 'Winning streak ',
                        style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: 'most of your funds are ahead of the benchmark. momentum is strong.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildFundListItem({
    required Color color,
    required String title,
    required String percentage,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage of MF portfolio',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _Performance3DBarPainter extends CustomPainter {
  final double progress;

  _Performance3DBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final y0 = size.height - 40;

    // Grid lines (Vertical dotted lines)
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    final numCols = 4;
    final stepX = size.width / numCols;
    for (int i = 0; i <= numCols; i++) {
      final x = i * stepX;
      _drawDashedLine(canvas, Offset(x, 20), Offset(x, y0 + 10), gridPaint);
    }
    
    // Bottom solid line
    canvas.drawLine(Offset(0, y0), Offset(size.width, y0), Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 1);

    final bars = [
      {
        'label': 'UNDER\nPERFORMING',
        'val': 10.0,
        'amt': '₹0',
        'colorFront': const Color(0xFFF56565),
        'colorSide': const Color(0xFFC53030),
        'colorTop': const Color(0xFFFEB2B2),
      },
      {
        'label': 'IN LINE\nPERFORMING',
        'val': 90.0,
        'amt': '₹1.08L',
        'colorFront': const Color(0xFF86EFAC), // Light Green
        'colorSide': const Color(0xFF4ADE80),
        'colorTop': const Color(0xFFBBF7D0),
      },
      {
        'label': 'OUT\nPERFORMING',
        'val': 180.0,
        'amt': '₹2.36L',
        'colorFront': const Color(0xFF22C55E), // Dark Green
        'colorSide': const Color(0xFF16A34A),
        'colorTop': const Color(0xFF86EFAC),
      },
      {
        'label': '',
        'val': 5.0,
        'amt': '₹',
        'colorFront': const Color(0xFFE2E8F0),
        'colorSide': const Color(0xFFCBD5E1),
        'colorTop': const Color(0xFFF1F5F9),
      }
    ];

    final textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    
    final barW = 28.0;
    final depth = 12.0;

    for (int i = 0; i < bars.length; i++) {
      final x = (i * stepX) + (stepX / 2);
      final targetH = bars[i]['val'] as double;
      final currentH = targetH * progress;
      
      // Draw 3D Bar
      final bx = x - (barW / 2);
      final by = y0;
      
      final frontColor = bars[i]['colorFront'] as Color;
      final sideColor = bars[i]['colorSide'] as Color;
      final topColor = bars[i]['colorTop'] as Color;

      // 1. Right Side
      final sidePath = Path()
        ..moveTo(bx + barW, by)
        ..lineTo(bx + barW + depth, by - depth)
        ..lineTo(bx + barW + depth, by - currentH - depth)
        ..lineTo(bx + barW, by - currentH)
        ..close();
      canvas.drawPath(sidePath, Paint()..color = sideColor);
      
      // 2. Top
      final topPath = Path()
        ..moveTo(bx, by - currentH)
        ..lineTo(bx + depth, by - currentH - depth)
        ..lineTo(bx + barW + depth, by - currentH - depth)
        ..lineTo(bx + barW, by - currentH)
        ..close();
      canvas.drawPath(topPath, Paint()..color = topColor);

      // 3. Front
      final frontRect = Rect.fromLTRB(bx, by - currentH, bx + barW, by);
      canvas.drawRect(frontRect, Paint()..color = frontColor);

      // Value label on top
      if (progress > 0.8) {
        textPainter.text = TextSpan(
          text: bars[i]['amt'] as String,
          style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2 + depth / 2, by - currentH - depth - 16));
      }

      // X Axis label
      final label = bars[i]['label'] as String;
      if (label.isNotEmpty) {
        textPainter.text = TextSpan(
          text: label,
          style: const TextStyle(fontFamily: 'DMSans', fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y0 + 16));
      }
    }
  }
  
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final distance = (p2 - p1).distance;
    final direction = (p2 - p1) / distance;
    double dashWidth = 4;
    double dashSpace = 4;
    double start = 0;
    
    while (start < distance) {
      canvas.drawLine(p1 + direction * start, p1 + direction * math.min(start + dashWidth, distance), paint);
      start += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _Performance3DBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DottedLinePainter2(),
    );
  }
}

class _DottedLinePainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    
    double dashWidth = 3;
    double dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
