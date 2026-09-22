// ============================================================
// FILE: lib/features/transactions/screens/merchant_transactions_screen.dart
// Date-grouped transaction list filtered to a single merchant.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/responsive/context_responsive.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/shimmer_card_skeleton.dart';
import '../data/transactions_providers.dart';
import '../models/transaction_models.dart';
import '../widgets/date_group_section.dart';
import 'transaction_detail_screen.dart';

class MerchantTransactionsScreen extends ConsumerStatefulWidget {
  final String merchantName;
  final double? totalAmount;

  const MerchantTransactionsScreen({super.key, required this.merchantName, this.totalAmount});

  @override
  ConsumerState<MerchantTransactionsScreen> createState() => _MerchantTransactionsScreenState();
}

class _MerchantTransactionsScreenState extends ConsumerState<MerchantTransactionsScreen> {
  List<TransactionDateGroup>? _groups;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final groups = await ref.read(transactionsRepositoryProvider).fetchGrouped(merchant: widget.merchantName);
      if (!mounted) return;
      setState(() => _groups = groups);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
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
              widget.merchantName,
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
        child: _groups == null && _error == null
            ? ListView(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  AppThemeShimmerCard(height: 72),
                  SizedBox(height: 12),
                  AppThemeShimmerCard(height: 72),
                  SizedBox(height: 12),
                  AppThemeShimmerCard(height: 72),
                ],
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 32, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF94A3B8)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _load,
                          child: const Text(
                            'Retry',
                            style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                        ),
                      ],
                    ),
                  )
                : _groups!.isEmpty
                    ? const Center(
                        child: Text(
                          'No transactions with this merchant',
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
