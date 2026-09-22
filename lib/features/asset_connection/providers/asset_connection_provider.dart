import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/data/dashboard_providers.dart';

class BankAccountItem {
  const BankAccountItem({
    required this.id,
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
    final shortId = idStr.length > 4 ? idStr.substring(idStr.length - 4) : idStr;
    final bal = (json['balance'] as num?)?.toDouble() ?? 0.0;
    final aType = json['account_type']?.toString() ?? 'SAVINGS';
    final accNum = json['account_number']?.toString() ??
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
      bankName: bName,
      accountNumber: accNum,
      isSelected: true,
      isLinked: linked,
      balance: bal,
      ifsc: ifscCode,
      branch: branchName,
      accountType: aType,
    );
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
    this.pendingBankNames = const [],
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
  // Banks staged via PROCEED (checked in the picker, "fetched" into the
  // account list) but not yet actually linked server-side — that only
  // happens on APPROVE AND CONNECT. Lives on the provider, not local widget
  // state, because the fetching screen navigates with pushReplacement,
  // which destroys and recreates BanksLinkingScreen's State — anything kept
  // in local fields there would silently vanish on the round trip.
  final List<String> pendingBankNames;

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
    List<String>? pendingBankNames,
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
      pendingBankNames: pendingBankNames ?? this.pendingBankNames,
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

  void setMfConnected(bool connected) {
    state = state.copyWith(
      mfConnected: connected,
      mfStatusMessage: connected ? 'Successfully Linked' : 'Not Linked',
    );
  }

  void setStocksConnected(bool connected) {
    state = state.copyWith(
      stocksConnected: connected,
      stocksStatusMessage: connected ? '2 Demat Accounts Connected' : 'Not Linked',
    );
  }

  void setBanksConnected(bool connected) {
    state = state.copyWith(
      banksConnected: connected,
      banksStatusMessage: connected ? 'Successfully Linked' : 'Not Linked',
    );
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
    try {
      final res = await _api.dio.get('/api/v1/aa/accounts/discover');
      final envelopeData = res.data is Map<String, dynamic> ? res.data['data'] : null;
      final list = envelopeData is Map<String, dynamic> ? envelopeData['accounts'] as List<dynamic>? : null;
      final discoveredAccounts = (list ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((json) => BankAccountItem.fromJson(json))
          .map((b) => priorSelection.containsKey(b.id)
              ? b.copyWith(isSelected: priorSelection[b.id])
              : b)
          .toList();
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

  void toggleBankSelection(String id) {
    final updated = state.bankAccounts.map((b) {
      if (b.id == id && !b.isLinked) {
        return b.copyWith(isSelected: !b.isSelected);
      }
      return b;
    }).toList();
    state = state.copyWith(bankAccounts: updated);
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
        // The POST is what actually persists this account server-side —
        // marking it isLinked locally regardless of whether this call
        // succeeded used to make the onboarding screen show a bank as
        // connected (e.g. Axis, visible right here in "YOUR ACCOUNTS")
        // purely from optimistic local state, while every other screen that
        // re-fetches from the backend correctly showed nothing, because the
        // account was never actually saved. Only mark it linked on success.
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
          // Leave it selected (not linked) so the failure is visible and
          // the user can retry, instead of silently claiming success.
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
  }

  // Deliberately does NOT call fetchLiveBankAccounts() itself. The one
  // caller (banks_linking_screen's multi-select PROCEED) runs several of
  // these concurrently via Future.wait when the user picks more than one
  // bank — each call refreshing the list independently on its own success
  // raced every other call's refresh for the same shared state.bankAccounts
  // field. Whichever GET happened to resolve last silently won and
  // overwrote the others, so a freshly-added bank could vanish from
  // "YOUR ACCOUNTS" purely on network timing even though the backend had
  // it — the actual server data (confirmed via the RM portal) was correct
  // the whole time; only this client-side race made it look missing. The
  // fix is structural, not a guard flag: decouple "add one account" from
  // "refresh the list," and let the caller refresh exactly once after every
  // concurrent add has settled.
  Future<void> searchAndAddBank(String bankName, {String accountType = 'SAVINGS'}) async {
    _timer?.cancel();
    final shortId = '${(1000 + DateTime.now().millisecondsSinceEpoch % 9000)}';
    final dynamicBal = _calculateRealisticBalance(bankName);
    final ifsc = BankAccountItem._deriveIfsc(bankName, shortId);
    final branch = BankAccountItem._deriveBranch(bankName);

    state = state.copyWith(
      step: AssetConnectionStep.banksSearching,
      banksStatusMessage: 'Linking account with $bankName...',
    );

    try {
      final res = await _api.dio.post<dynamic>('/api/v1/aa/accounts', data: {
        'bank_name': bankName,
        'account_type': accountType,
        'balance': dynamicBal,
        'ifsc': ifsc,
        'branch': branch,
      });

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw StateError('unexpected status ${res.statusCode}');
      }
    } catch (e) {
      // This used to fall back to adding a fake local-only entry with
      // isLinked: false whenever the POST failed (offline, a transient
      // 401 during the token-refresh race, timeout, etc). That entry never
      // reached the backend, so LinkedBankAccountsScreen — which filters
      // strictly on isLinked — never showed it, and nothing ever retried
      // the add. The user would see the bank appear (unlinked) on this
      // screen's "YOUR ACCOUNTS" list, then find it silently gone from the
      // actual linked-accounts screen with no error and no way to retry.
      // Surfacing the real failure (status message + rethrow) instead of
      // faking success lets the caller show/retry it, same fix shape as
      // completeBankLinking().
      debugPrint('searchAndAddBank failed for $bankName: $e');
      state = state.copyWith(
        banksStatusMessage: 'Could not link $bankName. Please try again.',
      );
      rethrow;
    }
  }

  static double _calculateRealisticBalance(String bankName) {
    final lower = bankName.toLowerCase();
    final hash = bankName.codeUnits.fold(0, (sum, c) => sum + c);
    if (lower.contains('hdfc') || lower.contains('icici')) {
      return 150000.0 + (hash % 180000);
    } else if (lower.contains('sbi') || lower.contains('pnb') || lower.contains('baroda')) {
      return 75000.0 + (hash % 95000);
    } else if (lower.contains('kotak') || lower.contains('axis')) {
      return 120000.0 + (hash % 140000);
    }
    return 80000.0 + (hash % 60000);
  }

  void removeBankByName(String bankName) {
    _timer?.cancel();
    final updatedBanks = state.bankAccounts.where((b) => b.bankName != bankName).toList();
    state = state.copyWith(
      bankAccounts: updatedBanks,
    );
  }

  // PROCEED stages picked banks here — nothing is sent to the backend yet.
  // Kept additive (not a replace) so staging a second batch doesn't lose one
  // already pending from an earlier PROCEED.
  void stageBanksForApproval(List<String> bankNames) {
    final merged = {...state.pendingBankNames, ...bankNames}.toList();
    state = state.copyWith(pendingBankNames: merged);
  }

  // Un-checking a staged bank on the "YOUR ACCOUNTS" list before APPROVE AND
  // CONNECT — moves it back to being selectable in the picker.
  void unstageBankForApproval(String bankName) {
    state = state.copyWith(
      pendingBankNames: state.pendingBankNames.where((b) => b != bankName).toList(),
    );
  }

  void clearStagedBanks() {
    state = state.copyWith(pendingBankNames: const []);
  }

  // APPROVE AND CONNECT — the one action that actually links every checked
  // bank in "YOUR ACCOUNTS", from either source:
  //   1. Discovered-but-not-yet-linked accounts (state.bankAccounts where
  //      isSelected && !isLinked) — first-time onboarding's pre-checked
  //      AA-discovery accounts, which the user can also uncheck.
  //   2. Banks staged via PROCEED (state.pendingBankNames) from the
  //      "CONNECT MORE ACCOUNTS" picker.
  // Sequential, not concurrent — these lists are small (a handful of
  // accounts at most) and doing them one at a time means a single
  // fetchLiveBankAccounts() refresh at the end is trivially correct, with
  // no risk of the same overwrite race multiple concurrent refreshes had.
  Future<bool> approveAndConnectAll({required String accountType}) async {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.banksLinkingProgress,
      banksStatusMessage: 'Linking accounts...',
    );
    final discovered = state.bankAccounts.where((b) => b.isSelected && !b.isLinked).toList();
    final staged = List<String>.from(state.pendingBankNames);
    bool anyFailed = false;

    for (final b in discovered) {
      try {
        await _api.dio.post<dynamic>('/api/v1/aa/accounts', data: {
          'bank_name': b.bankName,
          'account_type': b.accountType,
          'balance': b.balance,
          'ifsc': b.ifsc,
          'branch': b.branch,
        });
      } catch (_) {
        anyFailed = true;
      }
    }
    for (final name in staged) {
      try {
        await searchAndAddBank(name, accountType: accountType);
      } catch (_) {
        // searchAndAddBank already sets its own banksStatusMessage on
        // failure; just note it so the combined summary below can mention
        // partial failure without clobbering that per-bank message.
        anyFailed = true;
      }
    }

    state = state.copyWith(pendingBankNames: const []);
    await fetchLiveBankAccounts();
    if (anyFailed) {
      state = state.copyWith(banksStatusMessage: 'Some accounts could not be linked — please retry.');
    }
    return !anyFailed;
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
