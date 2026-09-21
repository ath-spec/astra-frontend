// ============================================================
// FILE: lib/features/analytics/widgets/recent_spends_card.dart
// "Recent Spends" preview list — top N transactions with a
// "See all" link out to the standalone Transactions feature.
// Uses brand logos for merchants when available in assets.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/merchant_logo_avatar.dart';
import '../models/analytics_models.dart';

class RecentSpendsCard extends StatelessWidget {
  final List<RecentSpend> spends;
  final VoidCallback? onSeeAll;

  const RecentSpendsCard({super.key, required this.spends, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent spends',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.0,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5BA1F7),
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF5BA1F7)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < spends.length; i++) ...[
          _RecentSpendRow(spend: spends[i]),
          if (i != spends.length - 1)
            const Divider(
              height: 12,
              thickness: 0.6,
              indent: 50,
              color: Color(0xFFF1F5F9),
            ),
        ],
      ],
    );
  }
}

class _RecentSpendRow extends StatelessWidget {
  final RecentSpend spend;

  const _RecentSpendRow({required this.spend});

  @override
  Widget build(BuildContext context) {
    final amountColor = spend.isDebit ? const Color(0xFF0F172A) : const Color(0xFF16A34A);
    final amountPrefix = spend.isDebit ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          MerchantLogoAvatar(
            merchantName: spend.merchantName,
            category: spend.category,
            size: 38,
            borderRadius: 10,
            isDebit: spend.isDebit,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  spend.merchantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${spend.category} · ${DateFormat('h:mm a').format(spend.time)}',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$amountPrefix₹${NumberFormat('#,##0').format(spend.amount)}',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
