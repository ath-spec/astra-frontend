import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  DateTime _lastRefreshed = DateTime.now().subtract(const Duration(days: 10));

  String _getLastRefreshedText() {
    final now = DateTime.now();
    final difference = now.difference(_lastRefreshed);
    if (difference.inSeconds < 60) return 'LAST REFRESHED - JUST NOW';
    if (difference.inMinutes < 60) return 'LAST REFRESHED - ${difference.inMinutes} MINS AGO';
    if (difference.inHours < 24) return 'LAST REFRESHED - ${difference.inHours} HOURS AGO';
    return 'LAST REFRESHED - ${difference.inDays} DAYS AGO';
  }


  final List<StockData> _mockStocks = [
    StockData(
      name: 'Mazagon Dock',
      sector: 'Aerospace & Defence',
      allocation: 30.7,
      currentVal: 45540,
      oneDayChange: 2691,
      oneDayChangePct: 6.28,
      quantity: 18,
      ltp: 2530.00,
    ),
    StockData(
      name: 'Cochin Shipyard',
      sector: 'Aerospace & Defence',
      allocation: 30.2,
      currentVal: 44700,
      oneDayChange: 1950,
      oneDayChangePct: 4.56,
      quantity: 30,
      ltp: 1490.00,
    ),
    StockData(
      name: 'Garden Reach Sh.',
      sector: 'Aerospace & Defence',
      allocation: 17.5,
      currentVal: 25994,
      oneDayChange: 921,
      oneDayChangePct: 3.67,
      quantity: 10,
      ltp: 2599.40,
    ),
    StockData(
      name: 'MSTC',
      sector: 'E-Commerce/App based Aggregator',
      allocation: 16.3,
      currentVal: 24208,
      oneDayChange: 73,
      oneDayChangePct: 0.30,
      quantity: 40,
      ltp: 605.20,
    ),
    StockData(
      name: 'Refex Industries',
      sector: 'Trading',
      allocation: 5.0,
      currentVal: 7466,
      oneDayChange: -123,
      oneDayChangePct: -1.62,
      quantity: 22,
      ltp: 339.36,
    ),
    StockData(
      name: 'Nifty Bees',
      sector: 'ETF',
      allocation: 2.3,
      currentVal: 3500,
      oneDayChange: 20,
      oneDayChangePct: 0.57,
      quantity: 15,
      ltp: 233.33,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(privacyProvider);
    
    final filteredStocks = _mockStocks.where((s) {
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
              totalAmount: PrivacyFormatter.obscure('₹1,47,908', isLocked),
              todayChange: PrivacyFormatter.obscure('↑ ₹5,635 (3.96%) today', isLocked),
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
              lastRefreshedText: _getLastRefreshedText(),
              onRefreshTap: () async {
                await context.push('/mf-fetch-confirm');
                if (mounted) {
                  setState(() {
                    _lastRefreshed = DateTime.now();
                  });
                }
              },
              isLocked: isLocked,
              onLockTap: () {
                ref.read(privacyProvider.notifier).state = !isLocked;
              },
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
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildViewToggleIcon(Icons.view_agenda_rounded, ViewMode.summary),
                        SizedBox(width: 4.w),
                        _buildViewToggleIcon(Icons.view_stream_rounded, ViewMode.expanded),
                        SizedBox(width: 4.w),
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
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  _buildChip('Sort by', icon: Icons.sort_rounded, isOutline: true),
                  SizedBox(width: 8.w),
                  _buildChip('Stocks'),
                  SizedBox(width: 8.w),
                  _buildChip('ETFs'),
                  SizedBox(width: 8.w),
                  _buildChip('Gainers'),
                  SizedBox(width: 8.w),
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Static Left Column
          Container(
            width: 140, // Fixed width for STOCKS
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFF1F5F9), width: 1.w)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  height: headerHeight,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        'STOCKS',
                        style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 12, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
                // Rows
                ...filteredStocks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stock = entry.value;
                  return Container(
                    height: rowHeight,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: const Color(0xFFF1F5F9), width: 1.w),
                      ),
                    ),
                    child: Text(
                      stock.name,
                      style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      overflow: TextOverflow.ellipsis,
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
                    return Container(
                      height: rowHeight,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: const Color(0xFFF1F5F9), width: 1.w),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Amount Column
                          Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              PrivacyFormatter.obscure(intl.NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(stock.currentVal), isLocked),
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ),
                          // 1D Column
                          Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                                SizedBox(height: 2.h),
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
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            alignment: Alignment.center,
                            child: Text(
                              PrivacyFormatter.obscure(ltpFormat.format(stock.ltp), isLocked),
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ),
                          // QTY Column
                          Container(
                            width: 80,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            alignment: Alignment.centerRight,
                            child: Text(
                              isLocked ? PrivacyFormatter.cypher : '${stock.quantity}',
                              style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ],
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: isRight ? Alignment.centerRight : (isCenter ? Alignment.center : Alignment.centerLeft),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF0F172A)),
          ),
          SizedBox(width: 4.w),
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6.h),
          decoration: BoxDecoration(
            color: isOutline ? Colors.transparent : (isSelected ? Colors.white : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(4.r),
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
                SizedBox(width: 4.w),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
                            fontSize: 14.sp,
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
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    // Options
                    _buildSortOption('Current Value', setModalState),
                    _buildSortOption('1-Day Change', setModalState),
                    _buildSortOption('Quantity', setModalState),
                    _buildSortOption('Alphabetically', setModalState),
                    SizedBox(height: 32.h),
                    // Apply Button
                    GestureDetector(
                      onTap: () {
                        setState(() {}); // Update main screen
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(4.r), // User requested border radius 4
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
                              fontSize: 14.sp,
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
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.w)),
        ),
        child: Row(
          children: [
            Container(
              width: 14.w, // Reduced size
              height: 14,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r), // User requested border radius 4
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                  width: 1.5.w,
                ),
              ),
            ),
            SizedBox(width: 12.w),
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
