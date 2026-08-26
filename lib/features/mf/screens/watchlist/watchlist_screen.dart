import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/shimmer_card_skeleton.dart';
import '../../data/watchlist_models.dart';
import '../../data/watchlist_providers.dart';
import '../fund_profile/mf_fund_profile_screen.dart';

import 'widgets/mf_watchlist_empty_state.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 24),
              child: Text(
                'Watchlist',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                  letterSpacing: -1.0,
                ),
              ),
            ),
            Expanded(
              child: _buildBody(context, ref, watchlistAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<WatchlistItem>> watchlistAsync,
  ) {
    if (watchlistAsync.isLoading) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: const [
          AppThemeShimmerCard(height: 76),
          SizedBox(height: 12),
          AppThemeShimmerCard(height: 76),
          SizedBox(height: 12),
          AppThemeShimmerCard(height: 76),
        ],
      );
    }

    if (watchlistAsync.hasError) {
      final err = watchlistAsync.error;
      final message = err is ApiException
          ? err.message
          : 'Something went wrong. Please try again.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(watchlistListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final watchlist = watchlistAsync.value ?? const <WatchlistItem>[];

    if (watchlist.isEmpty) {
      return const MfWatchlistEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: watchlist.length,
      itemBuilder: (context, index) {
        final item = watchlist[index];
        final returnText = item.returns1y != null
            ? '${item.returns1y! >= 0 ? '+' : ''}${item.returns1y!.toStringAsFixed(2)}%'
            : '--';
        final returnColor = (item.returns1y ?? 0) >= 0
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);
        final logoText = item.amcName.isNotEmpty
            ? item.amcName
                .split(' ')
                .take(2)
                .map((w) => w.isNotEmpty ? w[0] : '')
                .join()
                .toUpperCase()
            : 'MF';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Dismissible(
            key: ValueKey(item.schemeCode),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              try {
                await ref
                    .read(watchlistRepositoryProvider)
                    .remove(item.schemeCode);
                ref.invalidate(watchlistListProvider);
                return true;
              } catch (e) {
                final message = e is ApiException
                    ? e.message
                    : 'Something went wrong. Please try again.';
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
                return false;
              }
            },
            child: InkWell(
              onTap: () =>
                  MfFundProfileScreen.showModal(context, item.schemeCode),
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    // Logo Circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Center(
                        child: Text(
                          logoText,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.schemeName,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.category,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          returnText,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: returnColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '1Y Return',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
