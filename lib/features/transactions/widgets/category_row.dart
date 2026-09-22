// ============================================================
// FILE: lib/features/transactions/widgets/category_row.dart
// One row in the Transactions screen's "Categories" tab.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_models.dart';

class CategoryRow extends StatelessWidget {
  final CategorySummary summary;
  final VoidCallback? onTap;

  const CategoryRow({super.key, required this.summary, this.onTap});

  _CatVisual _getVisual() {
    final cat = summary.category.toLowerCase();
    if (cat.contains('food') || cat.contains('dining')) {
      return const _CatVisual(color: Color(0xFFF97316), icon: Icons.restaurant_rounded);
    } else if (cat.contains('shopping')) {
      return const _CatVisual(color: Color(0xFF3B82F6), icon: Icons.shopping_bag_rounded);
    } else if (cat.contains('transport')) {
      return const _CatVisual(color: Color(0xFF10B981), icon: Icons.directions_car_rounded);
    } else if (cat.contains('entertainment')) {
      return const _CatVisual(color: Color(0xFF8B5CF6), icon: Icons.movie_rounded);
    } else if (cat.contains('bill') || cat.contains('utilities')) {
      return const _CatVisual(color: Color(0xFFF43F5E), icon: Icons.receipt_long_rounded);
    } else if (cat.contains('income') || cat.contains('salary')) {
      return const _CatVisual(color: Color(0xFF16A34A), icon: Icons.arrow_downward_rounded);
    }
    return const _CatVisual(color: Color(0xFF64748B), icon: Icons.category_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final visual = _getVisual();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: visual.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(visual.icon, size: 19, color: visual.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    summary.displayName,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${summary.transactionCount} transaction${summary.transactionCount == 1 ? '' : 's'}',
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
              '₹${NumberFormat('#,##0').format(summary.totalAmount)}',
              style: const TextStyle(
                fontFamily: 'DMMono',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _CatVisual {
  final Color color;
  final IconData icon;

  const _CatVisual({required this.color, required this.icon});
}
