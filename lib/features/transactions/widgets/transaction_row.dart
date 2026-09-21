// ============================================================
// FILE: lib/features/transactions/widgets/transaction_row.dart
// A single transaction row — reused by TransactionsScreen,
// CategoryTransactionsScreen and MerchantTransactionsScreen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/merchant_logo_avatar.dart';
import '../models/transaction_models.dart';

class TransactionRow extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback? onTap;

  const TransactionRow({super.key, required this.item, this.onTap});  @override
  Widget build(BuildContext context) {
    final isDebit = item.isDebit;
    final amountColor = isDebit ? const Color(0xFF0F172A) : const Color(0xFF16A34A);
    final amountPrefix = isDebit ? '-' : '+';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
        child: Row(
          children: [
            MerchantLogoAvatar(
              merchantName: item.title,
              logoKey: item.merchant,
              category: item.category,
              size: 40,
              borderRadius: 4,
              isDebit: item.isDebit,
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
                      fontSize: 13,
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
                          fontFamily: 'DMSans',
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
                            fontFamily: 'DMSans',
                            fontSize: 10,
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
                fontFamily: 'DMSans',
                fontSize: 13,
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
