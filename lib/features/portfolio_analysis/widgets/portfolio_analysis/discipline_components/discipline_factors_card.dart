import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/portfolio_analysis_providers.dart';
import 'discipline_info_sheet.dart';

class DisciplineFactorsCard extends ConsumerWidget {
  const DisciplineFactorsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discAsync = ref.watch(portfolioDisciplineProvider);
    final disc = discAsync.value;

    String consistencySubtitle = 'Dipped below your usual amount in 8 of the last 12 months';
    String consistencyStatus = 'Fair';
    Color consistencyColor = const Color(0xFFDD6B20);

    String sipSubtitle = 'No SIP set up yet';
    String sipStatus = 'N/A';
    Color sipColor = const Color(0xFF94A3B8);

    String withdrawalSubtitle = 'Took out 31% of everything you put in this year';
    String withdrawalStatus = 'Good';
    Color withdrawalColor = const Color(0xFF38A169);

    if (disc != null) {
      final history = disc.monthlyHistory;
      if (history.isNotEmpty) {
        final total = history.length;
        final invested = history.where((m) => m.hasInvestment).length;
        consistencySubtitle = 'Invested in $invested of the last $total months';
        final ratio = invested / total;
        if (ratio >= 0.8) {
          consistencyStatus = 'Good';
          consistencyColor = const Color(0xFF38A169);
        } else if (ratio >= 0.5) {
          consistencyStatus = 'Fair';
          consistencyColor = const Color(0xFFDD6B20);
        } else {
          consistencyStatus = 'Low';
          consistencyColor = const Color(0xFFE53E3E);
        }
      }

      if (disc.activeMandatesCount > 0) {
        sipSubtitle = '${disc.activeMandatesCount} active SIP mandate${disc.activeMandatesCount == 1 ? '' : 's'} running';
        sipStatus = 'Good';
        sipColor = const Color(0xFF38A169);
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
