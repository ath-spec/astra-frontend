import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/data/dashboard_providers.dart';

class BankAccountItem {
  const BankAccountItem({
    required this.id,
    required this.shortId,
    required this.bankName,
    required this.accountNumber,
    required this.isSelected,
    required this.isLinked,
    required this.ifsc,
    required this.branch,
    this.balance = 0.0,
    this.accountType = 'SAVINGS',
  });

  final String id;
  // Last-4-chars display fragment — for the "• db88" style reference shown
  // under the bank name on the linked-accounts card. Never send this to the
  // backend; use [id] for that (see fromJson's comment on why this used to
  // be conflated).
  final String shortId;
  final String bankName;
  final String accountNumber;
  final bool isSelected;
  final bool isLinked;
  final String ifsc;
  final String branch;
  final double balance;
  final String accountType;

  factory BankAccountItem.fromJson(Map<String, dynamic> json) {
    final bName = json['bank_name']?.toString() ?? 'Bank Account';
    final idStr = json['id']?.toString() ?? '0000';
    final bal = (json['balance'] as num?)?.toDouble() ?? 0.0;
    final aType = json['account_type']?.toString() ?? 'SAVINGS';
    // Only IDBI-synced accounts carry a real account_number (see
    // aa_handler.go's GetAccounts) — manually added ones never collected
    // one. shortId used to be the last 4 chars of the internal id, which is
    // a hex UUID fragment and can contain letters (e.g. "db88") — wrong for
    // something styled as a bank account's last-4-digits. Use the real
    // number's last 4 when we have one; otherwise synthesize a digits-only
    // 4-char code instead of exposing hex.
    final rawAccNum = json['account_number']?.toString();
    final shortId = (rawAccNum != null && rawAccNum.isNotEmpty)
        ? (rawAccNum.length > 4 ? rawAccNum.substring(rawAccNum.length - 4) : rawAccNum.padLeft(4, '0'))
        : _numericShortId(idStr);
    final accNum = rawAccNum ??
        json['masked_account_number']?.toString() ??
        '$aType account - xxxx $shortId';
    final ifscCode = json['ifsc']?.toString() ??
        json['ifsc_code']?.toString() ??
        _deriveIfsc(bName, shortId);
    final branchName = json['branch']?.toString() ??
        json['branch_name']?.toString() ??
        _deriveBranch(bName);

    // GetAccounts (real, already-linked) and DiscoverAccounts (simulated AA
    // discovery, not yet linked) share this shape; is_linked distinguishes
    // them. Defaults to true so any older/other caller that omits the field
    // keeps its previous behaviour.
    final linked = json['is_linked'] as bool? ?? true;

    return BankAccountItem(
      // The full id, not shortId — shortId is a display-only fragment
      // (last 4 chars, used for the masked account number below). Using it
      // as the actual id meant every revoke/unlink call sent a 4-character
      // string instead of the real UUID, so the backend's uuid.Parse always
      // failed with "invalid account ID" — every account, every time.
      id: idStr,
      shortId: shortId,
      bankName: bName,
      accountNumber: accNum,
      // Discovery now returns the full per-user inventory (every bank in
      // the archetype pool, several account slots each) instead of two
      // pre-picked candidates — pre-checking all of them would hand the
      // user a huge already-ticked list to fight with. Nothing starts
      // selected; the linking screen is a plain picker now.
      isSelected: false,
      isLinked: linked,
      balance: bal,
      ifsc: ifscCode,
      branch: branchName,
      accountType: aType,
    );
  }

  /// Deterministic digits-only 4-char code derived from [seed] (typically
  /// the account's internal id) — used when there's no real account number
  /// to take the last 4 digits from.
  static String _numericShortId(String seed) {
    final n = seed.hashCode.abs() % 10000;
    return n.toString().padLeft(4, '0');
  }

