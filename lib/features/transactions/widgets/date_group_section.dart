// ============================================================
// FILE: lib/features/transactions/widgets/date_group_section.dart
// One date-header + its transaction rows, for the date-grouped
// transaction lists.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_models.dart';
import 'transaction_row.dart';

class DateGroupSection extends StatelessWidget {
  final TransactionDateGroup group;
  final ValueChanged<TransactionItem>? onTapItem;

  const DateGroupSection({super.key, required this.group, this.onTapItem});

  @override
  Widget build(BuildContext context) {
    final isDown = group.dailyTotal <= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateLabel(group.date).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  '${isDown ? '-' : '+'}₹${NumberFormat('#,##0').format(group.dailyTotal.abs())}',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDown ? const Color(0xFF94A3B8) : const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < group.items.length; i++) ...[
            TransactionRow(item: group.items[i], onTap: () => onTapItem?.call(group.items[i])),
            if (i != group.items.length - 1)
              const Divider(
                height: 1,
                thickness: 0.6,
                indent: 54,
                endIndent: 4,
                color: Color(0xFFE2E8F0),
              ),
          ],
        ],
      ),
    );
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEEE, d MMM').format(date);
  }
}
