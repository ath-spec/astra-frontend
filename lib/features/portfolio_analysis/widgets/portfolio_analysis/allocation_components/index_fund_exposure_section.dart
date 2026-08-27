import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/portfolio_analysis_providers.dart';
import '../../../data/portfolio_analysis_models.dart';
import '../discipline_components/generic_info_sheet.dart';

String _formatInr(double value) {
  final rounded = value.round();
  final neg = rounded < 0;
  final digits = rounded.abs().toString();
  String out;
  if (digits.length <= 3) {
    out = digits;
  } else {
    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    out =
        '${head.replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+(?!\d))'), (m) => '${m[1]},')},$tail';
  }
  return '${neg ? '-₹' : '₹'}$out';
}

const _capColors = {
  'Large Cap': Color(0xFF2563EB),
  'Mid Cap': Color(0xFFF687B3),
  'Small Cap': Color(0xFF059669),
  'Micro Cap': Color(0xFFD97706),
};

class IndexFundExposureSection extends ConsumerStatefulWidget {
  const IndexFundExposureSection({super.key});

  @override
  ConsumerState<IndexFundExposureSection> createState() =>
      _IndexFundExposureSectionState();
}

class _IndexFundExposureSectionState
    extends ConsumerState<IndexFundExposureSection>
    with TickerProviderStateMixin {
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
    _barAnimation =
        CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic);

    _doughnutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _doughnutAnimation =
        CurvedAnimation(parent: _doughnutController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _barController.dispose();
    _doughnutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allocAsync = ref.watch(portfolioAllocationProvider);
    final ee = allocAsync.valueOrNull?.equityExposure;

    if (ee == null) {
      return allocAsync.isLoading
          ? const _IndexFundExposureSkeleton()
          : const SizedBox.shrink();
    }

    final youPct = ee.indexFundPct;
    final peerPct = ee.peerIndexFundPct;
    final diff = youPct - peerPct;
    final String headline;
    if (peerPct <= 0 && youPct <= 0) {
      headline = 'No passive exposure';
    } else if (diff.abs() < 1) {
      headline = 'In line with';
    } else if (diff < 0) {
      headline = '${diff.abs().round()}% less';
    } else {
      headline = '${diff.round()}% more';
    }
    final maxPct = math.max(math.max(youPct, peerPct), 1.0);

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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
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
                        child: Icon(Icons.info_outline,
                            size: 14, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      headline,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'than your peers',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Peer Comparison
                Row(
                  children: const [
                    Icon(Icons.person, size: 12, color: Color(0xFF64748B)),
                    SizedBox(width: 8),
                    Text('You',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600)),
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
                          width: (youPct / maxPct) * 120 * _barAnimation.value,
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        Text('${youPct.toStringAsFixed(youPct % 1 == 0 ? 0 : 1)}%',
                            style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A))),
                      ],
                    );
                  },
                ),
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
                      child: const Icon(Icons.people,
                          size: 12, color: Color(0xFF22543D)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Investors like you',
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600)),
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
                          width: (peerPct / maxPct) * 120 * _barAnimation.value,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                            '${peerPct.toStringAsFixed(peerPct % 1 == 0 ? 0 : 1)}%',
                            style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A))),
                      ],
                    );
                  },
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
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
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
                      child: Icon(Icons.info_outline,
                          size: 14, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatInr(ee.totalEquityValue),
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'total equity exposure',
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
                'Breakdown of your equity exposure by company size and sector - including\nunderlying stocks within your mutual funds.',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
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
                          for (int i = 0; i < ee.marketCap.length; i++) ...[
                            if (i > 0) const SizedBox(height: 20),
                            _buildLegendItem(
                              _capColors[ee.marketCap[i].label] ??
                                  const Color(0xFF94A3B8),
                              ee.marketCap[i].label,
                              '${ee.marketCap[i].pct.toStringAsFixed(2)}%',
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Doughnut Chart
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.22,
                      height: MediaQuery.of(context).size.width * 0.22,
                      child: AnimatedBuilder(
                        animation: _doughnutAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _MarketCapPiePainter(
                              progress: _doughnutAnimation.value,
                              slices: ee.marketCap,
                            ),
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
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        Text(
          percentage,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, size: 12, color: Color(0xFF94A3B8)),
      ],
    );
  }
}

class _MarketCapPiePainter extends CustomPainter {
  final double progress;
  final List<MarketCapSliceData> slices;

  _MarketCapPiePainter({required this.progress, required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius - 12);

    double startAngle = -math.pi / 2;
    for (final s in slices) {
      if (s.pct <= 0) continue;
      final sweep = (s.pct / 100) * math.pi * 2 * progress;
      paint.color = _capColors[s.label] ?? const Color(0xFF94A3B8);
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _MarketCapPiePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        !identical(oldDelegate.slices, slices);
  }
}

class _IndexFundExposureSkeleton extends StatelessWidget {
  const _IndexFundExposureSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBar(width: 190, height: 20),
          const SizedBox(height: 16),
          const ShimmerBar(width: 160, height: 22),
          const SizedBox(height: 32),
          const ShimmerBar(width: 90, height: 12),
          const SizedBox(height: 12),
          const ShimmerBar(width: 120, height: 8),
          const SizedBox(height: 24),
          const ShimmerBar(width: 140, height: 12),
          const SizedBox(height: 12),
          const ShimmerBar(width: 90, height: 8),
          const SizedBox(height: 48),
          const ShimmerBar(width: 200, height: 20),
          const SizedBox(height: 16),
          const ShimmerBar(width: 150, height: 22),
          const SizedBox(height: 40),
          Row(
            children: [
              const Expanded(
                child: Column(
                  children: [
                    ShimmerBar(width: double.infinity, height: 12),
                    SizedBox(height: 20),
                    ShimmerBar(width: double.infinity, height: 12),
                    SizedBox(height: 20),
                    ShimmerBar(width: double.infinity, height: 12),
                    SizedBox(height: 20),
                    ShimmerBar(width: double.infinity, height: 12),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.22,
                height: MediaQuery.of(context).size.width * 0.22,
                child: const ShimmerBar(
                    width: double.infinity, height: double.infinity, borderRadius: 999),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
