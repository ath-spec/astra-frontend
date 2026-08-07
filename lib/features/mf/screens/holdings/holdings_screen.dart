import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/mf_holdings_empty_state.dart';
import 'widgets/mf_holdings_header.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../asset_connection/providers/asset_connection_provider.dart';
import '../../../../core/providers/privacy_provider.dart';
import 'widgets/connected_holdings_view.dart';

class HoldingsScreen extends ConsumerStatefulWidget {
  const HoldingsScreen({super.key});

  @override
  ConsumerState<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends ConsumerState<HoldingsScreen> {
  bool _hasImportedPortfolio = false;

  @override
  Widget build(BuildContext context) {
    // We import riverpod provider here to avoid too many file changes
    final assetState = ref.watch(assetConnectionProvider);
    final isLocked = ref.watch(privacyProvider);
    
    if (assetState.mfConnected) {
      return const ConnectedHoldingsView();
    }

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final double scale = size.width / 375.0;
    final double logicalHeight = (size.height - padding.top - padding.bottom) / scale;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 375,
            height: logicalHeight,
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: HoldingsHeaderDelegate(
                    safeAreaTop: 0,
                    screenHeight: logicalHeight,
                    hasImportedPortfolio: _hasImportedPortfolio,
                    isLocked: isLocked,
                    onLockTap: () {
                      ref.read(privacyProvider.notifier).state = !isLocked;
                    },
                    onCartTap: () => context.push('/cart'),
                    onRefreshTap: () => context.push('/mf-fetch-confirm'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        MfHoldingsEmptyState(
                          title: "Your AI Investment Guide",
                          subtitle: "Discover investments tailored to your goals, risk profile, and financial journey.",
                          ctaText: "Explore Investments",
                          imagePath: 'lib/core/images/new_holding.webp',
                          onCtaTapped: () {
                            setState(() {
                              _hasImportedPortfolio = false;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        MfHoldingsEmptyState(
                          title: "Unlock Portfolio Intelligence",
                          subtitle: "Import your holdings to unlock personalized insights, risk analysis, and smarter recommendations.",
                          ctaText: "Import Portfolio",
                          imagePath: 'lib/core/images/holdingsnewstocks.webp',
                          onCtaTapped: () {
                            context.push('/mf-fetch-confirm');
                          },
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


