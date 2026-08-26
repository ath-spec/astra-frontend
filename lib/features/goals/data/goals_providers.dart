import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/goals/data/goals_models.dart';
import 'package:astra_frontend/features/goals/data/goals_repository.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepository(dioApiClient);
});

final goalsListProvider = FutureProvider<List<GoalItem>>((ref) async {
  final repo = ref.watch(goalsRepositoryProvider);
  return repo.listGoals();
});

final goalsSummaryProvider = FutureProvider<GoalsSummary>((ref) async {
  final repo = ref.watch(goalsRepositoryProvider);
  return repo.getSummary();
});
