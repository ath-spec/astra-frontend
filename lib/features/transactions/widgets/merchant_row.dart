// ============================================================
// FILE: lib/features/transactions/widgets/merchant_row.dart
// One row in the Transactions screen's "Merchants" tab.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/merchant_logo_avatar.dart';
import '../models/transaction_models.dart';

class MerchantRow extends StatelessWidget {
  final MerchantSummary summary;
  final VoidCallback? onTap;

  const MerchantRow({super.key, required this.summary, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            MerchantLogoAvatar(
              merchantName: summary.merchant,
              category: '',
              size: 40,
              borderRadius: 12,
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
                      fontSize: 13,
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
                fontFamily: 'DMSans',
                fontSize: 13,
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
