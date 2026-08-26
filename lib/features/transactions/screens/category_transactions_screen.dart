// ============================================================
// FILE: lib/features/transactions/screens/category_transactions_screen.dart
// Date-grouped transaction list filtered to a single category.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/responsive/context_responsive.dart';
import '../../../core/widgets/responsive_body.dart';
import '../data/transactions_repository.dart';
import '../models/transaction_models.dart';
import '../widgets/date_group_section.dart';
import 'transaction_detail_screen.dart';

class CategoryTransactionsScreen extends StatefulWidget {
  final String categoryName;
  final double? totalAmount;

  const CategoryTransactionsScreen({super.key, required this.categoryName, this.totalAmount});

  @override
  State<CategoryTransactionsScreen> createState() => _CategoryTransactionsScreenState();
}

class _CategoryTransactionsScreenState extends State<CategoryTransactionsScreen> {
  List<TransactionDateGroup>? _groups;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = await TransactionsRepository.instance.fetchGrouped(category: widget.categoryName);
    if (!mounted) return;
    setState(() => _groups = groups);
  }

  @override
  Widget build(BuildContext context) {
    final hPad = context.pageHorizontalPadding;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.categoryName,
              style: const TextStyle(fontFamily: 'DMSans', fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            if (widget.totalAmount != null)
              Text(
                '₹${NumberFormat('#,##0').format(widget.totalAmount)} total',
                style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, color: Color(0xFF64748B)),
              ),
          ],
        ),
      ),
      body: ResponsiveBody(
        child: _groups == null
            ? const Center(child: CircularProgressIndicator())
            : _groups!.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions in this category',
                      style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
                    itemCount: _groups!.length,
                    itemBuilder: (context, index) => DateGroupSection(
                      group: _groups![index],
                      onTapItem: (item) => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TransactionDetailScreen(transactionId: item.id)),
                      ),
                    ),
                  ),
      ),
    );
  }
}
