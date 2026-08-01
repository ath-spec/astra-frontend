import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:visibility_detector/visibility_detector.dart';
import '../discipline_components/generic_info_sheet.dart';

class IndexFundExposureSection extends StatefulWidget {
  const IndexFundExposureSection({super.key});

  @override
  State<IndexFundExposureSection> createState() => _IndexFundExposureSectionState();
}

class _IndexFundExposureSectionState extends State<IndexFundExposureSection> with TickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnimation;
  bool _hasBarAnimated = false;
  
  late AnimationController _doughnutController;
  late Animation<double> _doughnutAnimation;
  bool _hasDoughnutAnimated = false;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _barAnimation = CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic);
    
    _doughnutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _doughnutAnimation = CurvedAnimation(parent: _doughnutController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _barController.dispose();
    _doughnutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VisibilityDetector(
            key: const Key('IndexFundExposureSection_Bar'),
            onVisibilityChanged: (info) {
              if (!_hasBarAnimated && info.visibleFraction >= 0.15) {
                _hasBarAnimated = true;
                _barController.forward();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Index Fund Exposure',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => const GenericInfoSheet(
                            title: 'What is Index Fund Exposure?',
                            paragraphs: [
                              'This shows what share of your equity portfolio is invested in passive index funds, compared to people like you.',
                              'Index funds are passive investments that aim to replicate a market index, such as the Nifty 50 or Sensex, rather than actively selecting stocks. Because they follow a predefined index, they typically have lower costs and broad market exposure.',
                              'We include index exposure held directly and through mutual funds to reflect your total allocation to passive investing.',
                            ],
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
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
                AnimatedBuilder(
                  animation: _barAnimation,
                  builder: (context, child) {
                    return Row(
                      children: [
                        Container(
                          height: 8,
                          width: 100 * _barAnimation.value,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('25%', style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Market Cap Split
                Row(
                  children: [
                    const Text(
                      'Equity Market cap split',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => const GenericInfoSheet(
                            title: 'What is Equity Market Cap & Sector Split?',
                            paragraphs: [
                              'This shows how your total equity portfolio is distributed across company sizes and sectors.',
                              'Market cap refers to the size of a company, commonly grouped into large-cap, mid-cap, small-cap and micro-cap. Sector split reflects which industries your investments are exposed to, such as financials, technology or healthcare.',
                              'We analyse both the stocks you hold directly and the underlying stocks inside your mutual funds, so this reflects your true overall equity exposure.',
                            ],
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
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
                VisibilityDetector(
                  key: const Key('IndexFundExposureSection_Doughnut'),
                  onVisibilityChanged: (info) {
                    if (!_hasDoughnutAnimated && info.visibleFraction >= 0.15) {
                      _hasDoughnutAnimated = true;
                      _doughnutController.forward();
                    }
                  },
                  child: Row(
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
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.width * 0.35,
                        child: AnimatedBuilder(
                          animation: _doughnutAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _MarketCapPiePainter(progress: _doughnutAnimation.value),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
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
