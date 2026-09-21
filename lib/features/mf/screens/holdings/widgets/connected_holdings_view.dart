import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sort_by_bottom_sheet.dart';
import 'mf_holdings_header.dart';
import 'holding_item.dart';
import 'simple_holdings_list.dart';
import 'detailed_holdings_list.dart';
import 'table_holdings_list.dart';
import 'holding_details_bottom_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/providers/privacy_provider.dart';
import '../../../../asset_connection/providers/asset_connection_provider.dart';
import '../../../data/mf_holdings_models.dart';
import '../../../data/mf_holdings_providers.dart';
import '../../../../stocks/data/stocks_providers.dart';
import '../../../../stocks/data/stocks_models.dart';

class ConnectedHoldingsView extends ConsumerStatefulWidget {
  const ConnectedHoldingsView({super.key});

  @override
  ConsumerState<ConnectedHoldingsView> createState() => _ConnectedHoldingsViewState();
}

class _ConnectedHoldingsViewState extends ConsumerState<ConnectedHoldingsView>
    with SingleTickerProviderStateMixin {
  int _viewType = 0; // 0: Simple, 1: Detailed, 2: Table

  late AnimationController _animationController;
  late Animation<double> _numberAnimation;

  final formatCurrency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  final formatCurrencyK = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  SortOption? _currentSort;
  final Set<String> _activeFilters = {};
  bool _animationStarted = false;

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _numberAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  /// Applies the active filter chips and current sort option to [source],
  /// returning a new list (does not mutate [source]).
  List<HoldingItem> _filterAndSort(List<HoldingItem> source) {
    List<HoldingItem> result;
    if (_activeFilters.isEmpty) {
      result = List.from(source);
    } else {
      result = source.where((item) {
        bool matchesEquity =
            _activeFilters.contains('Equity') && item.filterBucket == 'Equity';
        bool matchesDebt =
            _activeFilters.contains('Debt') && item.filterBucket == 'Debt';
        bool matchesGlobal =
            _activeFilters.contains('Global') && item.filterBucket == 'Global';
        bool matchesSip = _activeFilters.contains('SIP') && item.isSip;

        // If the item matches ANY of the active filters, keep it
        return matchesEquity || matchesDebt || matchesGlobal || matchesSip;
      }).toList();
    }

    if (_currentSort == null) return result;

    result.sort((a, b) {
      switch (_currentSort!) {
        case SortOption.currentValue:
          return b.current.compareTo(a.current);
        case SortOption.returns:
          return b.returns.compareTo(a.returns);
        case SortOption.xirr:
          return b.xirr.compareTo(a.xirr);
        case SortOption.oneDayChange:
          return b.oneDayChange.compareTo(a.oneDayChange);
        case SortOption.alphabetically:
          return a.name.compareTo(b.name);
      }
    });
    return result;
  }

  void _applySort(SortOption? sortOption) {
    setState(() {
      _currentSort = sortOption;
    });
  }

  void _showSortBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => SortByBottomSheet(currentSort: _currentSort),
    );

    if (result != null && result['applied'] == true) {
      _applySort(result['sort'] as SortOption?);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String formatLargeNumber(double value) {
    final absVal = value.abs();
    final sign = value < 0 ? '-' : '';
    if (absVal >= 100000) {
      return '$sign₹${(absVal / 100000).toStringAsFixed(2)}L';
    } else if (absVal >= 1000) {
      return '$sign₹${(absVal / 1000).toStringAsFixed(2)}K';
    }
    return '$sign₹${absVal.toStringAsFixed(0)}';
  }

  Widget _buildTopCard(bool isLocked, MfHoldingsSummary summary) {
    return AnimatedBuilder(
      animation: _numberAnimation,
      builder: (context, child) {
        double investedVal = summary.investedValue * _numberAnimation.value;
        double xirrVal = summary.xirrPct * _numberAnimation.value;
        double returnsVal = summary.returnsAmount * _numberAnimation.value;

        return GestureDetector(
          onTap: () {
            final aggregateItem = HoldingItem(
              name: 'Total Portfolio',
              category: 'All Assets',
              current: investedVal + returnsVal,
              invested: investedVal,
              returns: returnsVal,
              returnsPercent: summary.returnsPct,
              oneDayChange: summary.oneDayChangeAmount,
              oneDayChangePercent: summary.oneDayChangePct,
              xirr: xirrVal,
              logoPath: 'lib/core/images/icici.png', // Generic default — no logo for the aggregate row
              isSip: false,
              filterBucket: 'Equity',
            );

            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: MediaQuery.sizeOf(context).height,
                  color: Colors.transparent,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {}, // Prevent taps on the card from dismissing
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: HoldingDetailsBottomSheet(
                          item: aggregateItem,
                          formatCurrency: formatCurrency,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: Transform.translate(
            offset: const Offset(0, -42), // Negative margin effect
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Holding details',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.unfold_more,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLocked ? '₹ * * * *' : formatLargeNumber(investedVal),
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Invested',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isLocked ? '* * *' : '${xirrVal.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Current XIRR',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Builder(
                          builder: (context) {
                            final isPos = summary.returnsAmount >= 0;
                            final sign = isPos ? '+' : '-';
                            return Text(
                              isLocked
                                  ? '₹ * * * *'
                                  : '$sign${formatLargeNumber(returnsVal.abs())} (${summary.returnsPct.abs().toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isPos ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Total Returns',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ), // End Column
          ), // End Container
        ), // End Transform.translate
      ); // End GestureDetector
    }, // End builder
  ); // End AnimatedBuilder
}

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(
            'Sort by',
            icon: Icons.sort,
            onTap: _showSortBottomSheet,
            isActive: _currentSort != null,
          ),
          SizedBox(width: 8),
          _buildChip(
            'Equity',
            onTap: () => _toggleFilter('Equity'),
            isActive: _activeFilters.contains('Equity'),
          ),
          SizedBox(width: 8),
          _buildChip(
            'Debt',
            onTap: () => _toggleFilter('Debt'),
            isActive: _activeFilters.contains('Debt'),
          ),
          SizedBox(width: 8),
          _buildChip(
            'Global',
            onTap: () => _toggleFilter('Global'),
            isActive: _activeFilters.contains('Global'),
          ),
          SizedBox(width: 8),
          _buildChip(
            'SIP',
            onTap: () => _toggleFilter('SIP'),
            isActive: _activeFilters.contains('SIP'),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label, {
    IconData? icon,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? Colors.black : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : const Color(0xFF0F172A),
              ),
              SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Holdings',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight:
                  FontWeight.w400, // Matching the serif-like style roughly
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                _buildToggleIcon(Icons.view_agenda_rounded, 0),
                _buildToggleIcon(Icons.view_day_rounded, 1),
                _buildToggleIcon(Icons.table_rows_rounded, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleIcon(IconData icon, int index) {
    bool isSelected = _viewType == index;
    return GestureDetector(
      onTap: () => setState(() => _viewType = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 12,
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  // Currently unused (kept for parity with the design source); would need a
  // [MfHoldingsSummary] passed in if wired up.
  // ignore: unused_element
  Widget _buildTopStickyBar(MfHoldingsSummary summary) {
    final isLocked = ref.watch(privacyProvider);

    return Container(
      color: const Color(0xFFF9FAFB),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top,
        bottom: 8,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: AnimatedBuilder(
                    animation: _numberAnimation,
                    builder: (context, child) {
                      return Text(
                        isLocked ? '₹ * * * *' : formatCurrency.format(summary.currentValue * _numberAnimation.value),
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      );
                    },
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => ref.read(privacyProvider.notifier).state = !isLocked,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                      size: 10,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/cart'),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 10,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Subtle details below top bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invested',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
                Text(
                  'Current XIRR',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
                Text(
                  'Total Returns',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSignedChange(double amount, double pct) {
    final sign = amount >= 0 ? '' : '-';
    return '$sign${formatCurrency.format(amount.abs())} (${pct.toStringAsFixed(2)}%)';
  }

  @override
  Widget build(BuildContext context) {
    final assetState = ref.watch(assetConnectionProvider);
    final isLocked = ref.watch(privacyProvider);
    final holdingsAsync = ref.watch(mfHoldingsProvider);

    return holdingsAsync.when(
      loading: () => const HoldingsSkeletonLoading(),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFFCBD5E1)),
                const SizedBox(height: 12),
                Text(
                  'Could not load your holdings.\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(mfHoldingsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (holdings) {
        if (!_animationStarted) {
          _animationStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _animationController.forward());
        }

        // Load stock holdings and merge them into the unified list.
        // Stock positions come from the separate /api/v1/stocks/holdings endpoint.
        final stocksAsync = ref.watch(stocksHoldingsProvider);
        final stockItems = stocksAsync.value ?? <StockHoldingItem>[];
        final mfItems = holdings.folios.map(HoldingItem.fromFolio).toList();
        final stockHoldingItems = stockItems.map(HoldingItem.fromStock).toList();
        final allHoldings = [...mfItems, ...stockHoldingItems];
        final displayHoldings = _filterAndSort(allHoldings);

        // Build a combined summary that includes stock values on top of MF values.
        final stockCurrentValue = stockItems.fold<double>(0.0, (sum, s) => sum + s.currentValue);
        final stockInvestedValue = stockItems.fold<double>(0.0, (sum, s) => sum + s.investedValue);
        final stockPnl = stockItems.fold<double>(0.0, (sum, s) => sum + s.pnl);
        final stockOneDayChange = stockItems.fold<double>(0.0, (sum, s) => sum + s.oneDayChangeAmount);

        final combinedCurrentValue = holdings.summary.currentValue + stockCurrentValue;
        final combinedInvestedValue = holdings.summary.investedValue + stockInvestedValue;
        final combinedReturns = holdings.summary.returnsAmount + stockPnl;
        final combinedReturnsPct = combinedInvestedValue > 0
            ? (combinedReturns / combinedInvestedValue) * 100
            : 0.0;
        final combinedOneDayChange = holdings.summary.oneDayChangeAmount + stockOneDayChange;
        final combinedOneDayChangePct = (combinedCurrentValue - combinedOneDayChange) > 0
            ? (combinedOneDayChange / (combinedCurrentValue - combinedOneDayChange)) * 100
            : 0.0;

        // Use a synthetic summary that covers both asset classes.
        final summary = MfHoldingsSummary(
          currentValue: combinedCurrentValue,
          investedValue: combinedInvestedValue,
          returnsAmount: combinedReturns,
          returnsPct: combinedReturnsPct,
          xirrPct: holdings.summary.xirrPct,
          oneDayChangeAmount: combinedOneDayChange,
          oneDayChangePct: combinedOneDayChangePct,
          folioCount: holdings.summary.folioCount + stockItems.length,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Builder(
            builder: (context) => SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: HoldingsHeaderDelegate(
                      safeAreaTop: MediaQuery.paddingOf(context).top,
                      screenHeight: MediaQuery.sizeOf(context).height,
                        hasImportedPortfolio: true,
                        isLocked: isLocked,
                        onLockTap: () {
                          ref.read(privacyProvider.notifier).state = !isLocked;
                        },
                        onCartTap: () => context.push('/cart'),
                        onRefreshTap: () => context.push('/mf-fetch-confirm'),
                        mfConnected: assetState.mfConnected,
                        stocksConnected: assetState.stocksConnected,
                        totalValue: summary.currentValue,
                        oneDayChangeText: _formatSignedChange(
                          summary.oneDayChangeAmount,
                          summary.oneDayChangePct,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopCard(isLocked, summary),

                          _buildHeaderRow(),
                          SizedBox(height: 16),
                          _buildFilterChips(),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),

                    if (displayHoldings.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 64.0,
                            horizontal: 24.0,
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.filter_alt_off_rounded,
                                  size: 48,
                                  color: Color(0xFFCBD5E1),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No holdings found',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try adjusting or clearing your filters to see your portfolio.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else ...[
                      if (_viewType == 0)
                        SimpleHoldingsList(
                          displayHoldings: displayHoldings,
                          formatCurrency: formatCurrency,
                          formatLargeNumber: formatLargeNumber,
                          isLocked: isLocked,
                        ),
                      if (_viewType == 1)
                        DetailedHoldingsList(
                          displayHoldings: displayHoldings,
                          formatCurrency: formatCurrency,
                          formatLargeNumber: formatLargeNumber,
                          isLocked: isLocked,
                        ),
                      if (_viewType == 2)
                        TableHoldingsList(
                          displayHoldings: displayHoldings,
                          formatCurrency: formatCurrency,
                          formatLargeNumber: formatLargeNumber,
                          isLocked: isLocked,
                        ),
                    ],

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 120,
                      ), // Bottom padding for navigation
                    ),
                  ],
                ),
              ),
            ),
          );
      },
    );
  }
}
