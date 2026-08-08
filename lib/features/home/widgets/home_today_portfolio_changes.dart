import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeTodayPortfolioChanges extends StatefulWidget {
  final bool mfConnected;
  final bool stocksConnected;

  const HomeTodayPortfolioChanges({
    super.key,
    required this.mfConnected,
    required this.stocksConnected,
  });

  @override
  State<HomeTodayPortfolioChanges> createState() => _HomeTodayPortfolioChangesState();
}

class _HomeTodayPortfolioChangesState extends State<HomeTodayPortfolioChanges> {
  bool _showStocks = false;
  bool _sortHighestFirst = true;

  List<Map<String, dynamic>> _getSortedData(List<Map<String, dynamic>> source) {
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
    if (!widget.mfConnected && !widget.stocksConnected) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s portfolio changes',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.0,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total 1D Change',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFF22C55E)),
                      const SizedBox(width: 2),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF22C55E),
                          ),
                          children: [
                            TextSpan(text: '0.03% '),
                            TextSpan(text: '(₹157)', style: TextStyle(color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: const Color(0xFFE2E8F0),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nifty 50',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFFEF4444)),
                    const SizedBox(width: 2),
                    const Text(
                      '-0.26%',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Dotted divider
        CustomPaint(
          size: const Size(double.infinity, 1),
          painter: _DottedLinePainter(),
        ),
        const SizedBox(height: 16),
        // Tabs
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.sizeOf(context).width;
            final isSmallScreen = screenWidth < 360 || constraints.maxWidth < 320;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.mfConnected)
                      _buildTabButton(
                        title: isSmallScreen ? 'MF' : 'MUTUAL FUNDS',
                        isActive: !_showStocks,
                        onTap: () => setState(() => _showStocks = false),
                        isSmall: isSmallScreen,
                      ),
                    if (widget.mfConnected && widget.stocksConnected) SizedBox(width: isSmallScreen ? 4 : 8),
                    if (widget.stocksConnected)
                      _buildTabButton(
                        title: 'STOCKS',
                        isActive: _showStocks,
                        onTap: () => setState(() => _showStocks = true),
                        isSmall: isSmallScreen,
                      ),
                  ],
                ),
                _buildActionTabButton(
                  isSmallScreen 
                    ? (_sortHighestFirst ? '% ↑' : '% ↓') 
                    : (_sortHighestFirst ? '% CHANGE ↑' : '% CHANGE ↓'),
                  isSmallScreen,
                  onTap: () {
                    setState(() {
                      _sortHighestFirst = !_sortHighestFirst;
                    });
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        // Horizontally scrolling cards
        LayoutBuilder(
          builder: (context, constraints) {
            final mfData = _getSortedData(_mockMfData);
            final stocksData = _getSortedData(_mockStocksData);
            final cardWidth = (constraints.maxWidth * 0.42).clamp(140.0, 180.0);
            
            return SizedBox(
              height: 156, // Increased from 140 to prevent overflow on 2-line names
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Container(
                  key: ValueKey<bool>(_showStocks),
                  child: ListView.separated(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _showStocks ? stocksData.length : mfData.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final data = _showStocks ? stocksData[index] : mfData[index];
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

  Widget _buildTabButton({required String title, required bool isActive, required VoidCallback onTap, bool isSmall = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withAlpha(0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFE2E8F0) : const Color(0xFFE2E8F0).withAlpha(0),
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
          child: Text(title),
        ),
      ),
    );
  }

  Widget _buildActionTabButton(String title, bool isSmall, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Color(0xFF0F172A),
          ),
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
    final color = isUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final icon = isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return GestureDetector(
      onTap: () {
        context.push('/asset-today-change', extra: data);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(
                (data['name'] as String).substring(0, 1),
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
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
              color: Color(0xFF334155),
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
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 2),
              Text(
                data['change'],
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
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
