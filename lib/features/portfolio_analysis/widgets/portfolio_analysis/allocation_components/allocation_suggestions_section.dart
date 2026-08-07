import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/animated_gradient_text.dart';
import '../../../../../core/widgets/typewriter_text.dart';

class AllocationSuggestionsSection extends StatelessWidget {
  const AllocationSuggestionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Allocation Suggestions',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Insights based on your current portfolio mix.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 32),
          
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
                      'INSIGHTS BY PORTFOLIO AGENT',
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
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 24),

          // Insight Card 1 (Purple)
          _buildInsightCard(
            context: context,
            index: 1, // Index Funds is index 1
            title: 'Consider Index funds to achieve stability',
            painter: _TargetIsometricPainter(),
            bgGradient: const LinearGradient(
              colors: [Color(0xFFF5F3FF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          const SizedBox(height: 20),

          // Insight Card 2 (Teal)
          _buildInsightCard(
            context: context,
            index: 0, // Tax Harvesting is index 0
            title: 'Save tax on your gains (Tax Harvesting)',
            painter: _HarvestableIsometricPainter(),
            bgGradient: const LinearGradient(
              colors: [Color(0xFFF0FDF4), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required BuildContext context,
    required int index,
    required String title,
    required CustomPainter painter,
    required Gradient bgGradient,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/insights?initial=$index');
      },
      child: Container(
        width: double.infinity,
        height: 180,
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 3D Illustration
          Positioned(
            right: 0,
            bottom: 20,
            width: 180,
            height: 140,
            child: CustomPaint(painter: painter),
          ),
          // Text and Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF334155)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'KNOW MORE',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

// Draw a stylized Isometric 3D bar for "Target"
class _TargetIsometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // A simplified isometric block rendering
    final paintTop = Paint()..color = const Color(0xFFF3E8FF);
    final paintLeft = Paint()..color = const Color(0xFFE9D8FD);
    final paintRight = Paint()..color = const Color(0xFFD6BCFA);

    // Dotted target box
    final targetPath = Path()
      ..moveTo(20, 20)
      ..lineTo(70, 0)
      ..lineTo(110, 20)
      ..lineTo(60, 40)
      ..close();
    
    // For simplicity, just drawing the filled target box with an outline
    final targetPaint = Paint()
      ..color = const Color(0xFFF3E8FF).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    final targetOutlinePaint = Paint()
      ..color = const Color(0xFFB794F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(targetPath, targetPaint);
    canvas.drawPath(targetPath, targetOutlinePaint);

    // Text in target
    final tp = TextPainter(
      text: const TextSpan(
        text: 'YOUR\nTARGET\n20.0%-30.0%',
        style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6B46C1)),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, const Offset(30, 20));

    // The solid isometric block (Current)
    final h = 60.0;
    final bx = 80.0;
    final by = 80.0;

    final blockTop = Path()
      ..moveTo(bx, by)
      ..lineTo(bx + 40, by - 20)
      ..lineTo(bx + 70, by)
      ..lineTo(bx + 30, by + 20)
      ..close();
      
    final blockLeft = Path()
      ..moveTo(bx, by)
      ..lineTo(bx + 30, by + 20)
      ..lineTo(bx + 30, by + 20 + h)
      ..lineTo(bx, by + h)
      ..close();
      
    final blockRight = Path()
      ..moveTo(bx + 30, by + 20)
      ..lineTo(bx + 70, by)
      ..lineTo(bx + 70, by + h)
      ..lineTo(bx + 30, by + 20 + h)
      ..close();

    canvas.drawPath(blockTop, paintTop);
    canvas.drawPath(blockLeft, paintLeft);
    canvas.drawPath(blockRight, paintRight);
    
    // Bottom border stroke
    canvas.drawLine(Offset(bx, by + h), Offset(bx + 30, by + 20 + h), Paint()..color = const Color(0xFF6B46C1)..strokeWidth = 3);
    canvas.drawLine(Offset(bx + 30, by + 20 + h), Offset(bx + 70, by + h), Paint()..color = const Color(0xFF6B46C1)..strokeWidth = 3);

    // Current pointer
    final pointerTp = TextPainter(
      text: const TextSpan(
        text: 'CURRENT',
        style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    pointerTp.layout();
    
    // Draw pointer box
    final pRect = Rect.fromLTWH(bx - 40, by + h - 10, pointerTp.width + 12, pointerTp.height + 6);
    canvas.drawRRect(RRect.fromRectAndRadius(pRect, const Radius.circular(4)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(pRect, const Radius.circular(4)), Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);
    pointerTp.paint(canvas, Offset(pRect.left + 6, pRect.top + 3));
    canvas.drawLine(Offset(pRect.right, pRect.center.dy), Offset(bx + 15, by + h + 8), Paint()..color = Colors.black..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Draw a stylized Isometric 3D bar for "Harvestable"
class _HarvestableIsometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Empty glass block
    final bx = 40.0;
    final by = 70.0;
    final h = 30.0;
    
    final glassOutline = Paint()
      ..color = const Color(0xFF9AE6B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final glassFill = Paint()
      ..color = const Color(0xFFF0FDF4).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Full glass block
    final fullBlockPath = Path()
      ..moveTo(bx, by)
      ..lineTo(bx + 40, by - 20)
      ..lineTo(bx + 90, by)
      ..lineTo(bx + 50, by + 20)
      ..lineTo(bx + 50, by + 20 + h)
      ..lineTo(bx, by + h)
      ..close();
    
    canvas.drawPath(fullBlockPath, glassFill);
    canvas.drawPath(fullBlockPath, glassOutline);
    
    // Inner lines for 3d glass effect
    canvas.drawLine(Offset(bx + 50, by + 20), Offset(bx + 90, by), glassOutline);
    canvas.drawLine(Offset(bx + 50, by + 20), Offset(bx, by), glassOutline);
    canvas.drawLine(Offset(bx + 40, by - 20), Offset(bx + 40, by - 20 + h), glassOutline);

    // Solid harvestable small block at front
    final sbx = bx;
    final sby = by;
    final paintTop = Paint()..color = const Color(0xFF9DECF9);
    final paintLeft = Paint()..color = const Color(0xFF319795);
    final paintRight = Paint()..color = const Color(0xFF4FD1C5);
    
    final sblockTop = Path()
      ..moveTo(sbx, sby)
      ..lineTo(sbx + 10, sby - 5)
      ..lineTo(sbx + 20, sby)
      ..lineTo(sbx + 10, sby + 5)
      ..close();
      
    final sblockLeft = Path()
      ..moveTo(sbx, sby)
      ..lineTo(sbx + 10, sby + 5)
      ..lineTo(sbx + 10, sby + 5 + h)
      ..lineTo(sbx, sby + h)
      ..close();
      
    final sblockRight = Path()
      ..moveTo(sbx + 10, sby + 5)
      ..lineTo(sbx + 20, sby)
      ..lineTo(sbx + 20, sby + h)
      ..lineTo(sbx + 10, sby + 5 + h)
      ..close();

    canvas.drawPath(sblockTop, paintTop);
    canvas.drawPath(sblockLeft, paintLeft);
    canvas.drawPath(sblockRight, paintRight);

    // Text Pointer
    final pointerTp = TextPainter(
      text: const TextSpan(
        text: 'HARVESTABLE',
        style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF319795)),
      ),
      textDirection: TextDirection.ltr,
    );
    pointerTp.layout();
    
    final pRect = Rect.fromLTWH(sbx - 20, sby - 40, pointerTp.width + 12, pointerTp.height + 6);
    canvas.drawRRect(RRect.fromRectAndRadius(pRect, const Radius.circular(4)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(pRect, const Radius.circular(4)), Paint()..color = const Color(0xFF319795)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    pointerTp.paint(canvas, Offset(pRect.left + 6, pRect.top + 3));
    canvas.drawLine(Offset(pRect.center.dx, pRect.bottom), Offset(sbx + 10, sby + 5), Paint()..color = const Color(0xFF319795)..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
