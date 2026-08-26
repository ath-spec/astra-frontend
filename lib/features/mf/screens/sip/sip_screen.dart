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
    final List<RecurringMandate> mandates = mandatesAsync.value ?? [];
    final bool isEmpty = mandates.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SIPs & Mandates',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -1.0,
                    ),
                  ),
                  if (!isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${mandates.length} Active',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: isEmpty ? const MfSipEmptyState() : _buildContent(context, mandates),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<RecurringMandate> mandates) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: mandates.length,
      itemBuilder: (context, index) {
        final m = mandates[index];
        final nextDateStr = m.nextDebitDateTime != null
            ? DateFormat('dd MMM yyyy').format(m.nextDebitDateTime!)
            : 'Scheduled monthly';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.autorenew_rounded,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.payeeName,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Next debit: $nextDateStr • ${m.frequency}',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          color: Color(0xFF64748B),
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
                      currencyFormat.format(m.maxAmount),
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        m.status.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
