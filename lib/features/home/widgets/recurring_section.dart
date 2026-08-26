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
    final showActive = activeMandates.isNotEmpty;
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
                      color: Colors.black54,
                      size: 16,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
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
                  DateFormat('MMM').format(DateTime.now()).toLowerCase(),
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  DateFormat('yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(height: 30, width: 1, color: Colors.grey[300]),
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
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
      width: 135,
      height: 165,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white),
        borderRadius: BorderRadius.circular(4),
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
                      payeeName.toLowerCase(),
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payeedeet.toLowerCase(),
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Logo bubble — SVG if available, fallback to icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: logoAsset != null
                      ? Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SvgPicture.asset(
                            logoAsset!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(
                          icon ?? Icons.account_balance,
                          size: 16,
                          color: isDark ? Colors.black : Colors.black87,
                        ),
                ),
              ),
            ],
          ),
          // Due badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE5803E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Due in $dueInDays days',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
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
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          // Pay now button
          Container(
            width: double.infinity,
            height: 35,
            decoration: BoxDecoration(
              color: isDark ? Colors.white : Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PAY NOW',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 10,
                  color: isDark ? Colors.black : Colors.white,
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
        color: const Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(4),
        border:Border.all(color:const Color(0xFFE2E8F0),)
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
                  width: constraints.maxWidth * 0.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'lib/core/images/bills_card.webp',
                      fit: BoxFit.contain, // Contain will show the whole image
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                // ── Right text panel ─────────────────────────────────────
                Padding(
                  padding: EdgeInsets.only(
                    left: constraints.maxWidth * 0.4 + 10,
                    right: 18,
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
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF27272A), Color(0xFF09090B)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                        ),
                        child: const Text(
                          'TRACK NOW',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
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
