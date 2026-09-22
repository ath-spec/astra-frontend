import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Mirrors Zeyro's RecurringSection widget from the home screen.
///
/// Two visual states:
///  - **Empty**: no ACTIVE mandates on the backend — shows [_NoRecurringCard]
///  - **Active**: shows DuePaymentCards (from the real mandate list, sorted
///    by next debit date) + bill stats (from the real summary endpoint)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/features/recurring/data/recurring_mapping.dart';
import 'package:astra_frontend/features/recurring/data/recurring_models.dart';
import 'package:astra_frontend/features/recurring/data/recurring_providers.dart';

class RecurringSection extends ConsumerStatefulWidget {
  const RecurringSection({
    super.key,
  });

  @override
  ConsumerState<RecurringSection> createState() => _RecurringSectionState();
}

class _RecurringSectionState extends ConsumerState<RecurringSection> {
  @override
  Widget build(BuildContext context) {
    final activeMandatesAsync = ref.watch(mandatesProvider('ACTIVE'));
    final activeMandates = activeMandatesAsync.valueOrNull ?? const <RecurringMandate>[];
    final isBillsTrackingUnlocked = ref.watch(billsTrackingUnlockedProvider);
    final showActive = isBillsTrackingUnlocked;
    final summary = ref.watch(recurringSummaryProvider).valueOrNull ?? RecurringSummary.empty;

    return GestureDetector(
      onTap: () {
        if (showActive) {
          context.push('/recurring-control');
        } else {
          // push so home stays in the GoRouter stack beneath intro.
          // The intro then uses context.go('/recurring-control')
          // which replaces only the intro, leaving home below.
          // Back from control → pops to home cleanly.
          context.push('/recurring-intro');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Track your bills',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.0,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (showActive)
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF64748B),
                      size: 16,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Content ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: showActive
                  ? _buildActiveView(activeMandates, summary)
                  : const _NoRecurringCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveView(List<RecurringMandate> activeMandates, RecurringSummary summary) {
    final sorted = [...activeMandates]
      ..sort((a, b) => (a.nextDebitDate ?? 0).compareTo(b.nextDebitDate ?? 0));
    final preview = sorted.take(5).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal scrolling due-payment cards
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              if (preview.isEmpty)
                GestureDetector(
                  onTap: () => context.push('/recurring-control'),
                  child: Container(
                    width: 152,
                    height: 172,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline_rounded, size: 28, color: Color(0xFF64748B)),
                        SizedBox(height: 8),
                        Text(
                          'Add First Bill',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (int i = 0; i < preview.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Builder(builder: (context) {
                    final mandate = preview[i];
                    final visual = paymentMapFromMandate(mandate);
                    final due = mandate.nextDebitDateTime;
                    final dueInDays = due != null ? due.difference(today).inDays : 0;
                    return DuePaymentCard(
                      payeeName: mandate.payeeName,
                      payeedeet: mandate.category ?? '',
                      dueInDays: dueInDays < 0 ? '0' : dueInDays.toString(),
                      amount: NumberFormat.decimalPattern('en_IN').format(mandate.maxAmount),
                      isDark: visual['isDark'] as bool? ?? true,
                      logoAsset: visual['logoAsset'] as String?,
                      icon: visual['icon'] as IconData?,
                      backgroundColor: visual['backgroundColor'] as Color?,
                    );
                  }),
                ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Month + bill stats row
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM').format(DateTime.now()).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  DateFormat('yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontFamily: 'DMMono',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildBillStat('Upcoming', '₹${summary.upcomingTotal.toInt()}')),
                  Expanded(child: _buildBillStat('Overdue', '₹${summary.overdueTotal.toInt()}')),
                  Expanded(child: _buildBillStat('Paid', '₹${summary.paidThisMonthTotal.toInt()}')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Due Payment Card – single bill shown in the active recurring row
// ---------------------------------------------------------------------------
class DuePaymentCard extends StatelessWidget {
  final String payeeName;
  final String payeedeet;
  final String dueInDays;
  final String amount;
  final bool isDark;
  final IconData? icon;
  final String? logoAsset; // SVG path e.g. 'lib/core/images/spotify-icon.svg'
  final Color? backgroundColor;

  const DuePaymentCard({
    super.key,
    required this.payeeName,
    required this.payeedeet,
    required this.dueInDays,
    required this.amount,
    this.isDark = true,
    this.icon,
    this.logoAsset,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 152,
      height: 172,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? const Color(0xFF0F172A) : Colors.white),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row: name + icon bubble
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payeeName,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payeedeet,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF0F172A).withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Logo bubble — SVG if available, fallback to icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: logoAsset != null
                      ? Padding(
                          padding: const EdgeInsets.all(4.5),
                          child: SvgPicture.asset(
                            logoAsset!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(
                          icon ?? Icons.account_balance,
                          size: 14,
                          color: const Color(0xFF0F172A),
                        ),
                ),
              ),
            ],
          ),
          // Due badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE5803E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Due in $dueInDays days',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Amount
          Text(
            '₹$amount',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          // Pay now button
          Container(
            width: double.infinity,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PAY NOW',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 11,
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty-state card – matches Zeyro's _NoRecurringCard (light blue bg)
// ---------------------------------------------------------------------------
class _NoRecurringCard extends StatelessWidget {
  const _NoRecurringCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // ── Left image panel ─────────────────────────────────────
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: constraints.maxWidth * 0.38,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'lib/core/images/bills_card.webp',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                // ── Right text panel ─────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(
                    left: constraints.maxWidth * 0.38 + 12,
                    right: 16,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'AI automatically fetches your bills and reminds you to pay them on time',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TRACK NOW',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
