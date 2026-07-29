import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../navigation/mainnav.dart';
import '../../../core/providers/nav_context_provider.dart';
import 'nav_shared_components.dart';

class ExploreNavPill extends ConsumerWidget {
  const ExploreNavPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(exploreTabIndexProvider);

    return NavigationPill(
      currentIndex: activeTab,
      onTabTapped: (idx) {
        ref.read(exploreTabIndexProvider.notifier).state = idx;
      },
      isNavVisible: true,
      icons: const [
        Icons.trending_up_rounded,
        Icons.pie_chart_outline_rounded,
        Icons.currency_bitcoin_rounded,
      ],
      labels: const ['Stocks', 'ETFs', 'Crypto'],
    );
  }
}
