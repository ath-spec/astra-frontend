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
