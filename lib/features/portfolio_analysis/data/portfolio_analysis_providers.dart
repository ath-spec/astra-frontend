import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

final portfolioAllocationTipProvider = FutureProvider<AITipData>((ref) async {
  final repo = ref.watch(portfolioAnalysisRepositoryProvider);
  return repo.getAllocationTip();
});

final portfolioDisciplineTipProvider = FutureProvider<AITipData>((ref) async {
  final repo = ref.watch(portfolioAnalysisRepositoryProvider);
  return repo.getDisciplineTip();
});

final portfolioPerformanceTipProvider = FutureProvider<AITipData>((ref) async {
  final repo = ref.watch(portfolioAnalysisRepositoryProvider);
  return repo.getPerformanceTip();
});

class PortfolioAnalysisUnlockedNotifier extends StateNotifier<bool> {
  PortfolioAnalysisUnlockedNotifier() : super(false) {
    _loadState();
  }

  static const _storageKey = 'portfolio_analysis_unlocked';
  static const _storage = FlutterSecureStorage();

  Future<void> _loadState() async {
    try {
      final value = await _storage.read(key: _storageKey);
      if (value == 'true') {
        state = true;
      }
    } catch (_) {}
  }

  Future<void> setUnlocked(bool unlocked) async {
    state = unlocked;
    try {
      if (unlocked) {
        await _storage.write(key: _storageKey, value: 'true');
      } else {
        await _storage.delete(key: _storageKey);
      }
    } catch (_) {}
  }
}

/// Tracks whether the user has unlocked / completed the Portfolio Analysis walkthrough.
/// Persisted locally across app launches using FlutterSecureStorage.
final portfolioAnalysisUnlockedProvider =
    StateNotifierProvider<PortfolioAnalysisUnlockedNotifier, bool>((ref) {
  return PortfolioAnalysisUnlockedNotifier();
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
