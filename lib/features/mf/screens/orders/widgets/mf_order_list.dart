import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../stocks/data/stocks_providers.dart';
import '../../../../stocks/data/stocks_models.dart';
import 'mf_order_item_card.dart';

class MfOrderList extends ConsumerWidget {
  const MfOrderList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(stocksOrdersProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    if (ordersAsync.hasValue && ordersAsync.value != null && ordersAsync.value!.isNotEmpty) {
      final orders = ordersAsync.value!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: orders.map((order) {
          final dateStr = order.timestampEpoch > 0
              ? DateFormat('dd MMM').format(order.timestamp).toUpperCase()
              : 'TODAY';
          final logoColor = order.transactionType == 'BUY'
              ? const Color(0xFF0EA5E9)
              : const Color(0xFFEF4444);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(dateStr),
              MfOrderItemCard(
                logoText: order.tradingSymbol.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join(),
                logoColor: logoColor,
                fundName: '${order.tradingSymbol} (${order.exchange})',
                amount: currencyFormat.format(order.price * (order.quantity > 0 ? order.quantity : 1)),
                type: order.transactionType,
                status: order.status,
              ),
            ],
          );
        }).toList(),
      );
    }

    // Default fallback order list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader('12 FEB'),
        const MfOrderItemCard(
          logoText: 'CANARA\nROBECO',
          logoColor: Color(0xFF0EA5E9),
          fundName: 'Canara Robeco Large Cap Fund',
          amount: '₹22,501.87',
          type: 'BUY',
          status: 'COMPLETED',
        ),
        _buildDateHeader('9 FEB'),
        const MfOrderItemCard(
          logoText: 'Nippon',
          logoColor: Color(0xFFEF4444),
          fundName: 'Nippon India Large Cap Fund',
          amount: '₹58,191.95',
          type: 'SELL',
          status: 'COMPLETED',
        ),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 16.0),
      child: Text(
        date,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
