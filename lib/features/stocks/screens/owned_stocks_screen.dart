import '../data/stocks_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/privacy_provider.dart';
import '../../../core/utils/privacy_formatter.dart';
import '../widgets/stocks_header.dart';
import '../widgets/stock_card.dart';
import 'package:intl/intl.dart' as intl;

class StocksScreen extends ConsumerStatefulWidget {
  const StocksScreen({super.key});

  @override
  ConsumerState<StocksScreen> createState() => _StocksScreenState();
}

enum ViewMode { summary, expanded, table }

class _StocksScreenState extends ConsumerState<StocksScreen> {
    ViewMode _viewMode = ViewMode.summary;

  final Set<String> _activeFilters = {'Stocks'};
  String _activeSort = 'Current Value';

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(privacyProvider);
    final holdingsAsync = ref.watch(stocksHoldingsProvider);

    List<StockData> stockList = [];
    double totalWealth = 0.0;
    double total1DChange = 0.0;

    if (holdingsAsync.hasValue && holdingsAsync.value!.isNotEmpty) {
      final holdings = holdingsAsync.value!;
      totalWealth = holdings.fold<double>(0.0, (acc, h) => acc + h.currentValue);
      total1DChange = holdings.fold<double>(0.0, (acc, h) => acc + h.oneDayChangeAmount);
      stockList = holdings.map((h) {
        final alloc = totalWealth > 0 ? (h.currentValue / totalWealth * 100) : 0.0;
        return StockData(
          name: h.tradingSymbol,
          sector: h.tradingSymbol.contains("BEES") || h.tradingSymbol.contains("ETF") ? "ETF" : "Equity",
          allocation: double.parse(alloc.toStringAsFixed(1)),
          currentVal: h.currentValue,
          oneDayChange: h.oneDayChangeAmount,
          oneDayChangePct: double.parse(h.oneDayChangePct.toStringAsFixed(2)),
          quantity: h.quantity,
          ltp: h.lastPrice,
        );
      }).toList();
    }
    // A failed fetch (network error, auth hiccup) used to silently swap in
    // _mockStocks here — a fixed list of made-up holdings (Mazagon Dock,
    // Cochin Shipyard, ...) with their own fake total wealth and no
    // indication anything had gone wrong. That's a real portfolio screen
    // showing fabricated numbers with no error, which is worse than an
    // empty state: the user has no way to tell it's not their real data.
    // holdingsAsync.hasError now drives a proper retry banner below instead.

    final double total1DPct = (totalWealth - total1DChange) > 0
        ? (total1DChange / (totalWealth - total1DChange) * 100)
        : 0.0;
    final bool is1DPositive = total1DChange >= 0;
    final String liveTotalStr = '₹${intl.NumberFormat('#,##,###').format(totalWealth.round())}';
    final String live1DStr = '${is1DPositive ? '↑' : '↓'} ₹${intl.NumberFormat('#,##,###').format(total1DChange.abs().round())} (${total1DPct.abs().toStringAsFixed(2)}%) today';
    
    final filteredStocks = stockList.where((s) {
      bool passType = true;
      bool passPerformance = true;

      final hasStocks = _activeFilters.contains('Stocks');
      final hasEtfs = _activeFilters.contains('ETFs');
      if (hasStocks || hasEtfs) {
        if (hasStocks && hasEtfs) {
          passType = true;
        } else if (hasStocks) {
          passType = s.sector != 'ETF';
        } else if (hasEtfs) {
          passType = s.sector == 'ETF';
        }
      }

      final hasGainers = _activeFilters.contains('Gainers');
      final hasLosers = _activeFilters.contains('Losers');
      if (hasGainers || hasLosers) {
        if (hasGainers && hasLosers) {
          passPerformance = true;
        } else if (hasGainers) {
          passPerformance = s.oneDayChange >= 0;
        } else if (hasLosers) {
          passPerformance = s.oneDayChange < 0;
        }
      }

      return passType && passPerformance;
    }).toList();

