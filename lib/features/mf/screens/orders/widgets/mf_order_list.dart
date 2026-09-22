import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/widgets/shimmer_card_skeleton.dart';
import '../data/orders_feed.dart';
import 'mf_order_item_card.dart';

class MfOrderList extends ConsumerWidget {
  const MfOrderList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(ordersFeedProvider);
    final filter = ref.watch(ordersFeedFilterProvider);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    if (feedAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppThemeShimmerCard(height: 70),
            SizedBox(height: 12),
            AppThemeShimmerCard(height: 70),
          ],
        ),
      );
    }

    final allItems = feedAsync.value ?? const <OrderFeedItem>[];
    final items = filter == OrderFeedFilter.all
        ? allItems
        : allItems.where((item) => item.category == filter).toList();

    if (items.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          final dateStr = DateFormat('dd MMM').format(item.date).toUpperCase();
          final logoColor = item.category == OrderFeedFilter.sell
              ? const Color(0xFFEF4444)
              : item.category == OrderFeedFilter.sip
                  ? const Color(0xFF8B5CF6)
                  : item.category == OrderFeedFilter.surplus
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF0EA5E9);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(dateStr),
              MfOrderItemCard(
                logoText: item.title.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join(),
                logoColor: logoColor,
                fundName: item.title,
                amount: currencyFormat.format(item.amount),
                type: item.typeLabel,
                status: item.status,
              ),
            ],
          );
        }).toList(),
      );
    }

    // Clean Empty State
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text(
              'No Orders Yet',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your completed and ongoing mutual fund & stock transactions will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
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
