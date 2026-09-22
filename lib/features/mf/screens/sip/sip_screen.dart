import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../recurring/data/recurring_providers.dart';
import '../../../recurring/data/recurring_models.dart';
import 'widgets/mf_sip_empty_state.dart';

class SipScreen extends ConsumerWidget {
  const SipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mandatesAsync = ref.watch(mandatesProvider(null));
    // This screen is specifically for fund SIPs, not every autopay mandate —
    // mandatesProvider(null) also returns bill/subscription mandates (e.g.
    // Netflix, Spotify — see seedDemoSubscriptions in the backend's
    // provider/payments/recurring.go), which have category 'SUBSCRIPTION'/
    // 'BILL'/'OTHER', not 'SIP'. Without this filter every subscription
    // showed up here too.
    final List<RecurringMandate> mandates =
        (mandatesAsync.value ?? []).where((m) => m.category == 'SIP').toList();
    final bool isEmpty = mandates.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(mandates.length, isEmpty),
                  const Expanded(child: MfSipEmptyState()),
                ],
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(mandates.length, isEmpty)),
                  SliverToBoxAdapter(child: _buildContent(mandates)),
                  // Bottom padding for the navigation bar
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(int activeCount, bool isEmpty) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'SIPs & Mandates',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              letterSpacing: -1.0,
            ),
          ),
          if (!isEmpty)
            Text(
              '$activeCount ACTIVE',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(List<RecurringMandate> mandates) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(mandates.length, (index) {
        final m = mandates[index];
        final nextDateStr = m.nextDebitDateTime != null
            ? DateFormat('dd MMM yyyy').format(m.nextDebitDateTime!)
            : 'Scheduled monthly';
        final isLast = index == mandates.length - 1;
        final statusColor = m.status.toUpperCase() == 'ACTIVE'
            ? const Color(0xFF10B981)
            : const Color(0xFF94A3B8);

        return _MandateItem(
          payeeName: m.payeeName,
          subtitle: '$nextDateStr • ${m.frequency}',
          amount: currencyFormat.format(m.maxAmount),
          status: m.status,
          statusColor: statusColor,
          isLast: isLast,
        );
      }),
    );
  }
}

/// Row styling mirrors [MfOrderItemCard] from the Orders screen — a flat
/// row (no card shadow/border box), a white bordered avatar circle, and a
/// dashed divider between rows instead of per-item cards — so SIPs &
/// Mandates matches Orders visually instead of using its own card style.
class _MandateItem extends StatelessWidget {
  final String payeeName;
  final String subtitle;
  final String amount;
  final String status;
  final Color statusColor;
  final bool isLast;

  const _MandateItem({
    required this.payeeName,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.autorenew_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payeeName,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!isLast)
            Row(
              children: List.generate(
                60,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    color: index % 2 == 0 ? const Color(0xFFE2E8F0) : Colors.transparent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