  static String _deriveIfsc(String bankName, String shortId) {
    final lower = bankName.toLowerCase();
    final padded = shortId.padLeft(4, '0');
    if (lower.contains('hdfc')) return 'HDFC000$padded';
    if (lower.contains('icici')) return 'ICIC000$padded';
    if (lower.contains('sbi') || lower.contains('state bank')) return 'SBIN000$padded';
    if (lower.contains('axis')) return 'UTIB000$padded';
    if (lower.contains('kotak')) return 'KKBK000$padded';
    if (lower.contains('pnb') || lower.contains('punjab')) return 'PUNB000$padded';
    if (lower.contains('canara')) return 'CNRB000$padded';
    if (lower.contains('indusind')) return 'INDB000$padded';
    if (lower.contains('baroda')) return 'BARB000$padded';
    if (lower.contains('yes')) return 'YESB000$padded';
    final prefix = bankName.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase().padRight(4, 'X').substring(0, 4);
    return '${prefix}000$padded';
  }

  static String _deriveBranch(String bankName) {
    final lower = bankName.toLowerCase();
    if (lower.contains('hdfc')) return 'MUMBAI - NARIMAN POINT';
    if (lower.contains('icici')) return 'MUMBAI - BKC';
    if (lower.contains('sbi')) return 'MUMBAI - FORT MAIN';
    if (lower.contains('axis')) return 'MUMBAI - WORLI';
    if (lower.contains('kotak')) return 'MUMBAI - KALINA';
    return 'MUMBAI - MAIN BRANCH';
  }

  BankAccountItem copyWith({
    String? id,
    String? shortId,
    String? bankName,
    String? accountNumber,
    bool? isSelected,
    bool? isLinked,
    String? ifsc,
    String? branch,
    double? balance,
    String? accountType,
  }) {
    return BankAccountItem(
      id: id ?? this.id,
      shortId: shortId ?? this.shortId,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isSelected: isSelected ?? this.isSelected,
      isLinked: isLinked ?? this.isLinked,
      ifsc: ifsc ?? this.ifsc,
      branch: branch ?? this.branch,
      balance: balance ?? this.balance,
      accountType: accountType ?? this.accountType,
    );
  }
}

enum AssetConnectionStep {
  linkingMutualFunds,
  mutualFundsStatus,
  linkingStocks,
  stocksOtp,
  stocksVerifying,
  stocksSearching,
  stocksStatus,
  linkingBanks,
  banksSearching,
  banksLinking,
  banksLinkingProgress,
  completed,
}

class AssetConnectionState {
  const AssetConnectionState({
    required this.step,
    required this.mfConnected,
    required this.stocksConnected,
    required this.banksConnected,
    required this.mfStatusMessage,
    required this.stocksStatusMessage,
    required this.banksStatusMessage,
    required this.bankAccounts,
    this.bankAccountsLoaded = false,
    this.availableBanks = const [],
    this.availableBanksLoaded = false,
  });

  final AssetConnectionStep step;
  final bool mfConnected;
  final bool stocksConnected;
  final bool banksConnected;
  final String mfStatusMessage;
  final String stocksStatusMessage;
  final String banksStatusMessage;
  final List<BankAccountItem> bankAccounts;
  // True once a live fetchLiveBankAccounts() call has actually completed
  // (success or failure) at least once for the current session — lets a
  // consumer tell "confirmed zero accounts" apart from "haven't checked the
  // real backend yet," which `banksConnected` alone can't distinguish.
  final bool bankAccountsLoaded;
  final List<String> availableBanks;
  final bool availableBanksLoaded;

  AssetConnectionState copyWith({
    AssetConnectionStep? step,
    bool? mfConnected,
    bool? stocksConnected,
    bool? banksConnected,
    String? mfStatusMessage,
    String? stocksStatusMessage,
    String? banksStatusMessage,
    List<BankAccountItem>? bankAccounts,
    bool? bankAccountsLoaded,
    List<String>? availableBanks,
    bool? availableBanksLoaded,
  }) {
    return AssetConnectionState(
      step: step ?? this.step,
      mfConnected: mfConnected ?? this.mfConnected,
      stocksConnected: stocksConnected ?? this.stocksConnected,
      banksConnected: banksConnected ?? this.banksConnected,
      mfStatusMessage: mfStatusMessage ?? this.mfStatusMessage,
      stocksStatusMessage: stocksStatusMessage ?? this.stocksStatusMessage,
      banksStatusMessage: banksStatusMessage ?? this.banksStatusMessage,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      bankAccountsLoaded: bankAccountsLoaded ?? this.bankAccountsLoaded,
      availableBanks: availableBanks ?? this.availableBanks,
      availableBanksLoaded: availableBanksLoaded ?? this.availableBanksLoaded,
    );
  }
}

