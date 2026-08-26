// ============================================================
// FILE: lib/features/transactions/screens/transaction_detail_screen.dart
// Key-value detail card for a single transaction.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/responsive/context_responsive.dart';
import '../../../core/widgets/responsive_body.dart';
import '../data/transactions_repository.dart';
import '../models/transaction_models.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  TransactionDetail? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail = await TransactionsRepository.instance.fetchDetail(widget.transactionId);
    if (!mounted) return;
    setState(() => _detail = detail);
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Transaction details',
          style: TextStyle(fontFamily: 'DMSans', fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
      ),
      body: ResponsiveBody(
        child: detail == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(context.pageHorizontalPadding, 8, context.pageHorizontalPadding, 32),
              children: [
                _AmountHeader(detail: detail),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE6E6E6)),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(label: 'Category', value: detail.category),
                      if (detail.subcategory != null) _DetailRow(label: 'Subcategory', value: detail.subcategory!),
                      if (detail.merchantName != null) _DetailRow(label: 'Merchant', value: detail.merchantName!),
                      if (detail.merchantCategory != null)
                        _DetailRow(label: 'Merchant category', value: detail.merchantCategory!),
                      if (detail.description != null) _DetailRow(label: 'Description', value: detail.description!),
                      _DetailRow(label: 'Date', value: DateFormat('d MMM yyyy').format(detail.transactionDate)),
                      _DetailRow(label: 'Time', value: DateFormat('h:mm a').format(detail.transactionDate)),
                      if (detail.bankName != null) _DetailRow(label: 'Bank', value: detail.bankName!),
                      if (detail.accountNumberMasked != null)
                        _DetailRow(label: 'Account', value: detail.accountNumberMasked!),
                      if (detail.referenceNumber != null)
                        _DetailRow(label: 'Reference number', value: detail.referenceNumber!, isLast: true),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class _AmountHeader extends StatelessWidget {
  final TransactionDetail detail;

  const _AmountHeader({required this.detail});

  @override
  Widget build(BuildContext context) {
    final amountColor = detail.isDebit ? const Color(0xFF0F172A) : const Color(0xFF16A34A);
    final prefix = detail.isDebit ? '-' : '+';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0F172A),
      ),
      child: Column(
        children: [
          Text(
            '$prefix₹${NumberFormat('#,##0.00').format(detail.amount)}',
            style: TextStyle(fontFamily: 'DMSans', fontSize: 26, fontWeight: FontWeight.w700, color: amountColor == const Color(0xFF0F172A) ? Colors.white : amountColor),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(detail.status).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(detail.status),
              style: TextStyle(fontFamily: 'DMSans', fontSize: 11.5, fontWeight: FontWeight.w700, color: _statusColor(detail.status)),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return const Color(0xFF4ADE80);
      case TransactionStatus.pending:
        return const Color(0xFFFBBF24);
      case TransactionStatus.failed:
        return const Color(0xFFF87171);
    }
  }

  String _statusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Failed';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF64748B)),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}
