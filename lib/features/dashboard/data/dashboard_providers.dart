import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:astra_frontend/features/dashboard/data/dashboard_models.dart';

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

/// Invalidates the dashboard providers so widgets refetch (e.g. after
/// linking, unlinking, or revoking an account, or pulling to refresh).
/// Takes a plain [Ref] (not [WidgetRef]) so it can be called from inside a
/// notifier — e.g. right after a bank account unlink/revoke commits — and
/// not only from widget build methods.
void invalidateDashboardProviders(Ref ref) {
  ref.invalidate(dashboardSummaryProvider);
  ref.invalidate(dashboardGrowthProvider);
}
