import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sort_by_bottom_sheet.dart';
import 'mf_holdings_header.dart';
import '../../../../fund_profile/screens/your_fund_profile_screen.dart';
import 'holding_item.dart';
import 'simple_holdings_list.dart';
import 'detailed_holdings_list.dart';
import 'table_holdings_list.dart';
import 'holding_details_bottom_sheet.dart';



class ConnectedHoldingsView extends StatefulWidget {
  const ConnectedHoldingsView({super.key});

  @override
  State<ConnectedHoldingsView> createState() => _ConnectedHoldingsViewState();
}

class _ConnectedHoldingsViewState extends State<ConnectedHoldingsView> with SingleTickerProviderStateMixin {
  int _viewType = 0; // 0: Simple, 1: Detailed, 2: Table
  
  late AnimationController _animationController;
  late Animation<double> _numberAnimation;
  
  final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final formatCurrencyK = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  
  List<HoldingItem> _displayHoldings = [];
  SortOption? _currentSort;
  Set<String> _activeFilters = {};

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
      _applySort(_currentSort); // This will re-apply sorting AND filtering
    });
  }

  @override
  void initState() {
    super.initState();
    _displayHoldings = List.from(mockHoldings);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _numberAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);
    _animationController.forward();
  }

  void _applySort(SortOption? sortOption) {
    setState(() {
      _currentSort = sortOption;
      
      // 1. Apply filtering
      if (_activeFilters.isEmpty) {
        _displayHoldings = List.from(mockHoldings);
      } else {
        _displayHoldings = mockHoldings.where((item) {
          bool matchesEquity = _activeFilters.contains('Equity') && item.category.contains('Equity');
          bool matchesDebt = _activeFilters.contains('Debt') && item.category.contains('Debt');
          bool matchesGlobal = _activeFilters.contains('Global') && item.category.contains('Global');
          bool matchesSip = _activeFilters.contains('SIP') && item.isSip;
          
          // If the item matches ANY of the active filters, keep it
          return matchesEquity || matchesDebt || matchesGlobal || matchesSip;
        }).toList();
      }

      // 2. Apply sorting
      if (sortOption == null) {
        return;
      }
      
      _displayHoldings.sort((a, b) {
        switch (sortOption) {
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
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(2)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  Widget _buildTopCard() {
    return AnimatedBuilder(
      animation: _numberAnimation,
      builder: (context, child) {
        double investedVal = 299000 * _numberAnimation.value;
        double xirrVal = 9.98 * _numberAnimation.value;
        double returnsVal = 45120 * _numberAnimation.value;
        
        return GestureDetector(
          onTap: () {
            final aggregateItem = HoldingItem(
              name: 'Total Portfolio',
              category: 'All Assets',
              current: investedVal + returnsVal,
              invested: investedVal,
              returns: returnsVal,
              returnsPercent: (returnsVal / investedVal) * 100,
              oneDayChange: 1250.0, // Mock
              oneDayChangePercent: 0.45, // Mock
              xirr: xirrVal,
              logoPath: 'lib/core/images/icici.png', // Mock default
              isSip: false,
            );
            
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.transparent,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {}, // Prevent taps on the card from dismissing
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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
                    children: const [
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
                      Icon(Icons.unfold_more, size: 16, color: Color(0xFF64748B)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatLargeNumber(investedVal),
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
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
                        '${xirrVal.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
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
                      Text(
                        '+${formatLargeNumber(returnsVal)} (15.04%)',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
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
          ),
        ),
        );
      }
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip('Sort by', icon: Icons.sort, onTap: _showSortBottomSheet, isActive: _currentSort != null),
          const SizedBox(width: 8),
          _buildChip('Equity', onTap: () => _toggleFilter('Equity'), isActive: _activeFilters.contains('Equity')),
          const SizedBox(width: 8),
          _buildChip('Debt', onTap: () => _toggleFilter('Debt'), isActive: _activeFilters.contains('Debt')),
          const SizedBox(width: 8),
          _buildChip('Global', onTap: () => _toggleFilter('Global'), isActive: _activeFilters.contains('Global')),
          const SizedBox(width: 8),
          _buildChip('SIP', onTap: () => _toggleFilter('SIP'), isActive: _activeFilters.contains('SIP')),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {IconData? icon, VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? Colors.black : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isActive ? Colors.white : const Color(0xFF0F172A)),
              const SizedBox(width: 6),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Holdings',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 20,
              fontWeight: FontWeight.w400, // Matching the serif-like style roughly
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
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




  Widget _buildTopStickyBar() {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF0F172A)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: AnimatedBuilder(
                    animation: _numberAnimation,
                    builder: (context, child) {
                      return Text(
                        formatCurrency.format(345126 * _numberAnimation.value),
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      );
                    }
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.lock_open_rounded, size: 20, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, size: 20, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          // Subtle details below top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Invested', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFFD1D5DB))),
                Text('Current XIRR', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFFD1D5DB))),
                Text('Total Returns', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFFD1D5DB))),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final double scale = size.width / 375.0;
    final double logicalHeight = (size.height - padding.top - padding.bottom) / scale;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 375,
            height: logicalHeight,
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: HoldingsHeaderDelegate(
                    safeAreaTop: 0, // Handled by SafeArea
                    screenHeight: logicalHeight,
                    hasImportedPortfolio: true,
                  ),
                ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildTopCard(),
                ),
                  
                _buildHeaderRow(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          if (_displayHoldings.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.filter_alt_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 16),
                      const Text(
                        'No holdings found',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
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
            if (_viewType == 0) SimpleHoldingsList(displayHoldings: _displayHoldings, formatCurrency: formatCurrency, formatLargeNumber: formatLargeNumber),
            if (_viewType == 1) DetailedHoldingsList(displayHoldings: _displayHoldings, formatCurrency: formatCurrency, formatLargeNumber: formatLargeNumber),
            if (_viewType == 2) TableHoldingsList(displayHoldings: _displayHoldings, formatCurrency: formatCurrency, formatLargeNumber: formatLargeNumber),
          ],
          
          SliverToBoxAdapter(
            child: const SizedBox(height: 120), // Bottom padding for navigation
          ),
        ],
      ),
    ),
    ),
    ),
    );
  }
}

