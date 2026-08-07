import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'holding_item.dart';
import '../../../../fund_profile/screens/your_fund_profile_screen.dart';

class TableHoldingsList extends StatelessWidget {
  final List<HoldingItem> displayHoldings;
  final NumberFormat formatCurrency;
  final bool isLocked;
  final String Function(double) formatLargeNumber;

  const TableHoldingsList({
    super.key,
    required this.displayHoldings,
    required this.formatCurrency,
    this.isLocked = false,
    required this.formatLargeNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Static Column
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 48,
                    padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                    alignment: Alignment.centerLeft,
                    child: const Text('FUNDS', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ...displayHoldings.map((item) {
                    return InkWell(
                      onTap: () => Navigator.of(context, rootNavigator: true).push( MaterialPageRoute(builder: (_) => const YourFundProfileScreen())),
                      child: Container(
                        height: 72,
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                        child: Text(item.name, style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Right Scrollable Columns
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 90, height: 48, padding: const EdgeInsets.symmetric(vertical: 16), alignment: Alignment.centerRight, child: const Text('AMOUNT', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
                        Container(width: 90, height: 48, padding: const EdgeInsets.symmetric(vertical: 16), alignment: Alignment.centerRight, child: const Text('RETURNS', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
                        Container(width: 90, height: 48, padding: const EdgeInsets.symmetric(vertical: 16), alignment: Alignment.centerRight, child: const Text('1D', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
                        Container(width: 70, height: 48, padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16), alignment: Alignment.centerRight, child: const Text('XIRR', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)))),
                      ],
                    ),
                    const SizedBox(
                      width: 340,
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                    ...displayHoldings.map((item) {
                      bool isPosRet = item.returns >= 0;
                      bool isPos1D = item.oneDayChange >= 0;
                      return InkWell(
                        onTap: () => Navigator.of(context, rootNavigator: true).push( MaterialPageRoute(builder: (_) => const YourFundProfileScreen())),
                        child: Container(
                          height: 72,
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                          child: Row(
                            children: [
                              Container(
                                width: 90,
                                alignment: Alignment.centerRight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(formatCurrency.format(item.current), style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                    Text(formatCurrency.format(item.invested), style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, color: Color(0xFF9CA3AF))),
                                  ],
                                ),
                              ),
                              Container(
                                width: 90,
                                alignment: Alignment.centerRight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${isPosRet ? '+' : '-'}${formatCurrency.format(item.returns.abs())}', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: isPosRet ? const Color(0xFF22C55E) : const Color(0xFFEF4444))),
                                    Text('(${isPosRet ? '+' : '-'}${item.returnsPercent.abs()}%)', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: isPosRet ? const Color(0xFF22C55E) : const Color(0xFFEF4444))),
                                  ],
                                ),
                              ),
                              Container(
                                width: 90,
                                alignment: Alignment.centerRight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${isPos1D ? '+' : '-'}${formatCurrency.format(item.oneDayChange.abs())}', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w600, color: isPos1D ? const Color(0xFF22C55E) : const Color(0xFFEF4444))),
                                    Text('(${isPos1D ? '+' : '-'} ${item.oneDayChangePercent.abs()}%)', style: TextStyle(fontFamily: 'DMSans', fontSize: 10, color: isPos1D ? const Color(0xFF22C55E) : const Color(0xFFEF4444))),
                                  ],
                                ),
                              ),
                              Container(
                                width: 70,
                                padding: const EdgeInsets.only(right: 16),
                                alignment: Alignment.centerRight,
                                child: Text('${item.xirr}%', textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
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
      ),
    );
  }
}
