// ============================================================
// FILE: lib/features/transactions/widgets/transaction_row.dart
// A single transaction row — reused by TransactionsScreen,
// CategoryTransactionsScreen and MerchantTransactionsScreen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_models.dart';

class TransactionRow extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback? onTap;

  const TransactionRow({super.key, required this.item, this.onTap});

  _CategoryVisuals _getVisuals() {
    final cat = item.category.toLowerCase();
    final title = item.title.toLowerCase();

    if (cat.contains('food') || cat.contains('dining') || title.contains('zomato') || title.contains('swiggy')) {
      return const _CategoryVisuals(
        color: Color(0xFFF97316),
        icon: Icons.restaurant_rounded,
      );
    } else if (cat.contains('shopping') || title.contains('amazon') || title.contains('flipkart')) {
      return const _CategoryVisuals(
        color: Color(0xFF3B82F6),
        icon: Icons.shopping_bag_rounded,
      );
    } else if (cat.contains('transport') || title.contains('uber') || title.contains('ola')) {
      return const _CategoryVisuals(
        color: Color(0xFF10B981),
        icon: Icons.directions_car_rounded,
      );
    } else if (cat.contains('entertainment') || title.contains('netflix') || title.contains('spotify')) {
      return const _CategoryVisuals(
        color: Color(0xFF8B5CF6),
        icon: Icons.movie_rounded,
      );
    } else if (cat.contains('bill') || cat.contains('utilities')) {
      return const _CategoryVisuals(
        color: Color(0xFFF43F5E),
        icon: Icons.receipt_long_rounded,
      );
    } else if (!item.isDebit || cat.contains('income') || title.contains('salary')) {
      return const _CategoryVisuals(
        color: Color(0xFF16A34A),
        icon: Icons.arrow_downward_rounded,
      );
    }
    return const _CategoryVisuals(
      color: Color(0xFF64748B),
      icon: Icons.credit_card_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visuals = _getVisuals();
    final isDebit = item.isDebit;
    final amountColor = isDebit ? const Color(0xFF0F172A) : const Color(0xFF16A34A);
    final amountPrefix = isDebit ? '-' : '+';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: visuals.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                visuals.icon,
                size: 19,
                color: visuals.color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
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
                  Row(
                    children: [
                      Text(
                        DateFormat('h:mm a').format(item.time),
                        style: const TextStyle(
                          fontFamily: 'DMMono',
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      if (item.accountLast4 != null) ...[
                        const SizedBox(width: 5),
                        const Text(
                          '·',
                          style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'XX${item.accountLast4}',
                          style: const TextStyle(
                            fontFamily: 'DMMono',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                      if (item.status != TransactionStatus.completed) ...[
                        const SizedBox(width: 6),
                        _StatusBadge(status: item.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$amountPrefix₹${NumberFormat('#,##0').format(item.amount)}',
              style: TextStyle(
                fontFamily: 'DMMono',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryVisuals {
  final Color color;
  final IconData icon;

  const _CategoryVisuals({required this.color, required this.icon});
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status == TransactionStatus.pending;
    final color = isPending ? const Color(0xFFF97316) : const Color(0xFFF43F5E);
    final label = isPending ? 'Pending' : 'Failed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
