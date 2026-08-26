import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/mf/data/mf_holdings_repository.dart';
import 'package:astra_frontend/features/mf/data/mf_holdings_models.dart';

final mfHoldingsRepositoryProvider = Provider<MfHoldingsRepository>((ref) {
  return MfHoldingsRepository(dioApiClient);
});

/// The Holdings screen's real MF portfolio (`GET /api/v1/mf/holdings`).
final mfHoldingsProvider = FutureProvider<MfHoldingsResponse>((ref) async {
  final repo = ref.watch(mfHoldingsRepositoryProvider);
  return repo.holdings();
});

/// Invalidates the holdings provider so widgets refetch (e.g. after an
/// order settles or a pull-to-refresh).
void invalidateMfHoldingsProviders(WidgetRef ref) {
  ref.invalidate(mfHoldingsProvider);
}
