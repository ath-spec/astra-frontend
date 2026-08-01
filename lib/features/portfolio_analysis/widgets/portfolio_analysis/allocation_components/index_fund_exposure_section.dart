import 'package:flutter/material.dart';
import 'dart:math' as math;

class IndexFundExposureSection extends StatefulWidget {
  const IndexFundExposureSection({super.key});

  @override
  State<IndexFundExposureSection> createState() => _IndexFundExposureSectionState();
}

class _IndexFundExposureSectionState extends State<IndexFundExposureSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    
    Future.delayed(const Duration(milliseconds: 500), () {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Index Fund Exposure',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '25% less',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'than your peers',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Peer Comparison
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              const Text('You', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('0%', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF9AE6B4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people, size: 16, color: Color(0xFF22543D)),
              ),
              const SizedBox(width: 8),
              const Text('Investors like you', style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 8,
                width: 100,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 8),
              const Text('25%', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 48),
          
          // Market Cap Split
          Row(
            children: const [
              Text(
                'Equity Market cap split',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '₹2,30,102',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'total equity exposure',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Breakdown of your equity exposure by\ncompany size and sector - including\nunderlying stocks within your mutual funds.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 40),
          
          // Doughnut Chart and Legend
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Legend
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(const Color(0xFF2563EB), 'Large Cap', '89.36%'),
                    const SizedBox(height: 20),
                    _buildLegendItem(const Color(0xFFF687B3), 'Mid Cap', '10.63%'),
                    const SizedBox(height: 20),
                    _buildLegendItem(const Color(0xFF059669), 'Small Cap', '0.01%'),
                    const SizedBox(height: 20),
                    _buildLegendItem(const Color(0xFFD97706), 'Micro Cap', '0.0%'),
                  ],
                ),
              ),
              // Doughnut Chart
              SizedBox(
                width: 120,
                height: 120,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _MarketCapPiePainter(progress: _animation.value),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String percentage) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        Text(
          percentage,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
      ],
    );
  }
}

class _MarketCapPiePainter extends CustomPainter {
  final double progress;

  _MarketCapPiePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.butt;
    
    final rect = Rect.fromCircle(center: center, radius: radius - 12);
    
    // Large Cap (89.36%) - Blue
    final largeCapSweep = (89.36 / 100) * math.pi * 2 * progress;
    paint.color = const Color(0xFF2563EB);
    canvas.drawArc(rect, -math.pi / 2, largeCapSweep, false, paint);
    
    // Mid Cap (10.63%) - Pink
    final midCapSweep = (10.63 / 100) * math.pi * 2 * progress;
    paint.color = const Color(0xFFF687B3);
    canvas.drawArc(rect, -math.pi / 2 + largeCapSweep, midCapSweep, false, paint);
    
    // Small Cap and Micro Cap are practically 0, so skipping them on the chart
  }

  @override
  bool shouldRepaint(covariant _MarketCapPiePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
