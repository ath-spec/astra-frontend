// ============================================================
// FILE: lib/features/transactions/widgets/merchant_row.dart
// One row in the Transactions screen's "Merchants" tab.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_models.dart';

class MerchantRow extends StatelessWidget {
  final MerchantSummary summary;
  final VoidCallback? onTap;

  const MerchantRow({super.key, required this.summary, this.onTap});

  Color _getMerchantColor(String name) {
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFFF97316),
      Color(0xFF10B981),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
    ];
    if (name.isEmpty) return const Color(0xFF64748B);
    final idx = name.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final color = _getMerchantColor(summary.merchant);
    final initial = summary.merchant.isNotEmpty ? summary.merchant[0].toUpperCase() : '?';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    summary.merchant,
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
