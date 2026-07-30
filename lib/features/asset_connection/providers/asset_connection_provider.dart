import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BankAccountItem {
  const BankAccountItem({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.isSelected,
    required this.isLinked,
  });

  final String id;
  final String bankName;
  final String accountNumber;
  final bool isSelected;
  final bool isLinked;

  BankAccountItem copyWith({
    String? id,
    String? bankName,
    String? accountNumber,
    bool? isSelected,
    bool? isLinked,
  }) {
    return BankAccountItem(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      isSelected: isSelected ?? this.isSelected,
      isLinked: isLinked ?? this.isLinked,
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

  int get connectedCount {
    int count = 0;
    if (mfConnected) count++;
    if (stocksConnected) count++;
    if (banksConnected || bankAccounts.any((b) => b.isLinked)) count++;
    return count;
  }

  bool get hasUnlinkedAccounts => bankAccounts.any((b) => !b.isLinked);

  bool get allAccountsLinked => bankAccounts.isNotEmpty && bankAccounts.every((b) => b.isLinked);

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
            step: AssetConnectionStep.linkingMutualFunds,
            mfConnected: false,
            stocksConnected: false,
            banksConnected: true,
            mfStatusMessage: 'Linking now...',
            stocksStatusMessage: 'Pending',
            banksStatusMessage: 'Successfully Linked',
            bankAccounts: [
              BankAccountItem(
                id: '3192',
                bankName: 'HDFC Bank',
                accountNumber: 'SAVINGS account - xxxx 3192',
                isSelected: true,
                isLinked: true,
              ),
              BankAccountItem(
                id: '8779',
                bankName: 'Axis Bank',
                accountNumber: 'SAVINGS account - xxxx 8779',
                isSelected: true,
                isLinked: true,
              ),
            ],
          ),
        );

  Timer? _timer;

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
          bankName: 'HDFC Bank',
          accountNumber: 'SAVINGS account - xxxx 3192',
          isSelected: true,
          isLinked: false,
        ),
        BankAccountItem(
          id: '8779',
          bankName: 'Axis Bank',
          accountNumber: 'SAVINGS account - xxxx 8779',
          isSelected: true,
          isLinked: false,
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
    final newBank = BankAccountItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bankName: bankName,
      accountNumber: 'SAVINGS account - xxxx ${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
      isSelected: true, // Auto-select the newly found bank
      isLinked: false,
    );
    final updatedBanks = List<BankAccountItem>.from(state.bankAccounts)..add(newBank);
    
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

  /// Called when returning to banks-linking after a partial link.
  /// Ensures no previously-unlinked accounts are pre-selected.
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
