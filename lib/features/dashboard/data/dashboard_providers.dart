import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:astra_frontend/features/dashboard/data/dashboard_models.dart';
import 'package:astra_frontend/features/mf/data/mf_holdings_providers.dart';
import 'package:astra_frontend/features/mf/data/catalog_providers.dart';
import 'package:astra_frontend/features/fd/data/fd_providers.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(dioApiClient);
});

/// The Home screen's wealth/asset summary (`GET /api/v1/dashboard/summary`).
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.summary();
});

/// The Home screen's portfolio-growth series
/// (`GET /api/v1/dashboard/growth?days=...`), keyed by the lookback window
/// in days so each selected timeframe (1M/6M/1Y/ALL) gets its own cached
/// fetch.
final dashboardGrowthProvider =
    FutureProvider.family<List<DashboardGrowthPoint>, int>((ref, days) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.growth(days: days);
});

/// Invalidates every provider whose data can shift when linked accounts
/// change (e.g. after linking, unlinking, or revoking a bank account, MF, or
/// stock holding, or pulling to refresh): the Home screen's hero
/// summary/growth chart, MF holdings, and the MF Explore catalog (its
/// "Alternative to FD" cards blend live FD/bank figures into fund
/// comparisons, so a stale catalog fetch kept showing pre-link numbers there
/// too). Takes a plain [Ref] (not [WidgetRef]) so it can be called from
/// inside a notifier — e.g. right after a bank account unlink/revoke
/// commits — and not only from widget build methods.
void invalidateDashboardProviders(Ref ref) {
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(dashboardGrowthProvider);
  ref.invalidate(mfHoldingsProvider);
  ref.invalidate(mfTransactionsProvider);
  ref.invalidate(allCatalogFundsProvider);
  ref.invalidate(catalogNfosProvider);
  ref.invalidate(activeFdsProvider);
}
