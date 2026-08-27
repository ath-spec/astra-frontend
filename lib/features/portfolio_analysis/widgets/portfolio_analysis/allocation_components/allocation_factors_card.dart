import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/portfolio_analysis_providers.dart';
import 'allocation_info_sheet.dart';
import 'allocation_factor_info_sheet.dart';

String _formatInr(double value) {
  final rounded = value.round();
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
  return '₹ $formatted';
}

class AllocationFactorsCard extends ConsumerStatefulWidget {
  const AllocationFactorsCard({super.key});

  @override
  ConsumerState<AllocationFactorsCard> createState() => _AllocationFactorsCardState();
}

class _AllocationFactorsCardState extends ConsumerState<AllocationFactorsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allocAsync = ref.watch(portfolioAllocationProvider);
    final alloc = allocAsync.value;

    // No fabricated values: skeleton while loading, nothing on failure.
    if (alloc == null) {
      return allocAsync.isLoading
          ? const _AllocationFactorsSkeleton()
          : const SizedBox.shrink();
    }

    final buckets = alloc.volatilityBuckets;

    String stableAmt = '₹ 0', stablePct = '0%';
    String lowAmt = '₹ 0', lowPct = '0%';
    String medAmt = '₹ 0', medPct = '0%';
    String highAmt = '₹ 0', highPct = '0%';

    double sFrac = 0.0, lFrac = 0.0, mFrac = 0.0, hFrac = 0.0;

    {
      for (final b in buckets) {
        final lbl = b.label.toLowerCase();
        final formattedAmt = _formatInr(b.amount);
        final formattedPct = '${b.sharePct.round()}%';
        final frac = (b.sharePct / 100).clamp(0.0, 1.0);

        if (lbl.contains('stable')) {
          stableAmt = formattedAmt;
          stablePct = formattedPct;
          sFrac = frac;
        } else if (lbl.contains('low')) {
          lowAmt = formattedAmt;
          lowPct = formattedPct;
          lFrac = frac;
        } else if (lbl.contains('medium') || lbl.contains('moderat')) {
          medAmt = formattedAmt;
          medPct = formattedPct;
          mFrac = frac;
        } else if (lbl.contains('high')) {
          highAmt = formattedAmt;
          highPct = formattedPct;
          hFrac = frac;
        }
      }
    }

    final level = alloc.level;

    return VisibilityDetector(
      key: const Key('AllocationFactorsCard'),
      onVisibilityChanged: (info) {
        if (!_hasAnimated && info.visibleFraction >= 0.15) {
          _hasAnimated = true;
          _controller.forward();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: _NotchBorder(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ALLOCATION FACTORS',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) =>
                              AllocationInfoSheet(level: level),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.info_outline,
                            size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              const _DottedDivider(),

              // Animated Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 24.0),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(double.infinity, 8),
                      painter: _FactorsProgressBarPainter(
                        progress: _animation.value,
                        values: [sFrac, lFrac, mFrac, hFrac],
                      ),
                    );
                  },
                ),
              ),

              _buildFactorItem(
                context: context,
                index: 0,
                icon: Icons.change_history,
                title: 'Stable assets',
                subtitle: 'Bank Accounts, FDs, Surplus & Liquid Funds',
                amount: stableAmt,
                percentage: stablePct,
                iconColor: const Color(0xFF38A169),
              ),
              const _DottedDivider(),
              _buildFactorItem(
                context: context,
                index: 1,
                icon: Icons.call_split,
                title: 'Low volatility assets',
                subtitle: 'Mostly steady, small ups and downs',
                amount: lowAmt,
                percentage: lowPct,
                iconColor: const Color(0xFF38A169),
              ),
              const _DottedDivider(),
              _buildFactorItem(
                context: context,
                index: 2,
                icon: Icons.star_border,
                title: 'Medium volatility assets',
                subtitle: 'Moderate swings, growth potential',
                amount: medAmt,
                percentage: medPct,
                iconColor: const Color(0xFFDD6B20),
              ),
              const _DottedDivider(),
              _buildFactorItem(
                context: context,
                index: 3,
                icon: Icons.ac_unit,
                title: 'High volatility assets',
                subtitle: 'High swings, high potential',
                amount: highAmt,
                percentage: highPct,
                iconColor: const Color(0xFFE53E3E),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFactorItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String percentage,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => AllocationFactorInfoSheet(initialIndex: index),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(icon, size: 12, color: iconColor),
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
                    subtitle,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  percentage,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocationFactorsSkeleton extends StatelessWidget {
  const _AllocationFactorsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: _NotchBorder(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: ShimmerBar(width: 140, height: 10),
            ),
            const _DottedDivider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ShimmerBar(width: double.infinity, height: 8, borderRadius: 4),
            ),
            for (int i = 0; i < 4; i++) ...[
              if (i > 0) const _DottedDivider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  children: [
                    ShimmerBar(width: 20, height: 20, borderRadius: 10),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBar(width: 120, height: 12),
                          SizedBox(height: 6),
                          ShimmerBar(width: 180, height: 10),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    ShimmerBar(width: 56, height: 12),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 4.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return const SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _NotchBorder extends OutlinedBorder {
  const _NotchBorder(
      {super.side = const BorderSide(
          color: Color.fromARGB(255, 188, 187, 187), width: 1.0)});

  @override
  OutlinedBorder copyWith({BorderSide? side}) =>
      _NotchBorder(side: side ?? this.side);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _getPath(rect.deflate(side.width));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _getPath(rect);

  Path _getPath(Rect rect) {
    final path = Path();
    const notchWidth = 12.0;
    const notchHeight = 6.0;
    const radius = 4.0;

    path.moveTo(rect.left + radius, rect.top);

    path.lineTo(rect.center.dx - (notchWidth / 2), rect.top);
    path.lineTo(rect.center.dx, rect.top - notchHeight);
    path.lineTo(rect.center.dx + (notchWidth / 2), rect.top);

    path.lineTo(rect.right - radius, rect.top);
    path.arcToPoint(Offset(rect.right, rect.top + radius),
        radius: const Radius.circular(radius));

    path.lineTo(rect.right, rect.bottom - radius);
    path.arcToPoint(Offset(rect.right - radius, rect.bottom),
        radius: const Radius.circular(radius));

    path.lineTo(rect.left + radius, rect.bottom);
    path.arcToPoint(Offset(rect.left, rect.bottom - radius),
        radius: const Radius.circular(radius));

    path.lineTo(rect.left, rect.top + radius);
    path.arcToPoint(Offset(rect.left + radius, rect.top),
        radius: const Radius.circular(radius));

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(_getPath(rect), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) => _NotchBorder(side: side.scale(t));
}

class _FactorsProgressBarPainter extends CustomPainter {
  final double progress;
  final List<double> values;

  _FactorsProgressBarPainter({
    required this.progress,
    this.values = const [0.0, 0.0, 0.0, 0.0],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF38A169),
      const Color(0xFF38A169),
      const Color(0xFFDD6B20),
      const Color(0xFFE53E3E),
    ];

    canvas.clipRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)));
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF1F5F9));

    double currentX = 0;
    final totalWidth = size.width * progress;

    for (int i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;

      final segmentWidth = size.width * values[i];
      double drawWidth = segmentWidth;
      if (currentX + segmentWidth > totalWidth) {
        drawWidth = totalWidth - currentX;
      }

      if (drawWidth > 0) {
        canvas.drawRect(
            Rect.fromLTWH(currentX, 0, drawWidth, size.height),
            Paint()..color = colors[i]);
      }
      currentX += segmentWidth;
      if (currentX >= totalWidth) break;
    }
  }

  @override
  bool shouldRepaint(covariant _FactorsProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
