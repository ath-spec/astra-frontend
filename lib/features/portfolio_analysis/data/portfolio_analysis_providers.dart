import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/portfolio_analysis/data/portfolio_analysis_models.dart';
import 'package:astra_frontend/features/portfolio_analysis/data/portfolio_analysis_repository.dart';

final portfolioAnalysisRepositoryProvider = Provider<PortfolioAnalysisRepository>((ref) {
  return PortfolioAnalysisRepository(dioApiClient);
});

final portfolioAllocationProvider = FutureProvider<AllocationData>((ref) async {
  final repo = ref.watch(portfolioAnalysisRepositoryProvider);
  return repo.getAllocation();
});

final portfolioDisciplineProvider = FutureProvider<DisciplineData>((ref) async {
  final repo = ref.watch(portfolioAnalysisRepositoryProvider);
  return repo.getDiscipline();
});

final portfolioPerformanceProvider = FutureProvider<PerformanceData>((ref) async {
  final repo = ref.watch(portfolioAnalysisRepositoryProvider);
  return repo.getPerformance();
});

/// Single Source of Truth for the user's Current Portfolio DNA across all screens.
/// Uses the live Portfolio Genome computed and returned directly by the backend API.
final portfolioDnaProvider = Provider<List<double>>((ref) {
  final alloc = ref.watch(portfolioAllocationProvider).valueOrNull;
  if (alloc?.genome != null && alloc!.genome!.values.isNotEmpty) {
    return alloc.genome!.values;
  }
  if (alloc != null) {
    final equityFactor = (alloc.equityPct / 100).clamp(0.15, 0.95);
    final debtFactor = (alloc.debtPct / 100).clamp(0.10, 0.85);
    final otherFactor = (alloc.otherPct / 100).clamp(0.08, 0.75);

    return [
      equityFactor,
      debtFactor > 0.05 ? debtFactor : 0.30,
      debtFactor > 0.05 ? (debtFactor * 0.9) : 0.15,
      otherFactor > 0.05 ? (otherFactor * 2.0).clamp(0.1, 0.9) : 0.40,
      0.80,
      0.50,
      otherFactor > 0.05 ? (otherFactor * 1.5).clamp(0.1, 0.85) : 0.10,
    ];
  }
  return const [0.85, 0.30, 0.15, 0.40, 0.80, 0.50, 0.10];
});
