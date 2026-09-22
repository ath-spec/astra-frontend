import 'package:flutter/material.dart';
import 'package:astra_frontend/features/stocks/data/stocks_models.dart';

/// Mirrors MfFundOverviewCard's exact layout (sector/risk banner + stats
/// card + Show more/less) so the stock and fund profile screens read as the
/// same UI with different content, not two different designs.
class StockOverviewCard extends StatefulWidget {
  final StockProfileDetail data;

  const StockOverviewCard({super.key, required this.data});

  @override
  State<StockOverviewCard> createState() => _StockOverviewCardState();
}

class _StockOverviewCardState extends State<StockOverviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.data.fundamentals;
    final q = widget.data.quote;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company overview',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          // Sector banner — same visual slot as the fund's risk banner.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.category_outlined, size: 14, color: Color(0xFF6366F1)),
                    const SizedBox(width: 8),
                    Text(
                      widget.data.sector.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
                ),
                Text(
                  widget.data.description,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildStatRow('Market Cap', '₹ ${(f.marketCap / 10000000).toStringAsFixed(1)} Cr'),
                _buildDivider(),
                _buildStatRow('P/E Ratio', f.peRatio.toStringAsFixed(2)),
                _buildDivider(),
                _buildStatRow('P/B Ratio', f.pbRatio.toStringAsFixed(2)),
                _buildDivider(),
                _buildStatRow('Dividend Yield', '${f.divYield.toStringAsFixed(2)}%'),
                _buildDivider(),
                _buildStatRow('ROE', '${f.roe.toStringAsFixed(2)}%'),

                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Column(
                    children: [
                      _buildDivider(),
                      _buildStatRow('52W High', '₹ ${f.high52W.toStringAsFixed(2)}'),
                      _buildDivider(),
                      _buildStatRow('52W Low', '₹ ${f.low52W.toStringAsFixed(2)}'),
                      _buildDivider(),
                      _buildStatRow('Exchange', q.exchange),
                      _buildDivider(),
                      _buildStatRow('ISIN', q.isin),
                    ],
                  ),
                  crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isExpanded ? 'Show less' : 'Show more',
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 14,
                              color: const Color(0xFF0F172A),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isMultilineValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isMultilineValue ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              color: Color(0xFF475569),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
    );
  }
}
