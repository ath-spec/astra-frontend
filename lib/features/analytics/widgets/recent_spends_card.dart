// ============================================================
// FILE: lib/features/analytics/widgets/recent_spends_card.dart
// "Recent Spends" preview list — top N transactions with a
// "See all" link out to the standalone Transactions feature.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        const SizedBox(height: 12),
        for (var i = 0; i < spends.length; i++) ...[
          _RecentSpendRow(spend: spends[i]),
          if (i != spends.length - 1)
            const Divider(
              height: 1,
              thickness: 0.6,
              indent: 48,
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

  Color _getCategoryColor(String category, String merchant) {
    final cat = category.toLowerCase();
    final name = merchant.toLowerCase();
    if (cat.contains('food') || cat.contains('dining') || name.contains('zomato') || name.contains('swiggy')) {
      return const Color(0xFFF97316);
    } else if (cat.contains('shopping') || name.contains('amazon')) {
      return const Color(0xFF3B82F6);
    } else if (cat.contains('transport') || name.contains('uber')) {
      return const Color(0xFF10B981);
    } else if (cat.contains('entertainment') || name.contains('netflix')) {
      return const Color(0xFF8B5CF6);
    } else if (!spend.isDebit || cat.contains('income') || name.contains('salary')) {
      return const Color(0xFF16A34A);
    }
    return const Color(0xFF64748B);
  }

  IconData _getCategoryIcon(String category, String merchant) {
    final cat = category.toLowerCase();
    final name = merchant.toLowerCase();
    if (cat.contains('food') || cat.contains('dining') || name.contains('zomato') || name.contains('swiggy')) {
      return Icons.restaurant_rounded;
    } else if (cat.contains('shopping') || name.contains('amazon')) {
      return Icons.shopping_bag_rounded;
    } else if (cat.contains('transport') || name.contains('uber')) {
      return Icons.directions_car_rounded;
    } else if (cat.contains('entertainment') || name.contains('netflix')) {
      return Icons.movie_rounded;
    } else if (!spend.isDebit || cat.contains('income') || name.contains('salary')) {
      return Icons.arrow_downward_rounded;
    }
    return Icons.credit_card_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = spend.isDebit ? const Color(0xFF0F172A) : const Color(0xFF16A34A);
    final amountPrefix = spend.isDebit ? '-' : '+';
    final color = _getCategoryColor(spend.category, spend.merchantName);
    final icon = _getCategoryIcon(spend.category, spend.merchantName);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.5),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  spend.merchantName,
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
