import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/portfolio_analysis_providers.dart';
import 'discipline_info_sheet.dart';

const _green = Color(0xFF38A169);
const _amber = Color(0xFFDD6B20);
const _red = Color(0xFFE53E3E);
const _grey = Color(0xFF94A3B8);

class DisciplineFactorsCard extends ConsumerWidget {
  const DisciplineFactorsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discAsync = ref.watch(portfolioDisciplineProvider);
    final disc = discAsync.value;

    // No fabricated values: skeleton while loading, nothing on failure.
    if (disc == null) {
      return discAsync.isLoading
          ? const _DisciplineFactorsSkeleton()
          : const SizedBox.shrink();
    }

    final history = disc.monthlyHistory;

    // Monthly consistency — real invested-months ratio.
    String consistencySubtitle;
    String consistencyStatus;
    Color consistencyColor;
    if (history.isEmpty) {
      consistencySubtitle = 'No investment activity recorded yet';
      consistencyStatus = 'N/A';
      consistencyColor = _grey;
    } else {
      final total = history.length;
      final invested = history.where((m) => m.hasInvestment).length;
      consistencySubtitle = 'Invested in $invested of the last $total months';
      final ratio = invested / total;
      if (ratio >= 0.8) {
        consistencyStatus = 'Good';
        consistencyColor = _green;
      } else if (ratio >= 0.5) {
        consistencyStatus = 'Fair';
        consistencyColor = _amber;
      } else {
        consistencyStatus = 'Low';
        consistencyColor = _red;
      }
    }

    // SIP health — active mandates + automation share.
    String sipSubtitle;
    String sipStatus;
    Color sipColor;
    if (disc.activeMandatesCount > 0) {
      sipSubtitle =
          '${disc.activeMandatesCount} active SIP mandate${disc.activeMandatesCount == 1 ? '' : 's'} running';
      sipStatus = disc.sipAutomationPct >= 50 ? 'Good' : 'Fair';
      sipColor = disc.sipAutomationPct >= 50 ? _green : _amber;
    } else {
      sipSubtitle = 'No active SIP mandate';
      sipStatus = 'N/A';
      sipColor = _grey;
    }

    // Withdrawal pattern — real sell vs. buy flow over the 12-month window.
    final totalBuy = history.fold<double>(0, (s, m) => s + m.buyAmount);
    final totalSell = history.fold<double>(0, (s, m) => s + m.sellAmount);
    String withdrawalSubtitle;
    String withdrawalStatus;
    Color withdrawalColor;
    if (totalBuy <= 0 && totalSell <= 0) {
      withdrawalSubtitle = 'No investments or withdrawals recorded yet';
      withdrawalStatus = 'N/A';
      withdrawalColor = _grey;
    } else if (totalSell <= 0) {
      withdrawalSubtitle = 'No withdrawals in the last 12 months';
      withdrawalStatus = 'Good';
      withdrawalColor = _green;
    } else {
      final pct = totalBuy > 0 ? (totalSell / totalBuy * 100) : 100.0;
      withdrawalSubtitle =
          'Took out ${pct.round()}% of what you invested over the last 12 months';
      if (pct < 10) {
        withdrawalStatus = 'Good';
        withdrawalColor = _green;
      } else if (pct < 30) {
        withdrawalStatus = 'Fair';
        withdrawalColor = _amber;
      } else {
        withdrawalStatus = 'Low';
        withdrawalColor = _red;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                        'DISCIPLINE FACTORS',
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
                            builder: (context) => const DisciplineInfoSheet(),
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
                _buildFactorItem(
                  icon: Icons.layers_outlined,
                  title: 'Monthly Consistency',
                  subtitle: consistencySubtitle,
                  status: consistencyStatus,
                  statusColor: consistencyColor,
                  context: context,
                ),
                const _DottedDivider(),
                _buildFactorItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'SIP Health',
                  subtitle: sipSubtitle,
                  status: sipStatus,
                  statusColor: sipColor,
                  context: context,
                ),
                const _DottedDivider(),
                _buildFactorItem(
                  icon: Icons.arrow_downward,
                  title: 'Withdrawal Pattern',
                  subtitle: withdrawalSubtitle,
                  status: withdrawalStatus,
                  statusColor: withdrawalColor,
                  context: context,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const DisciplineInfoSheet(),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(icon, size: 12, color: statusColor),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
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

class _DisciplineFactorsSkeleton extends StatelessWidget {
  const _DisciplineFactorsSkeleton();

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
              child: ShimmerBar(width: 150, height: 10),
            ),
            const _DottedDivider(),
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const _DottedDivider(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  children: [
                    ShimmerBar(width: 20, height: 20, borderRadius: 10),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBar(width: 130, height: 12),
                          SizedBox(height: 6),
                          ShimmerBar(width: 200, height: 10),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    ShimmerBar(width: 44, height: 20, borderRadius: 4),
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
