import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class EquitySectorExposureSection extends StatefulWidget {
  const EquitySectorExposureSection({super.key});

  @override
  State<EquitySectorExposureSection> createState() => _EquitySectorExposureSectionState();
}

class _EquitySectorExposureSectionState extends State<EquitySectorExposureSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('EquitySectorExposureSection'),
      onVisibilityChanged: (info) {
        if (!_hasAnimated && info.visibleFraction >= 0.3) {
          _hasAnimated = true;
          _controller.forward();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DottedDivider(),
            const SizedBox(height: 32),
            const Text(
              'Equity Sector Exposure',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectorBar('Financial Services', 34, '₹1,12,756'),
            const SizedBox(height: 24),
            _buildSectorBar('Consumer Cyclical', 13, '₹42,835'),
            const SizedBox(height: 24),
            _buildSectorBar('Industrials', 9, '₹30,140'),
            const SizedBox(height: 24),
            _buildSectorBar('Technology', 8, '₹26,533'),
            const SizedBox(height: 24),
            _buildSectorBar('Others', 34, '₹1,13,471'),
            
            const SizedBox(height: 48),
            const Text(
              'This information is provided for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. It is based on standardized methods and may not reflect your individual financial circumstances or risk profile. Consider consulting a financial advisor before making any investment decisions.',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                height: 1.5,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorBar(String name, int percentage, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$name ($percentage%)',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: 10,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width * (percentage / 100) * _animation.value,
                  color: const Color(0xFF2563EB),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DottedLinePainter(),
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
