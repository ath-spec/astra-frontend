import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/mainnav.dart';
import '../../../core/providers/nav_context_provider.dart';
import 'nav_shared_components.dart';

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
        Icons.autorenew_rounded,
        Icons.lock_clock_outlined,
        Icons.receipt_long_outlined,
        Icons.bookmark_outline_rounded,
      ],
      labels: const ['Holdings', 'SIP', 'FD', 'Orders', 'Watchlist'],
    );
  }
}
