import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:astra_frontend/core/utils/fund_name_formatter.dart';
import 'package:astra_frontend/features/dashboard/data/dashboard_models.dart';
import 'package:astra_frontend/features/mf/data/mf_holdings_providers.dart';
import 'package:astra_frontend/features/stocks/data/stocks_providers.dart';

class HomeTodayPortfolioChanges extends ConsumerStatefulWidget {
  final DashboardSummary summary;
  final bool mfConnected;
  final bool stocksConnected;

  const HomeTodayPortfolioChanges({
    super.key,
    required this.summary,
    this.mfConnected = true,
    this.stocksConnected = true,
  });

  @override
  ConsumerState<HomeTodayPortfolioChanges> createState() =>
      _HomeTodayPortfolioChangesState();
}

class _HomeTodayPortfolioChangesState
    extends ConsumerState<HomeTodayPortfolioChanges> {
  bool _showStocks = false;
  bool _sortHighestFirst = true;

  List<Map<String, dynamic>> _getSortedData(
      List<Map<String, dynamic>> source) {
    final list = List<Map<String, dynamic>>.from(source);
    list.sort((a, b) {
      final pctA = (a['pct'] as num).toDouble();
      final pctB = (b['pct'] as num).toDouble();
      final valA = (a['isUp'] as bool) ? pctA : -pctA;
      final valB = (b['isUp'] as bool) ? pctB : -pctB;
      return _sortHighestFirst ? valB.compareTo(valA) : valA.compareTo(valB);
    });
    return list;
  }

  @override
  void initState() {
    super.initState();
    _showStocks = widget.stocksConnected && !widget.mfConnected;
  }

  @override
  void didUpdateWidget(HomeTodayPortfolioChanges oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.mfConnected && widget.stocksConnected) {
      _showStocks = true;
    } else if (widget.mfConnected && !widget.stocksConnected) {
      _showStocks = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mfAsync = ref.watch(mfHoldingsProvider);
    final stocksAsync = ref.watch(stocksHoldingsProvider);

    List<Map<String, dynamic>> mfData = [];
    final folios = mfAsync.valueOrNull?.folios;
    if (folios != null && folios.isNotEmpty) {
      mfData = folios.map((f) {
        final isUp = f.oneDayChangeAmount >= 0;
        return {
          'name': f.schemeName.isNotEmpty ? cleanFundName(f.schemeName) : f.amcName,
          'subtitle': f.category,
          'value': '₹${f.currentValue.round()}',
          'change':
              '₹${f.oneDayChangeAmount.abs().toStringAsFixed(2)} (${f.oneDayChangePct.abs().toStringAsFixed(2)}%)',
          'isUp': isUp,
          'pct': f.oneDayChangePct.abs(),
          'lastPrice': '₹${f.nav}',
          'quantity': '${f.unitsHeld} units',
        };
      }).toList();
    }
    if (mfData.isEmpty) {
      mfData = _mockMfData;
    }

    List<Map<String, dynamic>> stocksData = [];
    final stocks = stocksAsync.valueOrNull;
    if (stocks != null && stocks.isNotEmpty) {
      stocksData = stocks.map((s) {
        final isUp = s.oneDayChangeAmount >= 0;
        return {
          'name': s.tradingSymbol,
          'subtitle': 'Equities',
          'value': '₹${s.currentValue.round()}',
          'change':
              '₹${s.oneDayChangeAmount.abs().toStringAsFixed(2)} (${s.oneDayChangePct.abs().toStringAsFixed(2)}%)',
          'isUp': isUp,
          'pct': s.oneDayChangePct.abs(),
          'lastPrice': '₹${s.lastPrice}',
          'quantity': '${s.quantity} shares',
        };
      }).toList();
    }
    if (stocksData.isEmpty) {
      stocksData = _mockStocksData;
    }

    final sortedMf = _getSortedData(mfData);
    final sortedStocks = _getSortedData(stocksData);

    final totalChange = widget.summary.oneDayChangeAmount != 0
        ? widget.summary.oneDayChangeAmount
        : 778.0;
    final totalPct = widget.summary.oneDayChangePct != 0
        ? widget.summary.oneDayChangePct
        : 0.21;
    final totalIsUp = totalChange >= 0;
    final color = totalIsUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final icon = totalIsUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's portfolio changes",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 12, color: color),
                      const SizedBox(width: 4),
                      Text(
                        '${totalIsUp ? '+' : '-'} ₹ ${totalChange.abs().round()} (${totalPct.abs().toStringAsFixed(2)}%)',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'MARKET OPEN',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomPaint(
          size: const Size(double.infinity, 1),
          painter: _DottedLinePainter(),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 360;
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(
                        title: 'MUTUAL FUNDS',
                        isActive: !_showStocks,
                        onTap: () => setState(() => _showStocks = false),
                        isSmall: isSmall,
                      ),
                      _buildTabButton(
                        title: 'STOCKS',
                        isActive: _showStocks,
                        onTap: () => setState(() => _showStocks = true),
                        isSmall: isSmall,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _buildActionTabButton(
                  _sortHighestFirst ? 'HIGHEST' : 'LOWEST',
                  isSmall,
                  onTap: () => setState(
                      () => _sortHighestFirst = !_sortHighestFirst),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth * 0.44;
            return SizedBox(
              height: 154,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Container(
                  key: ValueKey<bool>(_showStocks),
                  child: ListView.separated(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount:
                        _showStocks ? sortedStocks.length : sortedMf.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final data =
                          _showStocks ? sortedStocks[index] : sortedMf[index];
                      return _ChangeCard(data: data, width: cardWidth);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabButton(
      {required String title,
      required bool isActive,
      required VoidCallback onTap,
      bool isSmall = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.symmetric(horizontal: isSmall ? 10 : 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
          child: Text(title),
        ),
      ),
    );
  }

  Widget _buildActionTabButton(String title, bool isSmall,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: isSmall ? 10 : 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert_rounded, size: 13, color: const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final double width;

  const _ChangeCard({required this.data, this.width = 160});

  @override
  Widget build(BuildContext context) {
    final bool isUp = data['isUp'] as bool;
    final color = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return GestureDetector(
      onTap: () {
        context.push('/asset-today-change', extra: data);
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Center(
                child: Text(
                  (data['name'] as String).substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              data['name'],
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              data['value'],
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 10, color: color),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      data['change'],
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const _mockMfData = [
  {
    'name': 'HDFC Silver ETF FoF',
    'subtitle': 'Commodities',
    'value': '₹196',
    'change': '₹5.07 (2.64%)',
    'isUp': true,
    'pct': 2.64,
    'lastPrice': '₹12.4',
    'quantity': '15.8 units',
  },
  {
    'name': 'Quantum Gold ETF FoF',
    'subtitle': 'Commodities',
    'value': '₹1,04,470',
    'change': '₹968.69 (0.93%)',
    'isUp': true,
    'pct': 0.93,
    'lastPrice': '₹1,245.3',
    'quantity': '83.9 units',
  },
  {
    'name': 'Tata Gold ETF FoF',
    'subtitle': 'Commodities',
    'value': '₹9,858',
    'change': '₹81.44 (0.83%)',
    'isUp': true,
    'pct': 0.83,
    'lastPrice': '₹420.1',
    'quantity': '23.4 units',
  },
  {
    'name': 'Canara Robeco Large Cap Fund',
    'subtitle': 'Large Cap Equity',
    'value': '₹2,38,680',
    'change': '₹811.17 (0.33%)',
    'isUp': false,
    'pct': 0.33,
    'lastPrice': '₹4,562.9',
    'quantity': '52.3 units',
  }
];

const _mockStocksData = [
  {
    'name': 'Cochin Shipyard',
    'subtitle': 'Aerospace & Defence',
    'value': '₹45,591',
    'change': '₹891 (1.99%)',
    'isUp': true,
    'pct': 1.99,
    'lastPrice': '₹1,519.7',
    'quantity': '30 shares',
  },
  {
    'name': 'Garden Reach Sh.',
    'subtitle': 'Aerospace & Defence',
    'value': '₹25,990',
    'change': '₹4 (0.01%)',
    'isUp': false,
    'pct': 0.01,
    'lastPrice': '₹1,856.4',
    'quantity': '14 shares',
  },
  {
    'name': 'Mazagon Dock',
    'subtitle': 'Aerospace & Defence',
    'value': '₹45,268',
    'change': '₹271.79 (0.59%)',
    'isUp': false,
    'pct': 0.59,
    'lastPrice': '₹4,526.8',
    'quantity': '10 shares',
  },
  {
    'name': 'Refex Industries',
    'subtitle': 'Industrial Gases & Fuels',
    'value': '₹7,322',
    'change': '₹143.75 (1.92%)',
    'isUp': false,
    'pct': 1.92,
    'lastPrice': '₹366.1',
    'quantity': '20 shares',
  },
  {
    'name': 'MSTC',
    'subtitle': 'Trading',
    'value': '₹23,650',
    'change': '₹558 (2.3%)',
    'isUp': false,
    'pct': 2.3,
    'lastPrice': '₹946.0',
    'quantity': '25 shares',
  },
];
