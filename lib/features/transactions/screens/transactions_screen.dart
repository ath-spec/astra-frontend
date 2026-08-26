// ============================================================
// FILE: lib/features/transactions/screens/transactions_screen.dart
// Main Transactions hub: Transactions / Categories / Merchants,
// switched by TypeSwitcherPill.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/responsive/context_responsive.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/unconnected_bank_empty_state.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';
import '../data/transactions_repository.dart';
import '../models/transaction_models.dart';
import '../widgets/type_switcher_pill.dart';
import '../widgets/date_group_section.dart';
import '../widgets/category_row.dart';
import '../widgets/merchant_row.dart';
import 'category_transactions_screen.dart';
import 'merchant_transactions_screen.dart';
import 'transaction_detail_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _repo = TransactionsRepository.instance;

  int _selectedTab = 0;
  List<TransactionDateGroup>? _groups;
  List<CategorySummary>? _categories;
  List<MerchantSummary>? _merchants;
  bool _demoMode = false;

  @override
  void initState() {
    super.initState();
    _loadTab(0);
  }

  Future<void> _loadTab(int index) async {
    switch (index) {
      case 0:
        final groups = await _repo.fetchGrouped();
        if (!mounted) return;
        setState(() => _groups = groups);
        break;
      case 1:
        final categories = await _repo.fetchCategories();
        if (!mounted) return;
        setState(() => _categories = categories);
        break;
      case 2:
        final merchants = await _repo.fetchMerchants();
        if (!mounted) return;
        setState(() => _merchants = merchants);
        break;
    }
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTab = index);
    final alreadyLoaded = switch (index) {
      0 => _groups != null,
      1 => _categories != null,
      2 => _merchants != null,
      _ => true,
    };
    if (!alreadyLoaded) _loadTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final hPad = context.pageHorizontalPadding;
    final assetState = ref.watch(assetConnectionProvider);
    final isBankConnected = assetState.banksConnected || _demoMode;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Transactions',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: ResponsiveBody(
        child: !isBankConnected
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Center(
                  child: UnconnectedBankEmptyState(
                    title: 'No Bank Account Connected',
                    description:
                        'Connect your bank account to automatically aggregate and view all your UPI payments, debits, and merchant transactions.',
                    onDemoTap: () => setState(() => _demoMode = true),
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 12),
                    child: TypeSwitcherPill(selectedIndex: _selectedTab, onChanged: _onTabChanged),
                  ),
                  Expanded(
                    child: switch (_selectedTab) {
                      0 => _buildTransactionsTab(hPad),
                      1 => _buildCategoriesTab(hPad),
                      _ => _buildMerchantsTab(hPad),
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTransactionsTab(double hPad) {
    final groups = _groups;
    if (groups == null) return const Center(child: CircularProgressIndicator());
    if (groups.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No transactions yet',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTab(0),
      color: const Color(0xFF0F172A),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: groups.length,
        itemBuilder: (context, index) => DateGroupSection(
          group: groups[index],
          onTapItem: (item) => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TransactionDetailScreen(transactionId: item.id)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(double hPad) {
    final categories = _categories;
    if (categories == null) return const Center(child: CircularProgressIndicator());
    if (categories.isEmpty) {
      return const _EmptyState(
        icon: Icons.category_outlined,
        message: 'No categories yet',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTab(1),
      color: const Color(0xFF0F172A),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 32),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: categories.length,
        separatorBuilder: (_, index) => const Divider(
          height: 1,
          thickness: 0.6,
          indent: 54,
          endIndent: 4,
          color: Color(0xFFE2E8F0),
        ),
        itemBuilder: (context, index) => CategoryRow(
          summary: categories[index],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryTransactionsScreen(
                categoryName: categories[index].category,
                totalAmount: categories[index].totalAmount,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantsTab(double hPad) {
    final merchants = _merchants;
    if (merchants == null) return const Center(child: CircularProgressIndicator());
    if (merchants.isEmpty) {
      return const _EmptyState(
        icon: Icons.storefront_outlined,
        message: 'No merchants yet',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTab(2),
      color: const Color(0xFF0F172A),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 32),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: merchants.length,
        separatorBuilder: (_, index) => const Divider(
          height: 1,
          thickness: 0.6,
          indent: 54,
          endIndent: 4,
          color: Color(0xFFE2E8F0),
        ),
        itemBuilder: (context, index) => MerchantRow(
          summary: merchants[index],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MerchantTransactionsScreen(
                merchantName: merchants[index].merchant,
                totalAmount: merchants[index].totalAmount,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
