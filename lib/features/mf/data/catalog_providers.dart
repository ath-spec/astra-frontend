import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/mf/data/catalog_models.dart';
import 'package:astra_frontend/features/mf/data/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(dioApiClient);
});

final allCatalogFundsProvider = FutureProvider<List<CatalogFund>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.searchFunds(limit: 50);
});

final catalogNfosProvider = FutureProvider<List<NfoItem>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.listNfos();
});

final fundProfileFamilyProvider =
    FutureProvider.family<FundProfileDetail, String>((ref, schemeCode) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getFundProfile(schemeCode);
});
