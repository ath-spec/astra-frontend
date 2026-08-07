import 'package:flutter/material.dart';
import '../../../../../core/widgets/animated_gradient_text.dart';
import '../../../../../core/widgets/typewriter_text.dart';
import 'package:flutter/physics.dart';
import 'dart:math' as math;
import 'package:visibility_detector/visibility_detector.dart';
import 'mutual_fund_performance_sheet.dart';

class MutualFundPerformanceSection extends StatefulWidget {
  const MutualFundPerformanceSection({super.key});

  @override
  State<MutualFundPerformanceSection> createState() =>
      _MutualFundPerformanceSectionState();
}

class _MutualFundPerformanceSectionState
    extends State<MutualFundPerformanceSection> {
  final GlobalKey _chartKey = GlobalKey();
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollable = Scrollable.maybeOf(context);
    if (_scrollPosition != scrollable?.position) {
      _scrollPosition = scrollable?.position;
    }
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '₹3,45,126',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 24,
            fontWeight: FontWeight.w600,
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
              fontSize: 10,
              height: 1.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        const SizedBox(height: 48),

        // 3D Chart with True Scrollytelling
        SizedBox(
          key: _chartKey,
          height: 240,
          width: double.infinity,
          child: GestureDetector(
            onTapUp: (details) {
              final width = MediaQuery.of(context).size.width;
              final dx = details.localPosition.dx;
              final sectionWidth = width / 4;
              int tabIndex = 0; // Default to out-performing
              if (dx < sectionWidth) {
                tabIndex = 2; // Under-performing
              } else if (dx < sectionWidth * 2) {
                tabIndex = 1; // In line
              } else if (dx < sectionWidth * 3) {
                tabIndex = 0; // Out-performing
              } else {
                tabIndex = 3; // Unrated
              }

              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) =>
                    MutualFundPerformanceSheet(initialIndex: tabIndex),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _scrollPosition ?? const AlwaysStoppedAnimation(0.0),
              builder: (context, child) {
                double progress = 1.0;
                
                if (_chartKey.currentContext != null && _scrollPosition != null) {
                  try {
                    final RenderBox renderBox = _chartKey.currentContext!.findRenderObject() as RenderBox;
                    final position = renderBox.localToGlobal(Offset.zero).dy;
                    final screenHeight = MediaQuery.of(context).size.height;
                    
                    // Scrollytelling mapping:
                    // Start animating when the top of the chart reaches 80% down the screen
                    // Finish animating when the top of the chart reaches 40% down the screen
                    final startY = screenHeight * 0.8;
                    final endY = screenHeight * 0.4;
                    
                    progress = (startY - position) / (startY - endY);
                    
                    // Add a tiny bit of non-linear easing for polish (Framer Motion feel)
                    progress = progress.clamp(0.0, 1.0);
                    progress = Curves.easeOutCubic.transform(progress);
                  } catch (e) {
                    // Fallback during initial layout phase
                    progress = 0.0;
                  }
                }

                return CustomPaint(
                  painter: _Performance3DBarPainter(
                    progress: progress,
                  ),
                );
              },
            ),
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
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) =>
                  const MutualFundPerformanceSheet(initialIndex: 2),
            );
          },
        ),
        const _DottedDivider(),
        _buildFundListItem(
          color: const Color(0xFF4ADE80), // Light green
          title: 'In line performing funds',
          percentage: '31%',
          amount: '₹1,08,587',
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) =>
                  const MutualFundPerformanceSheet(initialIndex: 1),
            );
          },
        ),
        const _DottedDivider(),
        _buildFundListItem(
          color: const Color(0xFF16A34A), // Dark green
          title: 'Out-performing funds',
          percentage: '68%',
          amount: '₹2,36,538',
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) =>
                  const MutualFundPerformanceSheet(initialIndex: 0),
            );
          },
        ),

        const SizedBox(height: 24),

        // Insights Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedGradientShimmer(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'INSIGHTS BY ANALYTICS AGENT',
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
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFE2E8F0),
                      thickness: 1,
                      height: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TypewriterText(
                  text: 'Winning streak most of your funds are ahead of the benchmark. momentum is strong.',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    height: 1.5,
                    color: Color(0xFF64748B),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage of MF portfolio',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 12, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _Performance3DBarPainter extends CustomPainter {
  final double progress;

  _Performance3DBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final y0 = size.height - 44;

    final numCols = 4;
    final stepX = size.width / numCols;

    // Subtle vertical dashed grid — very light, like the reference image
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i <= numCols; i++) {
      final x = i * stepX;
      _drawDashedLine(canvas, Offset(x, 0), Offset(x, y0 + 2), gridPaint);
    }

    // Clean bottom baseline
    canvas.drawLine(
      Offset(0, y0),
      Offset(size.width, y0),
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 1.2,
    );

    final bars = [
      {
        'label': 'UNDER\nPERFORMING',
        'val': 10.0,
        'amt': '₹0',
        'colorFront': const Color(0xFFF87171),
        'colorSide': const Color(0xFFEF4444),
        'colorTop': const Color(0xFFFCA5A5),
      },
      {
        'label': 'IN LINE\nPERFORMING',
        'val': 90.0,
        'amt': '₹1.08L',
        'colorFront': const Color(0xFF86EFAC),
        'colorSide': const Color(0xFF22C55E),
        'colorTop': const Color(0xFFBBF7D0),
      },
      {
        'label': 'OUT\nPERFORMING',
        'val': 180.0,
        'amt': '₹2.36L',
        'colorFront': const Color(0xFF4ADE80),
        'colorSide': const Color(0xFF16A34A),
        'colorTop': const Color(0xFF86EFAC),
      },
      {
        'label': '',
        'val': 5.0,
        'amt': '',
        'colorFront': const Color(0xFFE2E8F0),
        'colorSide': const Color(0xFFCBD5E1),
        'colorTop': const Color(0xFFF1F5F9),
      },
    ];

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Wider bars for more visual presence, refined slimmer depth
    final barW = math.max(28.0, size.width * 0.10);
    final depthX = barW * 0.18;   // Much slimmer horizontal side face
    final depthY = barW * 0.24;   // Steeper vertical angle for a sharper isometric look

    final maxAvailableHeight = size.height * 0.68;

    double maxVal = 0;
    for (var bar in bars) {
      final v = bar['val'] as double;
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0) maxVal = 1;

    for (int i = 0; i < bars.length; i++) {
      final x = (i * stepX) + (stepX / 2);
      final rawVal = bars[i]['val'] as double;
      final targetH = (rawVal / maxVal) * maxAvailableHeight;
      final currentH = targetH * progress;

      if (currentH < 0.5) continue; // Skip invisible bars

      final bx = x - (barW / 2);
      final by = y0;

      final frontColor = bars[i]['colorFront'] as Color;
      final sideColor = bars[i]['colorSide'] as Color;
      final topColor = bars[i]['colorTop'] as Color;

      // ── Tapered Perspective Projection ────────────────────────
      final depthX_bottom = depthX * 0.3; // Thinner at the base
      final depthX_top = depthX;          // Thicker at the top

      // ── Right Side Face ───────────────────────────────────────
      final sidePath = Path()
        ..moveTo(bx + barW, by)
        ..lineTo(bx + barW + depthX_bottom, by - depthY)
        ..lineTo(bx + barW + depthX_top, by - currentH - depthY)
        ..lineTo(bx + barW, by - currentH)
        ..close();
      canvas.drawPath(sidePath, Paint()..color = sideColor);

      // ── Top Face ──────────────────────────────────────────────
      final topPath = Path()
        ..moveTo(bx, by - currentH)
        ..lineTo(bx + barW, by - currentH)
        ..lineTo(bx + barW + depthX_top, by - currentH - depthY)
        ..lineTo(bx + depthX_top, by - currentH - depthY)
        ..close();
      canvas.drawPath(topPath, Paint()..color = topColor);

      // ── Front Face ────────────────────────────────────────────
      final frontRect = Rect.fromLTRB(bx, by - currentH, bx + barW, by);
      canvas.drawRect(frontRect, Paint()..color = frontColor);

      // ── Diagonal Hatch Texture (clean straight lines) ─────────
      if (currentH > 2 && bars[i]['label'] != '') {
        canvas.save();
        canvas.clipRect(frontRect);

        final hatchPaint = Paint()
          ..color = sideColor.withOpacity(0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

        // ── Distinct textures based on performance tier ─────────
        if (i == 0) {
          // Under-performing: Horizontal sinking ripples (volatility)
          for (double stepY = 2; stepY <= currentH; stepY += 6) {
            final path = Path();
            path.moveTo(bx, by - stepY);
            for (double stepX = 0; stepX <= barW; stepX += 2) {
              final wave = math.sin((stepX + stepY) * 0.4) * 1.2;
              path.lineTo(bx + stepX, by - stepY + wave);
            }
            canvas.drawPath(path, hatchPaint);
          }
        } else if (i == 1) {
          // In-line: Organic 45° diagonal with slight wobble (steady natural growth)
          const spacing = 7.0;
          final totalSpan = barW + currentH;
          for (double offset = -currentH; offset < totalSpan; offset += spacing) {
            final path = Path();
            path.moveTo(bx + offset, by);
            for (double step = 0; step <= currentH; step += 4) {
              final wave = math.sin((step + offset) * 0.15) * 1.5;
              path.lineTo(bx + offset + step + wave, by - step);
            }
            canvas.drawPath(path, hatchPaint);
          }
        } else if (i == 2) {
          // Out-performing: Sharp geometric zig-zag pattern (complex, high-energy tech look)
          const spacing = 8.0; 
          final totalSpan = barW + currentH;
          for (double offset = -currentH; offset < totalSpan; offset += spacing) {
            final path = Path();
            path.moveTo(bx + offset, by);
            for (double step = 0; step <= currentH; step += 6) {
              // Alternate left and right for a jagged, high-frequency energy look
              final zig = ((step / 6).floor() % 2 == 0) ? 3.0 : -3.0;
              path.lineTo(bx + offset + (step * 0.35) + zig, by - step);
            }
            canvas.drawPath(path, hatchPaint..strokeWidth = 1.0);
          }
        }
        canvas.restore();
      }

      // ── Value label above bar ─────────────────────────────────
      final labelOpacity = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);
      if (labelOpacity > 0 && bars[i]['amt'] != '') {
        textPainter.text = TextSpan(
          text: bars[i]['amt'] as String,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A).withOpacity(labelOpacity),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, by - currentH - depthY - 22),
        );
      }

      // ── X Axis label ──────────────────────────────────────────
      final label = bars[i]['label'] as String;
      if (label.isNotEmpty) {
        textPainter.text = TextSpan(
          text: label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: Color(0xFF94A3B8),
            height: 1.4,
          ),
        );
        textPainter.layout(maxWidth: stepX - 4);
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y0 + 12));
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final distance = (p2 - p1).distance;
    final direction = (p2 - p1) / distance;
    const dashWidth = 3.0;
    const dashSpace = 5.0;
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