class AssetConnectionNotifier extends StateNotifier<AssetConnectionState> {
  // Fetching once at provider-construction time is a race: this provider is
  // a plain (non-autoDispose) StateNotifierProvider, so it's built exactly
  // once and can be created before, during, or after the auth flow settles
  // (fresh verifyOtp, restoreSession on relaunch, token refresh, ...). A
  // returning user whose accounts are already linked server-side could have
  // that one-shot call race the login transition or hit a transient error
  // (silently swallowed), permanently misreporting "not connected" for the
  // rest of the session with nothing to ever retry it. Listening to
  // authProvider instead means every time the app actually settles into an
  // authenticated state, this refetches for real — not just once, hopefully
  // at the right time.
  AssetConnectionNotifier(Ref ref)
      : _ref = ref,
        super(
          const AssetConnectionState(
            step: AssetConnectionStep.linkingMutualFunds,
            mfConnected: false,
            stocksConnected: false,
            banksConnected: false,
            mfStatusMessage: 'Not Linked',
            stocksStatusMessage: 'Not Linked',
            banksStatusMessage: 'Not Linked',
            bankAccounts: [],
            availableBanks: [],
            availableBanksLoaded: false,
          ),
        ) {
    fetchLiveBankAccounts();
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthAuthenticated && previous is! AuthAuthenticated) {
        fetchLiveBankAccounts();
        // dashboardSummaryProvider is a plain FutureProvider — it fetches
        // once and then holds that result for the rest of the app session.
        // Without this, a fresh login/signup after a previous session (a
        // different test account, or the same account post-DB-clear) kept
        // showing the Home screen's Bank Accounts total from whoever was
        // logged in before, until the user happened to pull-to-refresh.
        invalidateDashboardProviders(ref);
      }
    });
  }

  String? _pendingBaseBankId;

  void setPendingBaseBankId(String id) {
    _pendingBaseBankId = id;
  }


  void setMfConnected(bool connected) {
    state = state.copyWith(
      mfConnected: connected,
      mfStatusMessage: connected ? 'Successfully Linked' : 'Not Linked',
    );
    // Without this, the Home screen's net worth/summary kept showing
    // whatever it had before this link completed until the user manually
    // pulled to refresh — same stale-provider issue as the auth-transition
    // case above, just triggered by finishing onboarding instead of logging
    // in.
    if (connected) invalidateDashboardProviders(_ref);
  }

  void setStocksConnected(bool connected) {
    state = state.copyWith(
      stocksConnected: connected,
      stocksStatusMessage: connected ? '2 Demat Accounts Connected' : 'Not Linked',
    );
    if (connected) invalidateDashboardProviders(_ref);
  }

  void setBanksConnected(bool connected) {
    state = state.copyWith(
      banksConnected: connected,
      banksStatusMessage: connected ? 'Successfully Linked' : 'Not Linked',
    );
    if (connected) invalidateDashboardProviders(_ref);
  }

  void resetAll() {
    state = const AssetConnectionState(
      step: AssetConnectionStep.linkingMutualFunds,
      mfConnected: false,
      stocksConnected: false,
      banksConnected: false,
      mfStatusMessage: 'Not Linked',
      stocksStatusMessage: 'Not Linked',
      banksStatusMessage: 'Not Linked',
      bankAccounts: [],
      availableBanks: [],
      availableBanksLoaded: false,
    );
  }

  final Ref _ref;
  Timer? _timer;
  final _api = DioApiClient();

  /// Fetches live bank accounts from backend PostgreSQL (/api/v1/aa/accounts).
  /// Always marks bankAccountsLoaded so callers (e.g. showFoundBanks) can
  /// tell a completed check apart from one that never ran.
  Future<void> fetchLiveBankAccounts() async {
    try {
      final res = await _api.dio.get('/api/v1/aa/accounts');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        // Every /api/v1 response is wrapped in the standard envelope —
        // {"error": bool, "data": {...}} — but this was reading `accounts`
        // directly off the envelope's top level instead of unwrapping
        // `data` first. res.data['accounts'] was always null (the real key
        // is res.data['data']['accounts']), so this returned 200 every time
        // and silently fell through the `if (list != null)` branch without
        // ever touching state.bankAccounts. That's why newly linked
        // accounts never showed up on "Your Accounts"/"Manage Accounts" —
        // both just read this provider's state, which this call was never
        // actually updating — and why showFoundBanks()'s "state.bankAccounts
        // is still empty after fetching" check kept tripping and falling
        // back to its two fake discovered accounts.
        final envelopeData = res.data['data'];
        final list = envelopeData is Map<String, dynamic> ? envelopeData['accounts'] as List<dynamic>? : null;
        if (list != null) {
          final items = list
              .whereType<Map<String, dynamic>>()
              .map((json) => BankAccountItem.fromJson(json))
              .toList();

          // Preserve unlinked candidates (but filter out any that just became linked)
          // so the UI list doesn't temporarily collapse before the next /discover call finishes.
          final newlyLinkedIds = items.map((b) => b.id).toSet();
          final unlinkedAccounts = state.bankAccounts.where((b) => !b.isLinked && !newlyLinkedIds.contains(b.id)).toList();
          final merged = [...items, ...unlinkedAccounts];

          state = state.copyWith(
            bankAccounts: merged,
            banksConnected: items.isNotEmpty,
            banksStatusMessage: items.isNotEmpty ? 'Successfully Linked' : 'No accounts linked',
            bankAccountsLoaded: true,
          );
          return;
        }
      }
      state = state.copyWith(bankAccountsLoaded: true);
    } catch (e) {
      // Offline or not logged in yet — keep whatever accounts are already
      // in state (don't destructively clear a good result on a transient
      // network blip), but still mark the attempt as complete so a caller
      // waiting on bankAccountsLoaded doesn't hang forever, and log it
      // instead of swallowing it silently.
      debugPrint('fetchLiveBankAccounts failed: $e');
      state = state.copyWith(bankAccountsLoaded: true);
    }
  }

  void startOnboardingFlow() {
    state = const AssetConnectionState(
      step: AssetConnectionStep.linkingMutualFunds,
      mfConnected: false,
      stocksConnected: false,
      banksConnected: false,
      mfStatusMessage: 'Linking now...',
      stocksStatusMessage: 'Pending',
      banksStatusMessage: 'Pending',
      bankAccounts: [],
      availableBanks: [],
      availableBanksLoaded: false,
    );
    fetchLiveBankAccounts();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        state = state.copyWith(
          step: AssetConnectionStep.mutualFundsStatus,
          mfStatusMessage: 'QR Upload Skipped',
        );
      }
    });
  }

  void connectMutualFunds() {
    _timer?.cancel();
    state = state.copyWith(
      mfConnected: true,
      mfStatusMessage: 'Successfully Linked',
    );
  }

  void proceedToStocks() {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.linkingStocks,
      mfConnected: true,
      mfStatusMessage: 'QR Upload Skipped',
      stocksStatusMessage: 'Linking now...',
    );
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        state = state.copyWith(
          step: AssetConnectionStep.stocksOtp,
          stocksStatusMessage: 'OTP Required',
        );
      }
    });
  }

  void verifyStocksOtp(String otp) {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.stocksVerifying,
      stocksStatusMessage: 'Verifying OTP...',
    );
  }

  void startStocksSearch() {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.stocksSearching,
      stocksStatusMessage: 'Searching demat accounts...',
    );
  }

  void showStocksStatus() {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.stocksStatus,
    );
  }

  void retryStocksOtp() {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.stocksOtp,
      stocksStatusMessage: 'OTP Required',
    );
  }

  void continueWithoutStocks() {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.linkingBanks,
      stocksConnected: false,
      stocksStatusMessage: 'Skipped. You can add it later',
      banksStatusMessage: 'Linking now...',
    );
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        state = state.copyWith(
          step: AssetConnectionStep.banksLinking,
          banksStatusMessage: 'Select accounts to link',
        );
      }
    });
  }

  void connectFoundStocks() {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.linkingBanks,
      stocksConnected: true,
      stocksStatusMessage: '2 Demat Accounts Connected',
      banksStatusMessage: 'Linking now...',
    );
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        state = state.copyWith(
          step: AssetConnectionStep.banksLinking,
          banksStatusMessage: 'Select accounts to link',
        );
      }
    });
  }

  void skipStocks() {
    _timer?.cancel();
    continueWithoutStocks();
  }

  /// Shows the user's bank accounts on the linking screen. This used to
  /// immediately fabricate two hardcoded "discovered" accounts client-side —
  /// the same fixed ICICI/HDFC pair, same fake balances, for every single
  /// user. Now it calls a real backend endpoint (GET
  /// /api/v1/aa/accounts/discover) that generates deterministic-per-user
  /// discovery candidates server-side — the same pattern the app already
  /// uses for its other mocked data sources (stocks/MF/FD), not one-off fake
  /// data living only in this file. The backend already excludes any bank
  /// the user has actually linked (WHERE unlinked_at IS NULL), so it's safe
  /// to call unconditionally: a returning user with one bank connected who
  /// wants to connect more still gets shown fresh AA candidates for the
  /// banks they *haven't* linked, instead of discovery being skipped
  /// entirely just because bankAccounts wasn't empty.
  ///
  /// This runs again every time the linking screen remounts (e.g. after
  /// PROCEED -> banks-searching -> pushReplacement('/banks-linking') for an
  /// unrelated manually-picked bank), and the backend always returns its
  /// discovered candidates pre-checked (isSelected: true). Rebuilding the
  /// list from those fresh objects on every rerun silently re-checked any
  /// discovered candidate the user had already unchecked — it looked like
  /// unchecking simply didn't stick. Existing selection state (matched by
  /// id) for a still-unlinked candidate is preserved here instead of being
  /// clobbered by the fresh fetch.
  Future<void> showFoundBanks() async {
    _timer?.cancel();
    final priorSelection = {
      for (final b in state.bankAccounts.where((b) => !b.isLinked)) b.id: b.isSelected,
    };
    await fetchLiveBankAccounts();
    final linkedAccounts = state.bankAccounts.where((b) => b.isLinked).toList();
    // A genuinely first-ever visit (nothing picked before, nothing already
    // linked) pre-selects just the first two discovered candidates instead
    // of dumping the whole pool as an unselected picker — matches "two
    // accounts fetched the first time" onboarding is meant to show, with
    // everything else reachable via CONNECT MORE ACCOUNTS.
    final isFirstVisit = priorSelection.isEmpty && linkedAccounts.isEmpty;
    try {
      final res = await _api.dio.get('/api/v1/aa/accounts/detected');
      final envelopeData = res.data is Map<String, dynamic> ? res.data['data'] : null;
      final list = envelopeData is Map<String, dynamic> ? envelopeData['accounts'] as List<dynamic>? : null;
      final discoveredAccounts = (list ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((json) => BankAccountItem.fromJson(json))
          .toList();
      for (var i = 0; i < discoveredAccounts.length; i++) {
        final b = discoveredAccounts[i];
        if (priorSelection.containsKey(b.id)) {
          discoveredAccounts[i] = b.copyWith(isSelected: priorSelection[b.id]);
        } else if (isFirstVisit) {
          // During onboarding (first visit), automatically select all detected candidates
          // so the user has a populated list to proceed with rather than an empty screen.
          discoveredAccounts[i] = b.copyWith(isSelected: true);
        } else if (_pendingBaseBankId == b.id) {
          discoveredAccounts[i] = b.copyWith(isSelected: true);
        }
      }
      final merged = [...linkedAccounts, ...discoveredAccounts];
      state = state.copyWith(
        step: AssetConnectionStep.banksLinking,
        bankAccounts: merged,
        banksStatusMessage: merged.isEmpty ? 'No accounts found' : 'Accounts found',
      );
    } catch (e) {
      debugPrint('discover accounts failed: $e');
      state = state.copyWith(
        step: AssetConnectionStep.banksLinking,
        banksStatusMessage: linkedAccounts.isEmpty
            ? 'Could not check for accounts. Please try again.'
            : 'Accounts found',
      );
    }
  }

  Future<void> fetchAvailableBanks() async {
    try {
      final res = await _api.dio.get('/api/v1/aa/accounts/available-banks');
      final envelopeData = res.data is Map<String, dynamic> ? res.data['data'] : null;
      final list = envelopeData is Map<String, dynamic> ? envelopeData['banks'] as List<dynamic>? : null;
      final banks = (list ?? const []).whereType<String>().toList();
      state = state.copyWith(
        availableBanks: banks,
        availableBanksLoaded: true,
      );
    } catch (e) {
      debugPrint('fetch available banks failed: $e');
      state = state.copyWith(
        availableBanksLoaded: true,
      );
    }
  }

  void toggleBankSelection(String id) {
    final updated = state.bankAccounts.map((b) {
      if (b.id == id && !b.isLinked) {
        return b.copyWith(isSelected: !b.isSelected);
      }
      return b;
    }).toList();
    state = state.copyWith(bankAccounts: updated);
  }

  /// "CONNECT MORE ACCOUNTS" checks banks first (plain local UI state, no
  /// network call), then PROCEED calls this once for every checked bank —
  /// asking the backend's discovery inventory specifically for those banks'
  /// candidate accounts and merging the response into "YOUR ACCOUNTS",
  /// pre-checked. This is a second, explicit fetch (not just filtering data
  /// already on the client) so the flow mirrors a real AA re-discovery step:
  /// "tell us which banks you want, we'll go fetch their accounts."
  /// Fetched accounts land pre-selected, but the user can still uncheck any
  /// of them afterward — APPROVE AND CONNECT only ever links whatever is
  /// checked at that moment, not everything this call ever returned.
  Future<void> fetchAccountsForBanks(List<String> bankNames) async {
    if (bankNames.isEmpty) return;
    try {
      final res = await _api.dio.get(
        '/api/v1/aa/accounts/discover',
        queryParameters: {'banks': bankNames.join(',')},
      );
      final envelopeData = res.data is Map<String, dynamic> ? res.data['data'] : null;
      final list = envelopeData is Map<String, dynamic> ? envelopeData['accounts'] as List<dynamic>? : null;
      
      final parsed = (list ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((json) => BankAccountItem.fromJson(json))
          .toList();
          
      // Select exactly the FIRST returned slot per bank so it becomes visible
      // in the UI (since the list only shows selected accounts). 
      final seenBanks = <String>{};
      final fetched = parsed.map((b) {
        if (!seenBanks.contains(b.bankName)) {
          seenBanks.add(b.bankName);
          return b.copyWith(isSelected: true);
        }
        return b; // Leave isSelected: false for additional slots
      }).toList();

      final fetchedIds = fetched.map((b) => b.id).toSet();
      final others = state.bankAccounts.where((b) => !fetchedIds.contains(b.id)).toList();
      state = state.copyWith(bankAccounts: [...others, ...fetched]);
      
      // Also refresh the available banks list so picked banks disappear from the UI
      await fetchAvailableBanks();
    } catch (e) {
      debugPrint('fetchAccountsForBanks failed for $bankNames: $e');
      state = state.copyWith(
        banksStatusMessage: 'Could not fetch accounts for the selected bank(s). Please try again.',
      );
    }
  }

  void startBankLinking() {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.banksLinkingProgress,
      banksStatusMessage: 'Linking accounts...',
    );
    _timer = Timer(const Duration(milliseconds: 2600), () {
      completeBankLinking();
    });
  }

  Future<void> completeBankLinking() async {
    _timer?.cancel();
    final updated = <BankAccountItem>[];
    bool anyFailed = false;
    for (final b in state.bankAccounts) {
      if (b.isSelected) {
        try {
          await _api.dio.post<dynamic>('/api/v1/aa/accounts', data: {
            'bank_name': b.bankName,
            'account_type': b.accountType,
            'balance': b.balance,
            'ifsc': b.ifsc,
            'branch': b.branch,
          });
          updated.add(b.copyWith(isLinked: true, isSelected: false));
        } catch (_) {
          anyFailed = true;
          updated.add(b);
        }
      } else {
        updated.add(b);
      }
    }
    final hasAnyLinked = updated.any((b) => b.isLinked);
    final statusMessage = anyFailed
        ? (hasAnyLinked
            ? 'Some accounts could not be linked — please retry.'
            : 'Could not link accounts. Please check your connection and try again.')
        : (hasAnyLinked ? 'Successfully Linked' : 'Accounts found');
    state = state.copyWith(
      step: AssetConnectionStep.banksLinking,
      bankAccounts: updated,
      banksConnected: hasAnyLinked,
      banksStatusMessage: statusMessage,
    );
    if (hasAnyLinked) invalidateDashboardProviders(_ref);
  }

  void removeBankByName(String bankName) {
    _timer?.cancel();
    final updatedBanks = state.bankAccounts.where((b) => b.bankName != bankName).toList();
    state = state.copyWith(
      bankAccounts: updatedBanks,
    );
  }

  Future<bool> approveAndConnectAll() async {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.banksLinkingProgress,
      banksStatusMessage: 'Linking accounts...',
    );
    final discovered = state.bankAccounts.where((b) => b.isSelected && !b.isLinked).toList();
    if (discovered.isEmpty) {
      // Nothing to do
      await fetchLiveBankAccounts();
      return true;
    }

    try {
      final selectedIds = discovered.map((b) => b.id).toList();
      await _api.dio.post<dynamic>('/api/v1/aa/accounts/connect', data: {
        'selected_existing_accounts': selectedIds,
        'banks_to_add': const <String>[],
      });
      
      await fetchLiveBankAccounts();
      final hasAnyLinked = state.bankAccounts.any((b) => b.isLinked);
      if (hasAnyLinked) invalidateDashboardProviders(_ref);
      return true;
    } catch (e) {
      debugPrint('ConnectAccounts failed: $e');
      await fetchLiveBankAccounts();
      state = state.copyWith(banksStatusMessage: 'Some accounts could not be linked — please retry.');
      return false;
    }
  }

  void resetSelectionForUnlinked() {
    final updated = state.bankAccounts.map((b) {
      if (!b.isLinked) {
        return b.copyWith(isSelected: false);
      }
      return b;
    }).toList();
    state = state.copyWith(bankAccounts: updated);
  }

  /// Returns true on success. A revoke of an IDBI-synced account ends the
  /// whole IDBI sync for this user server-side (there's no per-account
  /// revoke there — see AAHandler.UnlinkAccount), so this always refetches
  /// the authoritative account list from the backend afterward rather than
  /// just patching out the one `id` the user tapped: other IDBI accounts in
  /// `state.bankAccounts` need to disappear too, not just this one. It also
  /// invalidates the Home screen's net worth/dashboard summary so the bank
  /// balance total and net worth reflect the removed account immediately,
  /// instead of only updating on the next unrelated dashboard refetch.
  Future<bool> revokeBankConnection(String id) async {
    _timer?.cancel();
    try {
      await _api.dio.delete('/api/v1/aa/accounts/$id');
    } catch (e) {
      debugPrint('revokeBankConnection failed: $e');
      return false;
    }

    await fetchLiveBankAccounts();
    final hasAnyLinked = state.bankAccounts.any((b) => b.isLinked);
    state = state.copyWith(
      banksConnected: hasAnyLinked,
      banksStatusMessage: hasAnyLinked ? 'Successfully Linked' : 'Accounts found',
    );
    invalidateDashboardProviders(_ref);
    return true;
  }

  void skipBanks() {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.completed,
      banksStatusMessage: 'Skipped. You can add it later',
    );
  }

  void finishAssetConnection() {
    _timer?.cancel();
    final hasAnyLinked = state.bankAccounts.any((b) => b.isLinked);
    state = state.copyWith(
      step: AssetConnectionStep.completed,
      banksConnected: hasAnyLinked,
      banksStatusMessage: hasAnyLinked ? 'Successfully Linked' : 'Skipped. You can add it later',
    );
  }

  void finishOnboarding() {
    _timer?.cancel();
    finishAssetConnection();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final assetConnectionProvider =
    StateNotifierProvider<AssetConnectionNotifier, AssetConnectionState>((ref) {
  return AssetConnectionNotifier(ref);
});
