// ============================================================
// FILE: lib/features/transactions/data/transactions_providers.dart
// Riverpod DI for TransactionsRepository, following the same
// pattern as lib/features/mf/data/mf_holdings_providers.dart.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/core/network/api.dart';
import 'transactions_repository.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(dioApiClient);
});
