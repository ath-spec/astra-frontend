import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/animated_gradient_text.dart';
import '../../../../../core/widgets/typewriter_text.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../data/portfolio_analysis_providers.dart';
import '../../../data/portfolio_analysis_models.dart';
import 'portfolio_genome_chart.dart';

String _formatInr(double value) {
  final rounded = value.round();
  final isNegative = rounded < 0;
  final digits = rounded.abs().toString();
  String formatted;
  if (digits.length <= 3) {
    formatted = digits;
  } else {
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final headFormatted = head.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (m) => '${m[1]},',
    );
    formatted = '$headFormatted,$tail';
  }
  return '${isNegative ? '-' : ''}₹ $formatted';
}

class EquitySectorExposureSection extends ConsumerStatefulWidget {
  const EquitySectorExposureSection({super.key});

  @override
  ConsumerState<EquitySectorExposureSection> createState() => _EquitySectorExposureSectionState();
}

class _EquitySectorExposureSectionState extends ConsumerState<EquitySectorExposureSection> with SingleTickerProviderStateMixin {
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
    final allocAsync = ref.watch(portfolioAllocationProvider);
    final sectors =
        allocAsync.valueOrNull?.sectorExposure ?? const <SectorExposureData>[];
    final isLoading = allocAsync.isLoading && sectors.isEmpty;

    return VisibilityDetector(
      key: const Key('EquitySectorExposureSection'),
      onVisibilityChanged: (info) {
        if (!_hasAnimated && info.visibleFraction >= 0.15) {
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
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 24),

            if (isLoading)
              ..._sectorBarsSkeleton()
            else
              ..._sectorBars(sectors),

            const SizedBox(height: 48),

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sectors.isEmpty)
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBar(width: double.infinity, height: 12),
                        SizedBox(height: 8),
                        ShimmerBar(width: double.infinity, height: 12),
                        SizedBox(height: 8),
                        ShimmerBar(width: 180, height: 12),
                      ],
                    )
                  else
                    AnimatedGradientShimmer(
                      child: TypewriterText(
                        text: _insightText(sectors),
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  const PortfolioGenomeChart(),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            const Text(
              'This information is provided for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. It is based on standardized methods and may not reflect your individual financial circumstances or risk profile. Consider consulting a financial advisor before making any investment decisions.',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
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

  String _insightText(List<SectorExposureData> sectors) {
    final top = sectors.reduce((a, b) => a.percentage >= b.percentage ? a : b);
    return 'Your portfolio has a strong tilt towards ${top.sector} (${top.percentage.round()}%) and Cyclical sectors. While great for growth during economic expansions, this creates a blind spot in defensive sectors like Healthcare or Utilities. This means your portfolio is highly sensitive to interest rate changes and economic cycles, lacking stability during market downturns.';
  }

  List<Widget> _sectorBars(List<SectorExposureData> sectors) {
    final out = <Widget>[];
    for (var i = 0; i < sectors.length; i++) {
      if (i > 0) out.add(const SizedBox(height: 24));
      final s = sectors[i];
      out.add(_buildSectorBar(s.sector, s.percentage.round(), _formatInr(s.amount)));
    }
    return out;
  }

  List<Widget> _sectorBarsSkeleton() {
    final out = <Widget>[];
    for (var i = 0; i < 5; i++) {
      if (i > 0) out.add(const SizedBox(height: 24));
      out.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBar(width: 150, height: 12),
                ShimmerBar(width: 74, height: 12),
              ],
            ),
            SizedBox(height: 8),
            ShimmerBar(width: double.infinity, height: 10, borderRadius: 0),
          ],
        ),
      );
    }
    return out;
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
