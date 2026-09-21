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
import '../../../core/widgets/shimmer_card_skeleton.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';
import '../../dashboard/data/dashboard_providers.dart';
import '../data/transactions_providers.dart';
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
  int _selectedTab = 0;
  List<TransactionDateGroup>? _groups;
  List<CategorySummary>? _categories;
  List<MerchantSummary>? _merchants;
  String? _groupsError;
  String? _categoriesError;
  String? _merchantsError;
  bool _demoMode = false;

  @override
  void initState() {
    super.initState();
    _loadTab(0);
  }

  Future<void> _loadTab(int index) async {
    final repo = ref.read(transactionsRepositoryProvider);
    switch (index) {
      case 0:
        setState(() => _groupsError = null);
        try {
          final groups = await repo.fetchGrouped();
          if (!mounted) return;
          setState(() => _groups = groups);
        } catch (e) {
          if (!mounted) return;
          setState(() => _groupsError = e.toString());
        }
        break;
      case 1:
        setState(() => _categoriesError = null);
        try {
          final categories = await repo.fetchCategories();
          if (!mounted) return;
          setState(() => _categories = categories);
        } catch (e) {
          if (!mounted) return;
          setState(() => _categoriesError = e.toString());
        }
        break;
      case 2:
        setState(() => _merchantsError = null);
        try {
          final merchants = await repo.fetchMerchants();
          if (!mounted) return;
          setState(() => _merchants = merchants);
        } catch (e) {
          if (!mounted) return;
          setState(() => _merchantsError = e.toString());
        }
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
    // Same fallback as AnalyticsScreen: don't trust the locally-cached
    // banksConnected flag alone — OR it against the live backend truth so a
    // stale/unrefreshed local flag can never hide a real connection.
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    final backendConfirmedBankConnected = dashboardAsync.maybeWhen(
      data: (s) => s.bankBalancePresent,
      orElse: () => false,
    );
    final isBankConnected =
        assetState.banksConnected || backendConfirmedBankConnected || _demoMode;

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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      switchInCurve: const Cubic(0.23, 1.0, 0.32, 1.0),
                      switchOutCurve: const Cubic(0.23, 1.0, 0.32, 1.0),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_selectedTab),
                        child: switch (_selectedTab) {
                          0 => _buildTransactionsTab(hPad),
                          1 => _buildCategoriesTab(hPad),
                          _ => _buildMerchantsTab(hPad),
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTransactionsTab(double hPad) {
    final groups = _groups;
    if (groups == null && _groupsError == null) {
      return _LoadingSkeleton(hPad: hPad);
    }
    if (_groupsError != null) {
      return _ErrorState(message: _groupsError!, onRetry: () => _loadTab(0));
    }
    if (groups!.isEmpty) {
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
    if (categories == null && _categoriesError == null) {
      return _LoadingSkeleton(hPad: hPad);
    }
    if (_categoriesError != null) {
      return _ErrorState(message: _categoriesError!, onRetry: () => _loadTab(1));
    }
    if (categories!.isEmpty) {
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
    if (merchants == null && _merchantsError == null) {
      return _LoadingSkeleton(hPad: hPad);
    }
    if (_merchantsError != null) {
      return _ErrorState(message: _merchantsError!, onRetry: () => _loadTab(2));
    }
    if (merchants!.isEmpty) {
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

class _LoadingSkeleton extends StatelessWidget {
  final double hPad;

  const _LoadingSkeleton({required this.hPad});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        AppThemeShimmerCard(height: 72),
        SizedBox(height: 12),
        AppThemeShimmerCard(height: 72),
        SizedBox(height: 12),
        AppThemeShimmerCard(height: 72),
        SizedBox(height: 12),
        AppThemeShimmerCard(height: 72),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 36, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
          ),
        ],
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
