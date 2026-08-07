import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

                    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Builder(
          builder: (context) => SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: HoldingsHeaderDelegate(
                    safeAreaTop: 0,
                    screenHeight: MediaQuery.sizeOf(context).height,
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
                    padding: EdgeInsets.symmetric(vertical: 12.0),
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
                        SizedBox(height: 12.h),
                        MfHoldingsEmptyState(
                          title: "Unlock Portfolio Intelligence",
                          subtitle: "Import your holdings to unlock personalized insights, risk analysis, and smarter recommendations.",
                          ctaText: "Import Portfolio",
                          imagePath: 'lib/core/images/holdingsnewstocks.webp',
                          onCtaTapped: () {
                            context.push('/mf-fetch-confirm');
                          },
                        ),
                        SizedBox(height: 48.h),
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


