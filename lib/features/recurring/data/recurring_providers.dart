import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'package:astra_frontend/features/recurring/data/recurring_models.dart';
import 'package:astra_frontend/features/recurring/data/recurring_repository.dart';

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository(dioApiClient);
});

/// Mandates filtered by [statusFilter] (null/empty = all). Family so
/// `ref.invalidate(mandatesProvider(...))` (or the family as a whole) can be
/// used to refresh after a create/pause/resume/cancel mutation.
final mandatesProvider =
    FutureProvider.family<List<RecurringMandate>, String?>((ref, statusFilter) async {
  final repo = ref.watch(recurringRepositoryProvider);
  return repo.listMandates(statusFilter: statusFilter);
});

/// Convenience provider for the unfiltered mandate list (all statuses).
final allMandatesProvider = FutureProvider<List<RecurringMandate>>((ref) async {
  return ref.watch(mandatesProvider(null).future);
});

final recurringSummaryProvider = FutureProvider<RecurringSummary>((ref) async {
  final repo = ref.watch(recurringRepositoryProvider);
  return repo.summary();
});

final mandateHistoryProvider =
    FutureProvider.family<List<MandateExecution>, String>((ref, mandateId) async {
  final repo = ref.watch(recurringRepositoryProvider);
  return repo.history(mandateId);
});

/// Invalidates every provider that should be refreshed after a mandate is
/// created, paused, resumed, or cancelled. Called from widgets (with their
/// `WidgetRef`) after a successful create/pause/resume/cancel mutation.
void invalidateRecurringProviders(WidgetRef ref) {
  ref.invalidate(mandatesProvider);
  ref.invalidate(allMandatesProvider);
  ref.invalidate(recurringSummaryProvider);
}
