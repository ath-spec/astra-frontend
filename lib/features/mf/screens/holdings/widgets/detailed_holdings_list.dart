import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'holding_item.dart';
import '../../../../fund_profile/screens/your_fund_profile_screen.dart';

class DetailedHoldingsList extends StatelessWidget {
  final List<HoldingItem> displayHoldings;
  final NumberFormat formatCurrency;
  final String Function(double) formatLargeNumber;

  const DetailedHoldingsList({
    super.key,
    required this.displayHoldings,
    required this.formatCurrency,
    required this.formatLargeNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          HoldingItem item = displayHoldings[index];
          bool isPositive1D = item.oneDayChange >= 0;
          bool isPositiveReturns = item.returns >= 0;
          return GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push( MaterialPageRoute(builder: (_) => const YourFundProfileScreen()));
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Center(
                        child: Icon(Icons.business, color: Colors.grey[400], size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('1D Change: ', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B))),
                              Icon(isPositive1D ? Icons.arrow_upward : Icons.arrow_downward, size: 10, color: isPositive1D ? const Color(0xFF22C55E) : const Color(0xFFEF4444)),
                              Text(
                                '${formatCurrency.format(item.oneDayChange.abs())} (${item.oneDayChangePercent.abs()}%)',
                                style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: isPositive1D ? const Color(0xFF22C55E) : const Color(0xFFEF4444)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Invested', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Text(formatLargeNumber(item.invested), style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Current', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        Text(formatLargeNumber(item.current), style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: const [
                            Text('Returns', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B))),
                            Icon(Icons.unfold_more, size: 12, color: Color(0xFF64748B)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${isPositiveReturns ? '+' : '-'}${formatLargeNumber(item.returns.abs())} (${item.returnsPercent.abs()}%)',
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: isPositiveReturns ? const Color(0xFF22C55E) : const Color(0xFFEF4444)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          );
        },
        childCount: mockHoldings.length,
      ),
    );
  }
}
