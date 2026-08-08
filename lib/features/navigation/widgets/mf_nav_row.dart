import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/mainnav.dart';
import '../../../core/providers/nav_context_provider.dart';

class MfNavPill extends ConsumerWidget {
  const MfNavPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(mfTabIndexProvider);

    return NavigationPill(
      currentIndex: activeTab,
      onTabTapped: (idx) {
        ref.read(mfTabIndexProvider.notifier).state = idx;
      },
      isNavVisible: true,
      icons: const [
        Icons.account_balance_wallet_outlined,
        Icons.explore_outlined,
        Icons.autorenew_rounded,
        Icons.receipt_long_outlined,
        Icons.bookmark_outline_rounded,
      ],
      customIcons: [
        (color) => Icon(Icons.account_balance_wallet_outlined, color: color, size: 16),
        (color) => Icon(Icons.explore_outlined, color: color, size: 16),
        (color) => Icon(Icons.autorenew_rounded, color: color, size: 16),
        (color) => Icon(Icons.receipt_long_outlined, color: color, size: 16),
        (color) => Icon(Icons.bookmark_outline_rounded, color: color, size: 16),
      ],
      labels: const ['Holdings', 'Explore', 'SIP', 'Orders', 'Watchlist'],
    );
  }
}
