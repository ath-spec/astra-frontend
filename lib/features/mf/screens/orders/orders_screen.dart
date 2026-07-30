import 'package:flutter/material.dart';
import 'widgets/mf_orders_header.dart';
import 'widgets/mf_orders_filters.dart';
import 'widgets/mf_order_list.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: MfOrdersHeader(),
            ),
            const SliverToBoxAdapter(
              child: MfOrdersFilters(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
            const SliverToBoxAdapter(
              child: MfOrderList(),
            ),
            // Bottom padding for the navigation bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }
}

