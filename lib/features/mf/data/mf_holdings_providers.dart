import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/mf/data/mf_holdings_repository.dart';
import 'package:astra_frontend/features/mf/data/mf_holdings_models.dart';
import 'package:astra_frontend/features/mf/data/mf_transactions_models.dart';

final mfHoldingsRepositoryProvider = Provider<MfHoldingsRepository>((ref) {
  return MfHoldingsRepository(dioApiClient);
});

/// All MF transactions (`GET /api/v1/mf/transactions`) across every scheme.
final mfTransactionsProvider = FutureProvider<List<MfTransaction>>((ref) async {
  final repo = ref.watch(mfHoldingsRepositoryProvider);
  return repo.getTransactions();
});

/// MF transactions narrowed to a single scheme.
final mfTransactionsBySchemeProvider =
    FutureProvider.family<List<MfTransaction>, String?>((ref, schemeCode) async {
  final repo = ref.watch(mfHoldingsRepositoryProvider);
  return repo.getTransactions(schemeCode: schemeCode);
});

/// The Holdings screen's real MF portfolio (`GET /api/v1/mf/holdings`).
final mfHoldingsProvider = FutureProvider<MfHoldingsResponse>((ref) async {
  final repo = ref.watch(mfHoldingsRepositoryProvider);
  return repo.holdings();
});

/// Convenient selector returning just the list of [MfFolio]s from [mfHoldingsProvider].
final mfFoliosProvider = Provider<AsyncValue<List<MfFolio>>>((ref) {
  return ref.watch(mfHoldingsProvider).whenData((response) => response.folios);
});

/// Invalidates the holdings provider so widgets refetch (e.g. after an
/// order settles or a pull-to-refresh).
void invalidateMfHoldingsProviders(WidgetRef ref) {
  ref.invalidate(mfHoldingsProvider);
}
