import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistNotifier extends StateNotifier<List<String>> {
  WatchlistNotifier() : super([]);

  void toggleFund(String fundId) {
    if (state.contains(fundId)) {
      state = state.where((id) => id != fundId).toList();
    } else {
      state = [...state, fundId];
    }
  }
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<String>>((ref) {
  return WatchlistNotifier();
});
