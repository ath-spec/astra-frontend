import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'holding_item.dart';
import '../../../../fund_profile/screens/your_fund_profile_screen.dart';

class SimpleHoldingsList extends StatelessWidget {
  final List<HoldingItem> displayHoldings;
  final NumberFormat formatCurrency;
  final bool isLocked;
  final String Function(double) formatLargeNumber;

  const SimpleHoldingsList({
    super.key,
    required this.displayHoldings,
    required this.formatCurrency,
    this.isLocked = false,
    required this.formatLargeNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('FUNDS', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
              Text('CURRENT (INVESTED)', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: displayHoldings.asMap().entries.map((entry) {
              int idx = entry.key;
              HoldingItem item = entry.value;
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push( MaterialPageRoute(builder: (_) => const YourFundProfileScreen()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Center(
                            child: Icon(Icons.business, color: Colors.grey[400], size: 16), // Placeholder for logo
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
                              Text(
                                item.category,
                                style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isLocked ? '₹ * * * *' : formatCurrency.format(item.current),
                              style: const TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLocked ? '₹ * * * *' : formatCurrency.format(item.invested),
                              style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                  if (idx < mockHoldings.length - 1)
                    const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}
