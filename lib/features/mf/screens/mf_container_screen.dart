import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/nav_context_provider.dart';
import 'holdings/holdings_screen.dart';
import 'sip/sip_screen.dart';
import 'mf_explore/mf_explore_screen.dart';
import 'orders/orders_screen.dart';
import 'watchlist/watchlist_screen.dart';

const _kScreens = <Widget>[
  HoldingsScreen(),    // 0
  MfExploreScreen(),   // 1
  SipScreen(),         // 2
  OrdersScreen(),      // 3
  WatchlistScreen(),   // 4
];

/// Staggered IndexedStack tab container.
///
/// On first entry to MF, only Holdings is in the IndexedStack — matching the
/// budget of the same frame that runs the nav pill SizeTransition animation.
///
/// Then one new screen is added to the IndexedStack per frame via a chained
/// postFrameCallback. IndexedStack lays out all its children, so each added
/// screen gets its layout computed silently in the background while hidden.
///
/// By ~4 frames (~64ms) after entering MF, all 5 screens are fully built AND
/// laid out. Since human reaction time is ~200ms, any tab tap after that is
/// an instant switch with zero cold-layout cost.
///
/// If the user taps a tab before it's been stagger-built, it is force-added
/// synchronously inside build() so it appears immediately.
class MfContainerScreen extends ConsumerStatefulWidget {
  const MfContainerScreen({super.key});

  @override
  ConsumerState<MfContainerScreen> createState() => _MfContainerScreenState();
}

class _MfContainerScreenState extends ConsumerState<MfContainerScreen> {
  // Screens that have been added to the IndexedStack. Start with just Holdings.
  final Set<int> _built = {0};

  @override
  void initState() {
    super.initState();
    // Begin staggered pre-build starting from Explore (1) on the next frame.
    _prewarmNext(1);
  }

  void _prewarmNext(int index) {
    if (index >= _kScreens.length) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _built.add(index));
      _prewarmNext(index + 1); // Chain to next frame
    });
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(mfTabIndexProvider);

    // If user taps a tab before the stagger reaches it, add it now so it
    // renders immediately. Safe to mutate _built here — no setState needed
    // since we're already inside a build triggered by mfTabIndexProvider.
    _built.add(tab);

    return IndexedStack(
      index: tab,
      children: [
        for (int i = 0; i < _kScreens.length; i++)
          // Built screens: real widget, gets full IndexedStack layout treatment.
          // Placeholder screens: SizedBox.expand() — zero-cost, same constraints.
          _built.contains(i) ? _kScreens[i] : const SizedBox.expand(),
      ],
    );
  }
}
