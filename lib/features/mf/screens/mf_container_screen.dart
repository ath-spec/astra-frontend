import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/nav_context_provider.dart';
import 'holdings/holdings_screen.dart';
import 'sip/sip_screen.dart';
import 'mf_explore/mf_explore_screen.dart';
import 'orders/orders_screen.dart';
import 'watchlist/watchlist_screen.dart';

class MfContainerScreen extends ConsumerWidget {
  const MfContainerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(mfTabIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: tabIndex,
          children: const [
            HoldingsScreen(),
            MfExploreScreen(),
            SipScreen(),
            OrdersScreen(),
            WatchlistScreen(),
          ],
        ),
      ),
    );
  }
}