    filteredStocks.sort((a, b) {
      if (_activeSort == 'Current Value') {
        return b.currentVal.compareTo(a.currentVal);
      } else if (_activeSort == '1-Day Change') {
        return b.oneDayChangePct.compareTo(a.oneDayChangePct);
      } else if (_activeSort == 'Quantity') {
        return b.quantity.compareTo(a.quantity);
      } else if (_activeSort == 'Alphabetically') {
        return a.name.compareTo(b.name);
      }
      return 0;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: StocksHeaderDelegate(
              safeAreaTop: MediaQuery.paddingOf(context).top,
              totalAmount: PrivacyFormatter.obscure(liveTotalStr, isLocked),
              todayChange: PrivacyFormatter.obscure(live1DStr, isLocked),
              onBackTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              onAddAccountsTap: () {
                context.push('/aa-stocks-otp', extra: {'isOnboarding': false});
              },
              isLocked: isLocked,
              onLockTap: () {
                ref.read(privacyProvider.notifier).state = !isLocked;
              },
            ),
          ),
          
          // Fetch failed: a real error banner with retry, instead of the
          // fabricated holdings list this screen used to substitute in
          // silently (see the comment above where stockList is built).
          if (holdingsAsync.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Couldn't load your holdings.",
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF991B1B)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref.invalidate(stocksHoldingsProvider),
                        child: const Text(
                          'RETRY',
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Section Title & View Toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Holdings',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildViewToggleIcon(Icons.view_agenda_rounded, ViewMode.summary),
                        SizedBox(width: 4),
                        _buildViewToggleIcon(Icons.view_stream_rounded, ViewMode.expanded),
                        SizedBox(width: 4),
                        _buildViewToggleIcon(Icons.grid_view_rounded, ViewMode.table),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Chips Row
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildChip('Sort by', icon: Icons.sort_rounded, isOutline: true),
                  SizedBox(width: 8),
                  _buildChip('Stocks'),
                  SizedBox(width: 8),
                  _buildChip('ETFs'),
                  SizedBox(width: 8),
                  _buildChip('Gainers'),
                  SizedBox(width: 8),
                  _buildChip('Losers'),
                ],
              ),
            ),
          ),
          
          // List Header or Table Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: const Cubic(0.23, 1.0, 0.32, 1.0),
                switchOutCurve: const Cubic(0.23, 1.0, 0.32, 1.0),
                child: _viewMode == ViewMode.table
                    ? SizedBox.shrink()
                    : _buildListHeader(),
              ),
            ),
          ),

          // Holdings Content
          SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 40 + MediaQuery.paddingOf(context).bottom),
            sliver: _viewMode == ViewMode.table
                ? SliverToBoxAdapter(
                    child: _buildUnifiedTable(filteredStocks, isLocked),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return StockCard(
                          stock: filteredStocks[index],
                          forceExpanded: _viewMode == ViewMode.expanded,
                          isLocked: isLocked,
                        );
                      },
                      childCount: filteredStocks.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      key: const ValueKey('listHeader'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _activeFilters.isEmpty ? 'ALL HOLDINGS' : _activeFilters.join(', ').toUpperCase(),
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildUnifiedTable(List<StockData> filteredStocks, bool isLocked) {
    final ltpFormat = intl.NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    
    const double rowHeight = 72.0;
    const double headerHeight = 40.0;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Static Left Column
          Container(
            width: 140, // Fixed width for STOCKS
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  height: headerHeight,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        'STOCKS',
                        style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 12, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
                // Rows — table view previously had no tap handling on rows
                // at all (unlike Summary/Expanded view's StockCard, which
                // toggles an inline expand). Tapping a row here switches to
                // that same expanded card view instead of inventing a new
                // detail screen.
                ...filteredStocks.map((stock) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _viewMode = ViewMode.expanded),
                    child: Container(
                      height: rowHeight,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: const Color(0xFFF1F5F9), width: 1),
                        ),
                      ),
                      child: Text(
                        stock.name,
                        style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Scrollable Right Section
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  SizedBox(
                    height: headerHeight,
                    child: Row(
                      children: [
                        _buildTableHeaderCell('AMOUNT', 100),
                        _buildTableHeaderCell('1D', 100),
                        _buildTableHeaderCell('LTP', 100, isCenter: true),
                        _buildTableHeaderCell('QTY', 80, isRight: true),
                      ],
                    ),
                  ),
                  // Rows
                  ...filteredStocks.asMap().entries.map((entry) {
                    final stock = entry.value;
                    final isPositive = stock.oneDayChange >= 0;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _viewMode = ViewMode.expanded),
                      child: Container(
                      height: rowHeight,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: const Color(0xFFF1F5F9), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Amount Column
                          Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              PrivacyFormatter.obscure(intl.NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(stock.currentVal), isLocked),
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ),
                          // 1D Column
                          Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLocked ? PrivacyFormatter.cypher : '${isPositive ? '↑ ' : '↓ '}₹${stock.oneDayChange.abs().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  isLocked ? PrivacyFormatter.cypher : '(${stock.oneDayChangePct}%)',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // LTP Column
                          Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            child: Text(
                              PrivacyFormatter.obscure(ltpFormat.format(stock.ltp), isLocked),
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ),
                          // QTY Column
                          Container(
                            width: 80,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerRight,
                            child: Text(
                              isLocked ? PrivacyFormatter.cypher : '${stock.quantity}',
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ],
                      ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String title, double width, {bool isRight = false, bool isCenter = false}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 16),
      alignment: isRight ? Alignment.centerRight : (isCenter ? Alignment.center : Alignment.centerLeft),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF0F172A)),
          ),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 12, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildViewToggleIcon(IconData icon, ViewMode mode) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _viewMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: const Cubic(0.23, 1.0, 0.32, 1.0),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildChip(String label, {IconData? icon, bool isOutline = false}) {
    final isSelected = isOutline ? false : _activeFilters.contains(label);
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (label == 'Sort by') {
          _showSortByBottomSheet(context);
          return;
        }
        if (!isOutline) {
          setState(() {
            if (_activeFilters.contains(label)) {
              _activeFilters.remove(label);
            } else {
              _activeFilters.add(label);
            }
          });
        }
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isOutline ? 1.0 : (isSelected ? 1.0 : 0.6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: const Cubic(0.23, 1.0, 0.32, 1.0),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isOutline ? Colors.transparent : (isSelected ? Colors.white : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isOutline ? const Color(0xFFE2E8F0) : (isSelected ? const Color(0xFFE2E8F0) : Colors.transparent),
            ),
            boxShadow: isSelected && !isOutline ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Color(0xFF0F172A)),
                SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isOutline ? const Color(0xFF0F172A) : (isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortByBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sort by',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _activeSort = 'Current Value';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Options
                    _buildSortOption('Current Value', setModalState),
                    _buildSortOption('1-Day Change', setModalState),
                    _buildSortOption('Quantity', setModalState),
                    _buildSortOption('Alphabetically', setModalState),
                    SizedBox(height: 32),
                    // Apply Button
                    GestureDetector(
                      onTap: () {
                        setState(() {}); // Update main screen
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(4), // User requested border radius 4
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Apply',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(String label, StateSetter setModalState) {
    final isSelected = _activeSort == label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setModalState(() {
          _activeSort = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 14, // Reduced size
              height: 14,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                borderRadius: BorderRadius.circular(4), // User requested border radius 4
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10, // Reduced text size
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
