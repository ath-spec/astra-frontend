import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../../data/portfolio_analysis_providers.dart';
import '../../../data/portfolio_analysis_models.dart';
import 'generic_info_sheet.dart';
import 'sip_month_sheet.dart';

class SipDisciplineGrid extends ConsumerWidget {
  const SipDisciplineGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discAsync = ref.watch(portfolioDisciplineProvider);
    final disc = discAsync.value;

    if (disc == null) {
      return discAsync.isLoading
          ? const _SipGridSkeleton()
          : const SizedBox.shrink();
    }

    final history = disc.monthlyHistory;
    // The grid visualises the most recent 12 months.
    final window = history.length > 12
        ? history.sublist(history.length - 12)
        : history;
    final completed = window.where((m) => m.hasInvestment).length;
    final total = window.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'SIP Discipline',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const GenericInfoSheet(
                      title: 'What is SIP Discipline?',
                      paragraphs: [
                        'SIP Discipline measures how reliably you complete your scheduled SIP instalments.',
                        'It looks at the proportion of SIPs that were successfully executed during the period. Higher reliability reflects stronger follow-through on planned investments.',
                      ],
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.info_outline,
                    size: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$completed of $total',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -1.0,
                  ),
                ),
                const TextSpan(
                  text: ' SIP instalments completed',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Measures how reliably you complete your\nscheduled SIP instalments.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Streak pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: Color(0xFF3182CE),
                ),
                const SizedBox(width: 8),
                Text(
                  '${disc.currentStreakMonths} MONTH STREAK',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF56565),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Month grid (up to 12, two rows)
          _buildMonthGrid(context, history, window),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  String _label(MonthlyInvestmentData m) {
    final n = m.monthName.trim();
    if (n.isNotEmpty) {
      return n.substring(0, n.length >= 3 ? 3 : n.length).toUpperCase();
    }
    final parts = m.yearMonth.split('-');
    if (parts.length >= 2) {
      const abbr = [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
      ];
      final idx = (int.tryParse(parts[1]) ?? 1).clamp(1, 12) - 1;
      return abbr[idx];
    }
    return '--';
  }

  Widget _buildMonthGrid(
    BuildContext context,
    List<MonthlyInvestmentData> history,
    List<MonthlyInvestmentData> window,
  ) {
    if (window.isEmpty) return const SizedBox.shrink();
    final firstRow = window.take(6).toList();
    final secondRow =
        window.length > 6 ? window.sublist(6) : <MonthlyInvestmentData>[];
    final lastMonth = window.last;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                for (final m in firstRow)
                  _buildMonthCircle(context, history, m, identical(m, lastMonth)),
                for (int i = firstRow.length; i < 6; i++)
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                for (final m in secondRow)
                  _buildMonthCircle(context, history, m, identical(m, lastMonth)),
                for (int i = secondRow.length; i < 6; i++)
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCircle(
    BuildContext context,
    List<MonthlyInvestmentData> history,
    MonthlyInvestmentData m,
    bool isActive,
  ) {
    final isCheck = m.hasInvestment;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final idx = history.indexOf(m);
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => SipMonthSheet(
              months: history,
              initialIndex: idx < 0 ? history.length - 1 : idx,
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: isActive
                  ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                  : const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              decoration: isActive
                  ? BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                _label(m),
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
              ),
              child: Center(
                child: Icon(
                  isCheck ? Icons.check : Icons.close,
                  size: 12,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SipGridSkeleton extends StatelessWidget {
  const _SipGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBar(width: 140, height: 20),
          const SizedBox(height: 16),
          const ShimmerBar(width: 220, height: 22),
          const SizedBox(height: 12),
          const ShimmerBar(width: 200, height: 12),
          const SizedBox(height: 24),
          const ShimmerBar(width: 130, height: 30, borderRadius: 4),
          const SizedBox(height: 40),
          for (int row = 0; row < 2; row++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  for (int i = 0; i < 6; i++)
                    const Expanded(
                      child: Column(
                        children: [
                          ShimmerBar(width: 24, height: 10),
                          SizedBox(height: 8),
                          ShimmerBar(width: 20, height: 20, borderRadius: 10),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (row == 0) const SizedBox(height: 32),
          ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
