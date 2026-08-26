import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/mf/data/watchlist_models.dart';
import 'package:astra_frontend/features/mf/data/watchlist_repository.dart';

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepository(dioApiClient);
});

/// Backs the Watchlist screen's list of saved funds.
final watchlistListProvider = FutureProvider<List<WatchlistItem>>((ref) async {
  final repo = ref.watch(watchlistRepositoryProvider);
  return repo.list();
});
