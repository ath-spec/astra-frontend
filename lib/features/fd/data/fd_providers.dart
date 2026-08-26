import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/fd/data/fd_models.dart';
import 'package:astra_frontend/features/fd/data/fd_repository.dart';

final fdRepositoryProvider = Provider<FDRepository>((ref) {
  return FDRepository(dioApiClient);
});

final activeFdsProvider = FutureProvider<List<FDAccountItem>>((ref) async {
  final repo = ref.watch(fdRepositoryProvider);
  return repo.listFDs();
});
