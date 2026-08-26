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

    final int streak = disc?.currentStreakMonths ?? 0;
    final int activeSips = disc?.activeMandatesCount ?? 0;
    final double autoRatio = (disc?.sipAutomationPct ?? 0.0) / 100.0;

    final String consistencyStatus = streak >= 10 ? 'Excellent' : (streak >= 6 ? 'Fair' : 'Needs Attention');
    final Color consistencyColor = streak >= 10 ? const Color(0xFF10B981) : (streak >= 6 ? const Color(0xFFDD6B20) : const Color(0xFFEF4444));

    final String sipStatus = activeSips > 0 ? 'Active' : 'No SIP';
    final Color sipColor = activeSips > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    final String autoStatus = autoRatio >= 0.8 ? 'Automated' : (autoRatio >= 0.4 ? 'Partial' : 'Manual');
    final Color autoColor = autoRatio >= 0.8 ? const Color(0xFF10B981) : const Color(0xFFDD6B20);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const DisciplineInfoSheet(currentLevelIndex: 2),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'DISCIPLINE FACTORS',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFactorItem(
                      icon: Icons.layers_outlined,
                      title: 'Monthly Consistency',
                      subtitle: 'Maintained regular investments in $streak of the last 12 months',
                      status: consistencyStatus,
                      statusColor: consistencyColor,
                      context: context,
                    ),
                    const _DottedDivider(),
                    _buildFactorItem(
                      icon: Icons.calendar_today_outlined,
                      title: 'SIP Health',
                      subtitle: '$activeSips active SIP mandates running on schedule',
                      status: sipStatus,
                      statusColor: sipColor,
                      context: context,
                    ),
                    const _DottedDivider(),
                    _buildFactorItem(
                      icon: Icons.autorenew_rounded,
                      title: 'Automation Ratio',
                      subtitle: '${(autoRatio * 100).toInt()}% of monthly investments set to autopay',
                      status: autoStatus,
                      statusColor: autoColor,
                      context: context,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
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
                    fontSize: 13,
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
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
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
