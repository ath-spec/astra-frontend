import '../../../core/widgets/shimmer_card_skeleton.dart';
import 'dart:ui' show lerpDouble, ImageFilter;
import 'dart:math' hide log;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/arch_background.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';
import '../../../core/providers/nav_context_provider.dart';
import '../../../core/providers/privacy_provider.dart';
import '../../../core/utils/privacy_formatter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/data/dashboard_models.dart';
import '../../dashboard/data/dashboard_providers.dart';

import '../widgets/home_today_portfolio_changes.dart';
import '../widgets/home_portfolio_insights.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_astra_intelligence.dart';
import '../widgets/home_grow_wealth.dart';
import '../widgets/home_explore_more.dart';
import '../widgets/home_order_cards.dart';
import '../widgets/home_portfolio_analysis.dart';
import 'package:astra_frontend/features/home/widgets/home_portfolio_growth.dart';
import 'package:astra_frontend/features/home/widgets/budget_section.dart';
import 'package:astra_frontend/features/home/widgets/recurring_section.dart';

/// Screen 4: New Home Screen / Dashboard (Image 4) in clean light mode.
/// Displays user wealth header, portfolio chart card, asset status list (with FETCHING status),
/// and floating pill bottom navigation bar.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isSecondCardStacked = ValueNotifier(false);
  bool _showFab = false;
  bool _isRefreshing = false;

  /// Invalidates the cached dashboard providers (Riverpod's FutureProvider
  /// result cache — there's no separate HTTP cache in this app) and awaits
  /// the refetch. The summary endpoint recomputes the user's portfolio value
  /// live and upserts today's portfolio_snapshots row server-side, so this
  /// is also what refreshes the snapshot the RM portal's book/list views
  /// read.
  Future<void> _handleRefreshTap() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    ref.invalidate(dashboardGrowthProvider);
    try {
      ref.invalidate(dashboardSummaryProvider);
      await ref.read(dashboardSummaryProvider.future);
      HapticFeedback.lightImpact();
      if (mounted) {
        _showRefreshedCue();
      }
    } catch (_) {
      if (mounted) {
        _showRefreshFailedCue();
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _showRefreshedCue() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0F172A),
          elevation: 6,
          margin: EdgeInsets.only(
            bottom: 84 + MediaQuery.paddingOf(context).bottom,
            left: 32,
            right: 32,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF334155), width: 1),
          ),
          duration: const Duration(milliseconds: 2000),
          content: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Color(0xFF10B981),
              ),
              SizedBox(width: 8),
              Text(
                'Data refreshed',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showRefreshFailedCue() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0F172A),
          elevation: 6,
          margin: EdgeInsets.only(
            bottom: 84 + MediaQuery.paddingOf(context).bottom,
            left: 32,
            right: 32,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF334155), width: 1),
          ),
          duration: const Duration(milliseconds: 2500),
          content: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 16,
                color: Color(0xFFEF4444),
              ),
              SizedBox(width: 8),
              Text(
                'Failed to refresh data',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _isSecondCardStacked.addListener(() {
      if (_isSecondCardStacked.value && !_showFab) {
        setState(() => _showFab = true);
      } else if (!_isSecondCardStacked.value && _showFab) {
        setState(() => _showFab = false);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.stop();
    _pulseController.dispose();
    _scrollController.dispose();
    _isSecondCardStacked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetState = ref.watch(assetConnectionProvider);
    final isLocked = ref.watch(privacyProvider);
    final authState = ref.watch(authProvider);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final dashboardAsync = ref.watch(dashboardSummaryProvider);
    // The backend now always seeds realistic starter MF/Stocks holdings, so
    // there's no real "not connected" state for them any more — empty-state
    // gating below is driven by whether a bucket's `value` is 0 (via
    // DashboardSummary.mfConnected/stocksConnected), not the old
    // assetConnectionProvider onboarding-flow mock flags. Those flags are
    // still used for bank-account linking, which has no backend endpoint
    // yet, and as a loading-state fallback so returning users don't flash
    // an empty header while the summary request is in flight.
    final DashboardSummary summary = dashboardAsync.maybeWhen(
      data: (s) => s,
      orElse: () => DashboardSummary.empty,
    );
    final bool summaryLoaded = dashboardAsync.hasValue;
    final bool mfConnected = assetState.mfConnected || (summaryLoaded && summary.mfConnected);
    final bool stocksConnected = assetState.stocksConnected || (summaryLoaded && summary.stocksConnected);
    final bool fdConnected = summaryLoaded && summary.fixedDepositsPresent;
    final bool banksConnected = assetState.banksConnected || (summaryLoaded && summary.bankBalancePresent);

    final String userName = authState is AuthAuthenticated ? authState.user.name.toUpperCase() : 'USER';

    final double totalWealthValue = summary.totalWealth;
    final formattedTotal = PrivacyFormatter.obscure(
      totalWealthValue == 0 ? '₹0' : '₹${NumberFormat('#,##,###').format(totalWealthValue)}',
      isLocked
    );

    final bool showReturnsPill = summaryLoaded && totalWealthValue > 0;

    // Total returns aggregated from the real per-bucket invested/returns
    // figures the backend provides (mutual funds + stocks + fixed deposits;
    // bank balance has no invested/returns concept). There's no single
    // "total returns" field in the API response, so this is a client-side
    // sum of real numbers, not a fabricated figure.
    final double totalInvested = summary.mutualFunds.investedValue +
        summary.stocks.investedValue +
        summary.fixedDeposits.investedValue;
    final double totalReturnsAmount = summary.mutualFunds.returnsAmount +
        summary.stocks.returnsAmount +
        summary.fixedDeposits.returnsAmount;
    final double totalReturnsPct =
        totalInvested > 0 ? (totalReturnsAmount / totalInvested) * 100 : 0.0;

    final String oneDayArrow = summary.oneDayChangeAmount >= 0 ? '↑' : '↓';
    final String totalReturnsArrow = totalReturnsAmount >= 0 ? '↑' : '↓';
    final String pillOneDayText = showReturnsPill
        ? '$oneDayArrow ₹${NumberFormat('#,##,###').format(summary.oneDayChangeAmount.abs())} (${summary.oneDayChangePct.abs().toStringAsFixed(2)}%) 1D change'
        : '';
    final String pillTotalText = showReturnsPill
        ? '$totalReturnsArrow ₹${NumberFormat('#,##,###').format(totalReturnsAmount.abs())} (${totalReturnsPct.abs().toStringAsFixed(2)}%) Total Returns'
        : '';

    if (assetState.step == AssetConnectionStep.banksLinkingProgress) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      if (_pulseController.isAnimating) _pulseController.stop();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Sit above the navigation bar
        child: AnimatedScale(
          scale: _showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: const Cubic(0.23, 1, 0.32, 1),
          child: AnimatedOpacity(
            opacity: _showFab ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            curve: const Cubic(0.23, 1, 0.32, 1),
            child: SizedBox(
              width: 40,
              height: 40,
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: const Cubic(0.23, 1, 0.32, 1),
                  );
                },
                backgroundColor: const Color(0xFF0F172A),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, minHeight: double.infinity), // Max width for tablet/web, full height
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _HomeHeaderDelegate(
              safeAreaTop: MediaQuery.paddingOf(context).top,
              totalWealth: formattedTotal,
              userName: userName,
              showReturnsPill: showReturnsPill,
              pillOneDayText: pillOneDayText,
              pillTotalText: pillTotalText,
              isLocked: isLocked,
              onProfileTap: () => context.push('/user-profile'),
              onLockTap: () => ref.read(privacyProvider.notifier).state = !isLocked,
              onRefreshTap: _handleRefreshTap,
              isRefreshing: _isRefreshing,
            ),
          ),
          // 1. Main content with consistent horizontal padding
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                
                // Asset List

                if (mfConnected)
                  _buildConnectedAssetRow(
                    icon: Icons.signal_cellular_alt_rounded,
                    title: 'Mutual Funds',
                    percentage: '${summary.mutualFunds.sharePct.toStringAsFixed(1)}%',
                    amount: PrivacyFormatter.obscure(
                      '₹${NumberFormat('#,##,###').format(summary.mutualFunds.value)}',
                      isLocked,
                    ),
                    subtitle: PrivacyFormatter.obscure(
                      '${summary.mutualFunds.returnsAmount >= 0 ? '↑' : '↓'} ${_formatCompact(summary.mutualFunds.returnsAmount.abs())} (${summary.mutualFunds.returnsPct.abs().toStringAsFixed(2)}%) Returns',
                      isLocked,
                    ),
                    subtitleColor: summary.mutualFunds.returnsAmount >= 0
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    onTap: () {
                      ref.read(navContextProvider.notifier).state = NavContext.mf;
                      // mfTabIndexProvider persists across the whole app
                      // session (it's how quick actions like "Invest via
                      // SIP" jump straight to a specific MF tab). The bottom
                      // nav bar's own MF icon resets it to 0 on tap (see
                      // app_shell.dart), but this tile is a second, separate
                      // entry point to the same screen that bypassed that
                      // reset — landing on whatever tab was last active
                      // instead of Holdings. Reset it here too.
                      ref.read(mfTabIndexProvider.notifier).state = 0;
                      context.go('/mf');
                    },
                  )
                else
                  _buildAssetRow(
                    icon: Icons.bar_chart_rounded,
                    title: 'Mutual Funds',
                    buttonText: 'IMPORT',
                    onPressed: () => context.push('/mf-fetch-confirm'),
                  ),
                _buildDottedDivider(),

                if (stocksConnected)
                  _buildConnectedAssetRow(
                    icon: Icons.candlestick_chart_rounded,
                    title: 'Stocks',
                    percentage: '${summary.stocks.sharePct.toStringAsFixed(1)}%',
                    amount: PrivacyFormatter.obscure(
                      '₹${NumberFormat('#,##,###').format(summary.stocks.value)}',
                      isLocked,
                    ),
                    subtitle: PrivacyFormatter.obscure(
                      '${summary.stocks.returnsAmount >= 0 ? '↑' : '↓'} ${_formatCompact(summary.stocks.returnsAmount.abs())} (${summary.stocks.returnsPct.abs().toStringAsFixed(2)}%) Returns',
                      isLocked,
                    ),
                    subtitleColor: summary.stocks.returnsAmount >= 0
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    onTap: () {
                      context.push('/stocks');
                    },
                  )
                else
                  _buildAssetRow(
                    icon: Icons.candlestick_chart_rounded,
                    title: 'Stocks',
                    buttonText: 'IMPORT',
                    onPressed: () => context.push('/aa-stocks-otp'),
                  ),
                _buildDottedDivider(),

                if (fdConnected)
                  _buildConnectedAssetRow(
                    icon: Icons.savings_rounded,
                    title: 'Fixed Deposits',
                    percentage: '${summary.fixedDeposits.sharePct.toStringAsFixed(1)}%',
                    amount: PrivacyFormatter.obscure(
                      '₹${NumberFormat('#,##,###').format(summary.fixedDeposits.value)}',
                      isLocked,
                    ),
                    subtitle: PrivacyFormatter.obscure(
                      '${summary.fixedDeposits.returnsAmount >= 0 ? '↑' : '↓'} ${_formatCompact(summary.fixedDeposits.returnsAmount.abs())} (${summary.fixedDeposits.returnsPct.abs().toStringAsFixed(2)}%) Returns',
                      isLocked,
                    ),
                    subtitleColor: summary.fixedDeposits.returnsAmount >= 0
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    onTap: () {
                      context.push('/fds');
                    },
                  )
                else
                  _buildAssetRow(
                    icon: Icons.savings_rounded,
                    title: 'Fixed Deposits',
                    buttonText: 'OPEN',
                    onPressed: () => context.push('/mf-fd'),
                  ),
                _buildDottedDivider(),

                if (banksConnected)
                  _buildConnectedAssetRow(
                    icon: Icons.account_balance_rounded,
                    title: 'Bank Accounts',
                    percentage: '${summary.bankBalance.sharePct.toStringAsFixed(1)}%',
                    amount: PrivacyFormatter.obscure(
                      '₹${NumberFormat('#,##,###').format(summary.bankBalance.value)}',
                      isLocked,
                    ),
                    onTap: () {
                      context.push('/linked-bank-accounts');
                    },
                  )
                else
                  _buildBankAccountsRow(
                    isLinked: false,
                    isLinking: assetState.step == AssetConnectionStep.banksLinkingProgress,
                  ),


                const SizedBox(height: 48),
                HomePortfolioInsights(isLocked: isLocked),

                const SizedBox(height: 48),
                const HomePortfolioAnalysis(),

                const SizedBox(height: 48),
                const HomeQuickActions(),
                const SizedBox(height: 48),
                if (mfConnected || stocksConnected)
                  HomeTodayPortfolioChanges(
                    summary: summary,
                  ),

              ]),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 48),
          ),
          // 4. Edge-to-edge Portfolio Growth Graph
          if (mfConnected || stocksConnected)
            SliverToBoxAdapter(
              child: HomePortfolioGrowth(
                mfConnected: mfConnected,
                stocksConnected: stocksConnected,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),

          const SliverToBoxAdapter(
            child: BudgetSection(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
          const SliverToBoxAdapter(
            child: RecurringSection(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 48),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 140 + bottomPadding), // Extra padding for AppShell nav bar
          ),
        ],
      ),
    ),
      ),
    );
  }

  Widget _buildConnectedAssetRow({
    required IconData icon,
    required String title,
    required String percentage,
    required String amount,
    String? subtitle,
    Color subtitleColor = const Color(0xFF64748B),
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF0F172A), size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: subtitle != null ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    percentage,
                    style: const TextStyle(
                      fontFamily: 'DMMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: subtitle != null ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor,
                      letterSpacing: 0,
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRow({
    required IconData icon,
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
    bool isLinked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLinked ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              foregroundColor: isLinked ? const Color(0xFF0F172A) : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: isLinked
                    ? const BorderSide(color: Color(0xFFCBD5E1))
                    : BorderSide.none,
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurplusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF64748B), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Surplus',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    children: [
                      TextSpan(text: 'Earn '),
                      TextSpan(
                        text: '2.5x',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(text: ' on your idle money'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Surplus idle money management coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Explore',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountsRow({required bool isLinked, required bool isLinking}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: GestureDetector(
        onTap: () {
          if (isLinked) {
            context.push('/linked-bank-accounts');
          } else {
            context.push('/banks-linking');
          }
        },
        child: Row(
          children: [
            const Icon(Icons.account_balance_rounded, color: Color(0xFF64748B), size: 24),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Bank Accounts',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
              if (isLinked)
                const SizedBox() // Handled by _buildConnectedAssetRow now
              else if (isLinking)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: const Text(
                      '• • •',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FETCHING',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'IMPORT',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Compact currency formatting for row subtitles, e.g. ₹52.96K / ₹3.53L.
  String _formatCompact(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(2)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  Widget _buildDottedDivider() {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DottedLinePainter(),
    );
  }
}

/// Dotted horizontal line separator
class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    double startX = 0;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double safeAreaTop;
  final String totalWealth;
  final String userName;
  final bool showReturnsPill;
  final String pillOneDayText;
  final String pillTotalText;
  final VoidCallback onProfileTap;
  final VoidCallback onLockTap;
  final VoidCallback onRefreshTap;
  final bool isLocked;
  final bool isLoading;
  final bool isRefreshing;

  _HomeHeaderDelegate({
    required this.safeAreaTop,
    required this.totalWealth,
    required this.userName,
    required this.showReturnsPill,
    required this.pillOneDayText,
    required this.pillTotalText,
    required this.onProfileTap,
    required this.onLockTap,
    required this.onRefreshTap,
    required this.isLocked,
    this.isLoading = false,
    this.isRefreshing = false,
  });

  @override
  double get minExtent => safeAreaTop + 84.0;

  @override
  double get maxExtent => safeAreaTop + 260.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 0.0 when fully expanded, 1.0 when fully collapsed
    final shrinkRatio = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    // Use an ease-in-out curve for the transition to make it feel organic (Emil style)
    final curve = Curves.easeInOutCubic;
    final double easedRatio = curve.transform(shrinkRatio);

    // Layout Interpolations
    final double startTop = maxExtent - 124.0; // Keep the text at the same visual height (260 - 124 = 136)
    final double endTop = safeAreaTop + 18.0; // Vertically centered with 44px buttons
    final double currentTop = lerpDouble(startTop, endTop, easedRatio)!;

    final double startSubtitleTop = startTop - 26.0;
    final double endSubtitleTop = endTop - 40.0;
    final double currentSubtitleTop = lerpDouble(startSubtitleTop, endSubtitleTop, easedRatio)!;

    // Style Interpolations
    final double currentFontSize = lerpDouble(36.0, 14.0, easedRatio)!;
    final double currentBorderRadius = lerpDouble(0.0, 20.0, easedRatio)!;
    final double currentHPad = lerpDouble(0.0, 16.0, easedRatio)!;
    final double currentVPad = lerpDouble(0.0, 6.0, easedRatio)!;
    
    // Fade the background in slower so it looks like text first, then pill
    final double pillBgRatio = (easedRatio * 1.5).clamp(0.0, 1.0);
    final double currentBorderOpacity = lerpDouble(0.0, 1.0, pillBgRatio)!;
    final double currentShadowOpacity = lerpDouble(0.0, 0.05, pillBgRatio)!;

    return Container(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [

          // Frosted glass blur overlay
          Positioned.fill(
            child: Stack(
              children: [
                // Progressive blur
                if (!kIsWeb) ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.black, Colors.transparent],
                    stops: [0.0, 0.7, 1.0],
                  ).createShader(bounds),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: lerpDouble(0.0, 16.0, easedRatio)!,
                        sigmaY: lerpDouble(0.0, 16.0, easedRatio)!,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                // Progressive tint
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: lerpDouble(0.0, 0.85, easedRatio)!),
                        Colors.white.withValues(alpha: lerpDouble(0.0, 0.4, easedRatio)!),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subtitle "ABHIMANYU'S WEALTH"
          Positioned(
            top: currentSubtitleTop,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - (shrinkRatio * 2.5)).clamp(0.0, 1.0), // Fades out quickly
              child: Center(
                child: Text(
                  "$userName'S WEALTH",
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // The Transforming Wealth Number -> Pill
          Positioned(
            top: currentTop,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: currentHPad, vertical: currentVPad),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: pillBgRatio),
                  borderRadius: BorderRadius.circular(currentBorderRadius),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0).withValues(alpha: currentBorderOpacity),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: currentShadowOpacity),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isLoading
                        ? ShimmerBar(
                            width: lerpDouble(170.0, 80.0, easedRatio)!,
                            height: currentFontSize,
                            borderRadius: 6,
                          )
                        : Text(
                            totalWealth,
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              color: const Color(0xFF0F172A),
                              fontSize: currentFontSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: lerpDouble(-1.0, 0.0, easedRatio)!,
                              height: 1.1,
                            ),
                          ),
                    // Shrinking Refresh Icon
                    if (shrinkRatio < 1.0) ...[
                      SizedBox(width: lerpDouble(12.0, 0.0, easedRatio)!),
                      Opacity(
                        opacity: (1.0 - (shrinkRatio * 2)).clamp(0.0, 1.0),
                        child: GestureDetector(
                          onTap: isRefreshing ? null : onRefreshTap,
                          child: Tooltip(
                            message: 'Refresh data',
                            child: Container(
                              width: lerpDouble(28.0, 0.0, easedRatio)!,
                              height: lerpDouble(28.0, 0.0, easedRatio)!,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                              ),
                              child: isRefreshing
                                  ? Padding(
                                      padding: EdgeInsets.all(
                                        lerpDouble(6.0, 0.0, easedRatio)!,
                                      ),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.6,
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF64748B),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.refresh_rounded,
                                      size: lerpDouble(16.0, 0.0, easedRatio)!,
                                      color: const Color(0xFF64748B),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Returns Pill below the wealth number
          if (shrinkRatio < 1.0)
            Positioned(
              top: currentTop + 64.0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: isLoading
                    ? Opacity(
                        opacity: (1.0 - (shrinkRatio * 3.0)).clamp(0.0, 1.0),
                        child: const ShimmerBar(width: 140, height: 20, borderRadius: 20),
                      )
                    : (showReturnsPill
                        ? _ReturnsPill(
                            opacity: (1.0 - (shrinkRatio * 3.0)).clamp(0.0, 1.0),
                            oneDayText: pillOneDayText,
                            totalText: pillTotalText,
                          )
                        : const SizedBox.shrink()),
              ),
            ),

          // Top Row (Profile, Lock)
          Positioned(
            top: safeAreaTop + 12.0,
            left: 24.0,
            right: 24.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF0F172A),
                      size: 22,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onLockTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                      color: const Color(0xFF0F172A),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return safeAreaTop != oldDelegate.safeAreaTop ||
           totalWealth != oldDelegate.totalWealth ||
           showReturnsPill != oldDelegate.showReturnsPill ||
           pillOneDayText != oldDelegate.pillOneDayText ||
           pillTotalText != oldDelegate.pillTotalText ||
           isLoading != oldDelegate.isLoading ||
           isRefreshing != oldDelegate.isRefreshing;
  }
}

class _ReturnsPill extends StatefulWidget {
  final double opacity;
  final String oneDayText;
  final String totalText;
  
  const _ReturnsPill({
    required this.opacity,
    required this.oneDayText,
    required this.totalText,
  });

  @override
  State<_ReturnsPill> createState() => _ReturnsPillState();
}

class _ReturnsPillState extends State<_ReturnsPill> {
  bool _showOneDay = true;

  @override
  Widget build(BuildContext context) {
    if (widget.opacity <= 0.01) return const SizedBox.shrink();
    
    return Opacity(
      opacity: widget.opacity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _showOneDay = !_showOneDay;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, childWidget) {
                      final isCurrent = childWidget?.key == ValueKey(_showOneDay);
                      final angle = isCurrent 
                          ? (1.0 - animation.value) * -pi / 2 
                          : (1.0 - animation.value) * pi / 2;
                      
                      return FadeTransition(
                        opacity: animation,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.002)
                            ..rotateX(angle),
                          alignment: Alignment.center,
                          child: childWidget,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _showOneDay ? widget.oneDayText : widget.totalText,
                    key: ValueKey<bool>(_showOneDay),
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.unfold_more_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

