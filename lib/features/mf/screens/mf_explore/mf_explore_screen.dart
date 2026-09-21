import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/privacy_provider.dart';
import '../../../asset_connection/providers/asset_connection_provider.dart';
import '../../../dashboard/data/dashboard_providers.dart';
import '../holdings/widgets/mf_holdings_header.dart';
import 'widgets/mf_alternative_funds.dart';

// NEW SECTIONS
import 'widgets/mf_explore_assets.dart';
import 'widgets/mf_new_trending_themes.dart';
import 'widgets/mf_new_investment_ideas.dart';
import 'widgets/mf_goal_planning.dart';
import 'widgets/mf_global_investing.dart';
import 'widgets/mf_new_alternative_assets.dart';

class MfExploreScreen extends ConsumerWidget {
  const MfExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetState = ref.watch(assetConnectionProvider);
    final isLocked = ref.watch(privacyProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final summary = summaryAsync.valueOrNull;

    final double totalWealth = summary?.totalWealth ?? 0.0;
    final double oneDayChange = summary?.oneDayChangeAmount ?? 0.0;
    final double oneDayPct = summary?.oneDayChangePct ?? 0.0;

    final bool hasImported =
        assetState.mfConnected || assetState.stocksConnected || totalWealth > 0;

    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final sign = oneDayChange >= 0 ? '' : '-';
    final oneDayText = (hasImported && (oneDayChange != 0 || oneDayPct != 0))
        ? '$sign${formatCurrency.format(oneDayChange.abs())} (${oneDayPct.toStringAsFixed(2)}%)'
        : (hasImported ? '₹0 (0.00%)' : '');

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: HoldingsHeaderDelegate(
              safeAreaTop: MediaQuery.paddingOf(context).top,
              screenHeight: MediaQuery.sizeOf(context).height,
              hasImportedPortfolio: hasImported,
              isLocked: isLocked,
              onLockTap: () {
                ref.read(privacyProvider.notifier).state = !isLocked;
              },
              onCartTap: () => context.push('/cart'),
              onRefreshTap: () {
                ref.invalidate(dashboardSummaryProvider);
                context.push('/mf-fetch-confirm');
              },
              mfConnected:
                  assetState.mfConnected || (summary?.mfConnected ?? false),
              stocksConnected: assetState.stocksConnected ||
                  (summary?.stocksConnected ?? false),
              totalValue: totalWealth,
              oneDayChangeText: oneDayText,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: const [
                  // EXPLORE ASSETS
                  MfExploreAssets(),

                  // Section 1: TRENDING THEMES
                  SizedBox(height: 48),
                  MfNewTrendingThemes(),
                  SizedBox(height: 48),

                  // Section 5: INVESTMENT IDEAS
                  MfNewInvestmentIdeas(),
                  SizedBox(height: 48),
                  // Section 6: GOAL PLANNING
                  MfGoalPlanning(),
                  SizedBox(height: 48),
                  // Section 2: ALTERNATIVE ASSETS
                  MfNewAlternativeAssets(),
                  SizedBox(height: 48),
                  MfAlternativeFunds(),
                  SizedBox(height: 48),

                  // Section 6: GLOBAL INVESTING
                  MfGlobalInvesting(),

                  SizedBox(height: 120), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
