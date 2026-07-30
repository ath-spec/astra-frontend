import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavContext { main, mf, explore }

/// Current nav context — main 3-tab vs MF section vs Explore section.
final navContextProvider = StateProvider<NavContext>((ref) => NavContext.main);

/// Active tab index within the MF section.
/// 0=Holdings, 1=Explore, 2=SIP, 3=Orders, 4=Watchlist
final mfTabIndexProvider = StateProvider<int>((ref) => 0);

/// Active tab index within the Explore section.
/// 0=Stocks, 1=ETFs, 2=Crypto
final exploreTabIndexProvider = StateProvider<int>((ref) => 0);
