import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api.dart';

class BankAccountItem {
  const BankAccountItem({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.isSelected,
    required this.isLinked,
    this.ifsc = 'HDFC0000173',
    this.branch = 'MUMBAI - NARIMAN POINT',
    this.balance = 0.0,
  });

  final String id;
  final String bankName;
  final String accountNumber;
  final bool isSelected;
  final bool isLinked;
  final String ifsc;
  final String branch;
  final double balance;

  BankAccountItem copyWith({
    String? id,
    String? bankName,
    String? accountNumber,
    bool? isSelected,
    bool? isLinked,
    String? ifsc,
    String? branch,
    double? balance,
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
  });

  final AssetConnectionStep step;
  final bool mfConnected;
  final bool stocksConnected;
  final bool banksConnected;
  final String mfStatusMessage;
  final String stocksStatusMessage;
  final String banksStatusMessage;
  final List<BankAccountItem> bankAccounts;

  AssetConnectionState copyWith({
    AssetConnectionStep? step,
    bool? mfConnected,
    bool? stocksConnected,
    bool? banksConnected,
    String? mfStatusMessage,
    String? stocksStatusMessage,
    String? banksStatusMessage,
    List<BankAccountItem>? bankAccounts,
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
    );
  }
}

class AssetConnectionNotifier extends StateNotifier<AssetConnectionState> {
  AssetConnectionNotifier()
      : super(
          const AssetConnectionState(
            step: AssetConnectionStep.linkingBanks,
            mfConnected: true,
            stocksConnected: true,
            banksConnected: true,
            mfStatusMessage: 'Successfully Linked',
            stocksStatusMessage: '2 Demat Accounts Connected',
            banksStatusMessage: 'Successfully Linked',
            bankAccounts: [
              BankAccountItem(
                id: '3192',
                bankName: 'ICICI Bank',
                accountNumber: 'SAVINGS account - xxxx 3192',
                isSelected: true,
                isLinked: false,
                ifsc: 'ICIC0000173',
                branch: 'MUMBAI - KHAR WEST',
                balance: 345000.0,
              ),
              BankAccountItem(
                id: '8779',
                bankName: 'HDFC Bank',
                accountNumber: 'SAVINGS account - xxxx 8779',
                isSelected: true,
                isLinked: false,
                ifsc: 'HDFC0000877',
                branch: 'MUMBAI - NARIMAN POINT',
                balance: 185000.0,
              ),
            ],
          ),
        ) {
    fetchLiveBankAccounts();
  }

  Timer? _timer;
  final _api = DioApiClient();

  /// Fetches live bank accounts from backend PostgreSQL (/api/v1/aa/accounts)
  Future<void> fetchLiveBankAccounts() async {
    try {
      final res = await _api.dio.get('/api/v1/aa/accounts');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final list = res.data['accounts'] as List<dynamic>?;
        if (list != null && list.isNotEmpty) {
          final items = list.map((json) {
            final map = json as Map<String, dynamic>;
            final bName = map['bank_name']?.toString() ?? 'Bank Account';
            final idStr = map['id']?.toString() ?? '0000';
            final shortId = idStr.length > 4 ? idStr.substring(idStr.length - 4) : idStr;
            final bal = (map['balance'] as num?)?.toDouble() ?? 0.0;
            final aType = map['account_type']?.toString() ?? 'SAVINGS';

            return BankAccountItem(
              id: shortId,
              bankName: bName,
              accountNumber: '$aType account - xxxx $shortId',
              isSelected: true,
              isLinked: false,
              balance: bal,
              ifsc: 'HDFC000${shortId.padLeft(4, '0')}',
              branch: 'MUMBAI - MAIN',
            );
          }).toList();

          state = state.copyWith(
            bankAccounts: items,
            banksConnected: items.isNotEmpty,
            banksStatusMessage: items.isNotEmpty ? 'Successfully Linked' : 'No accounts linked',
          );
        }
      }
    } catch (_) {
      // Keep existing accounts if offline or not logged in yet
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
      bankAccounts: [
        BankAccountItem(
          id: '3192',
          bankName: 'ICICI Bank Wealth',
          accountNumber: 'SAVINGS account - xxxx 3192',
          isSelected: true,
          isLinked: false,
          balance: 345000.0,
        ),
        BankAccountItem(
          id: '8779',
          bankName: 'Zerodha Pro',
          accountNumber: 'TRADING account - xxxx 8779',
          isSelected: true,
          isLinked: false,
          balance: 185000.0,
        ),
      ],
    );
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

  void showFoundBanks() {
    _timer?.cancel();
    state = state.copyWith(
      step: AssetConnectionStep.banksLinking,
      banksStatusMessage: 'Accounts found',
    );
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

  void completeBankLinking() {
    _timer?.cancel();
    final updated = state.bankAccounts.map((b) {
      if (b.isSelected) {
        // Sync with backend
        _api.dio.post('/api/v1/aa/accounts', data: {
          'bank_name': b.bankName,
          'account_type': 'SAVINGS',
          'balance': b.balance,
        }).catchError((dynamic _) => Future<dynamic>.value(null));

        return b.copyWith(isLinked: true, isSelected: false);
      }
      return b;
    }).toList();
    final hasAnyLinked = updated.any((b) => b.isLinked);
    state = state.copyWith(
      step: AssetConnectionStep.banksLinking,
      bankAccounts: updated,
      banksConnected: hasAnyLinked,
      banksStatusMessage: hasAnyLinked ? 'Successfully Linked' : 'Accounts found',
    );
  }

  void searchAndAddBank(String bankName) {
    _timer?.cancel();
    final genBal = 25000.0 + (DateTime.now().millisecondsSinceEpoch % 45000);
    final newBank = BankAccountItem(
      id: DateTime.now().millisecondsSinceEpoch.toString().substring(9),
      bankName: bankName,
      accountNumber: 'SAVINGS account - xxxx ${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
      isSelected: true,
      isLinked: false,
      balance: genBal,
      ifsc: '${bankName.replaceAll(' ', '').toUpperCase().padRight(4, 'X').substring(0, 4)}0001234',
      branch: 'MUMBAI - MAIN',
    );
    final updatedBanks = List<BankAccountItem>.from(state.bankAccounts)..add(newBank);
    
    // Also post to backend if user is logged in
    _api.dio.post('/api/v1/aa/accounts', data: {
      'bank_name': bankName,
      'account_type': 'SAVINGS',
      'balance': genBal,
    }).catchError((dynamic _) => Future<dynamic>.value(null));

    state = state.copyWith(
      step: AssetConnectionStep.banksSearching,
      banksStatusMessage: 'Fetching accounts...',
      bankAccounts: updatedBanks,
    );
  }

  void removeBankByName(String bankName) {
    _timer?.cancel();
    final updatedBanks = state.bankAccounts.where((b) => b.bankName != bankName).toList();
    state = state.copyWith(
      bankAccounts: updatedBanks,
    );
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

  void revokeBankConnection(String id) {
    _timer?.cancel();
    final updated = state.bankAccounts.map((b) {
      if (b.id == id) {
        return b.copyWith(isLinked: false, isSelected: false);
      }
      return b;
    }).toList();
    final hasAnyLinked = updated.any((b) => b.isLinked);
    state = state.copyWith(
      bankAccounts: updated,
      banksConnected: hasAnyLinked,
      banksStatusMessage: hasAnyLinked ? 'Successfully Linked' : 'Accounts found',
    );
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
  return AssetConnectionNotifier();
});
