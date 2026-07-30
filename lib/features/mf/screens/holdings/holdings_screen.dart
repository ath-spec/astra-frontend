import 'package:flutter/material.dart';
import 'widgets/mf_holdings_header.dart';
import 'widgets/mf_holdings_empty_state.dart';

class HoldingsScreen extends StatelessWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9), // Slate 100
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left_rounded, color: Colors.black, size: 24),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded, color: Colors.black, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                MfHoldingsHeader(),
                Expanded(
                  child: Center(
                    child: MfHoldingsEmptyState(),
                  ),
                ),
                SizedBox(height: 100), // padding for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }
}
