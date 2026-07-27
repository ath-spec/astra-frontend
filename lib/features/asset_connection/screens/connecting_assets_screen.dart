import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/asset_connection_provider.dart';
import '../widgets/asset_timeline_item.dart';

/// Screen displaying vertical timeline of asset connection progress (Mutual Funds, Stocks, Banks).
/// Automatically transitions to status screens or OTP screens as timers trigger.
class ConnectingAssetsScreen extends ConsumerStatefulWidget {
  const ConnectingAssetsScreen({super.key});

  @override
  ConsumerState<ConnectingAssetsScreen> createState() => _ConnectingAssetsScreenState();
}

class _ConnectingAssetsScreenState extends ConsumerState<ConnectingAssetsScreen> {
  @override
  void initState() {
    super.initState();
    // Start the onboarding connection flow when entering this screen if initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(assetConnectionProvider);
      if (state.step == AssetConnectionStep.linkingMutualFunds) {
        ref.read(assetConnectionProvider.notifier).startOnboardingFlow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetConnectionProvider);

    // Listen for step transitions to navigate to appropriate screen
    ref.listen<AssetConnectionState>(assetConnectionProvider, (previous, next) {
      if (previous?.step == AssetConnectionStep.linkingMutualFunds &&
          next.step == AssetConnectionStep.mutualFundsStatus) {
        context.push('/mf-status');
      } else if (previous?.step == AssetConnectionStep.linkingStocks &&
          next.step == AssetConnectionStep.stocksOtp) {
        context.push('/stocks-otp');
      } else if (previous?.step == AssetConnectionStep.linkingBanks &&
          (next.step == AssetConnectionStep.banksLinking ||
              next.step == AssetConnectionStep.banksSearching)) {
        if (next.step == AssetConnectionStep.banksLinking) {
          context.push('/banks-linking');
        } else {
          context.push('/banks-searching');
        }
      }
    });

    final isMfLinking = state.step == AssetConnectionStep.linkingMutualFunds;
    final isMfDone = state.mfConnected ||
        state.step != AssetConnectionStep.linkingMutualFunds;
    final isStocksLinking = state.step == AssetConnectionStep.linkingStocks ||
        state.step == AssetConnectionStep.stocksVerifying ||
        state.step == AssetConnectionStep.stocksSearching;
    final isStocksDone = state.stocksConnected ||
        state.stocksStatusMessage.contains('Skipped') ||
        state.step == AssetConnectionStep.linkingBanks ||
        state.step == AssetConnectionStep.banksSearching ||
        state.step == AssetConnectionStep.banksLinking ||
        state.step == AssetConnectionStep.banksLinkingProgress ||
        state.step == AssetConnectionStep.completed;
    final isBanksLinking = state.step == AssetConnectionStep.linkingBanks ||
        state.step == AssetConnectionStep.banksSearching ||
        state.step == AssetConnectionStep.banksLinking ||
        state.step == AssetConnectionStep.banksLinkingProgress;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (!didPop && !context.canPop()) {
            context.go('/aa-stocks-status');
          } else {
            context.go('/pan');
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F19),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Connecting your assets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.connectedCount} of 3 assets connected',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Timeline Items
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            AssetTimelineItem(
                              title: 'Mutual Funds',
                              subtitle: state.mfStatusMessage,
                              icon: Icons.pie_chart_outline_rounded,
                              isLinking: isMfLinking,
                              isCompleted: isMfDone,
                            ),
                            AssetTimelineItem(
                              title: 'Stocks',
                              subtitle: state.stocksStatusMessage,
                              icon: Icons.show_chart_rounded,
                              isLinking: isStocksLinking,
                              isCompleted: isStocksDone,
                            ),
                            AssetTimelineItem(
                              title: 'Banks',
                              subtitle: state.banksStatusMessage,
                              icon: Icons.account_balance_rounded,
                              isLinking: isBanksLinking,
                              isCompleted: state.banksConnected,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Security Shield Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Your data is 100% protected',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
