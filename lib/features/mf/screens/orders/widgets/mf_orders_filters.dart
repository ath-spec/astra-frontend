import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/orders_feed.dart';

class MfOrdersFilters extends ConsumerWidget {
  const MfOrdersFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(ordersFeedFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterPill(
            ref,
            'FILTER',
            filter: OrderFeedFilter.all,
            selected: selected,
            icon: Icons.tune,
          ),
          const SizedBox(width: 8),
          _buildFilterPill(ref, 'BUY', filter: OrderFeedFilter.buy, selected: selected),
          const SizedBox(width: 8),
          _buildFilterPill(ref, 'SIP', filter: OrderFeedFilter.sip, selected: selected),
          const SizedBox(width: 8),
          _buildFilterPill(ref, 'SELL', filter: OrderFeedFilter.sell, selected: selected),
          const SizedBox(width: 8),
          _buildFilterPill(ref, 'SURPLUS', filter: OrderFeedFilter.surplus, selected: selected),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    WidgetRef ref,
    String text, {
    required OrderFeedFilter filter,
    required OrderFeedFilter selected,
    IconData? icon,
  }) {
    final isActive = filter == selected;
    return GestureDetector(
      onTap: () => ref.read(ordersFeedFilterProvider.notifier).state =
          isActive && filter != OrderFeedFilter.all ? OrderFeedFilter.all : filter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w600, // Match screenshot (bold)
                letterSpacing: 1.0,
                color: isActive ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: isActive ? Colors.white : const Color(0xFF0F172A)),
            ],
          ],
        ),
      ),
    );
  }
}
