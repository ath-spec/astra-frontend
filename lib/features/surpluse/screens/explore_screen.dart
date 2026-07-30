import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/nav_context_provider.dart';
import 'stocks/stocks_screen.dart';
import 'etfs/etfs_screen.dart';
import 'crypto/crypto_screen.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(exploreTabIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: tabIndex,
          children: const [
            StocksScreen(),
            EtfScreen(),
            CryptoScreen(),
          ],
        ),
      ),
    );
  }
}
