import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../dashboard/data/dashboard_providers.dart';
import '../../../data/portfolio_analysis_providers.dart';
import '../../../models/portfolio_analysis_models.dart';
import 'allocation_info_sheet.dart';
import 'allocation_factor_info_sheet.dart';

class AllocationFactorsCard extends ConsumerStatefulWidget {
  const AllocationFactorsCard({super.key});

  @override
  ConsumerState<AllocationFactorsCard> createState() => _AllocationFactorsCardState();
}

class _AllocationFactorsCardState extends ConsumerState<AllocationFactorsCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
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
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    final alloc = allocAsync.value;
    final totalWealth = summaryAsync.value?.totalWealth ?? 0.0;

    final double debtPct = alloc?.debtPct ?? 0.0;
    final double equityPct = alloc?.equityPct ?? 0.0;
    final double otherPct = alloc?.otherPct ?? 0.0;

    final int stableAmount = ((debtPct / 100) * totalWealth).toInt();
    final int equityAmount = ((equityPct / 100) * totalWealth).toInt();
    final int inflationAmount = ((otherPct / 100) * totalWealth).toInt();

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
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
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
                          builder: (context) => const AllocationInfoSheet(level: AllocationLevel.veryAggressive),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              const _DottedDivider(),
              
              // Animated Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return SizedBox(
                      height: 8,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _FactorsProgressBarPainter(
                          progress: _animation.value,
                          debtPct: debtPct,
                          equityPct: equityPct,
                          otherPct: otherPct,
                        ),
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
                amount: '₹ ${stableAmount.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                percentage: '${debtPct.toStringAsFixed(1)}%',
                iconColor: const Color(0xFF38A169),
              ),
              const _DottedDivider(),
              _buildFactorItem(
                context: context,
                index: 1,
                icon: Icons.show_chart,
                title: 'Growth assets',
                subtitle: 'Mutual Funds & Stocks',
                amount: '₹ ${equityAmount.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                percentage: '${equityPct.toStringAsFixed(1)}%',
                iconColor: const Color(0xFF0F172A),
              ),
              const _DottedDivider(),
              _buildFactorItem(
                context: context,
                index: 2,
                icon: Icons.security,
                title: 'Inflation protection',
                subtitle: 'Gold, Real Estate & Commodities',
                amount: '₹ ${inflationAmount.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                percentage: '${otherPct.toStringAsFixed(1)}%',
                iconColor: const Color(0xFFD69E2E),
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
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => AllocationFactorInfoSheet(initialIndex: index),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  percentage,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class _FactorsProgressBarPainter extends CustomPainter {
  final double progress;
  final double debtPct;
  final double equityPct;
  final double otherPct;

  _FactorsProgressBarPainter({
    required this.progress,
    required this.debtPct,
    required this.equityPct,
    required this.otherPct,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, bgPaint);

    final double total = debtPct + equityPct + otherPct;
    if (total == 0) return;

    final double stableW = (debtPct / total) * size.width * progress;
    final double equityW = (equityPct / total) * size.width * progress;
    final double otherW = (otherPct / total) * size.width * progress;

    double currentX = 0;

    if (stableW > 0) {
      final stablePaint = Paint()..color = const Color(0xFF38A169);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(currentX, 0, stableW, size.height),
          const Radius.circular(4),
        ),
        stablePaint,
      );
      currentX += stableW;
    }

    if (equityW > 0) {
      final equityPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawRect(
        Rect.fromLTWH(currentX, 0, equityW, size.height),
        equityPaint,
      );
      currentX += equityW;
    }

    if (otherW > 0) {
      final otherPaint = Paint()..color = const Color(0xFFD69E2E);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(currentX, 0, otherW, size.height),
          const Radius.circular(4),
        ),
        otherPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FactorsProgressBarPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        debtPct != oldDelegate.debtPct ||
        equityPct != oldDelegate.equityPct;
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: const Color(0xFFF1F5F9),
    );
  }
}
