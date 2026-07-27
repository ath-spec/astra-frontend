import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/asset_connection_provider.dart';

class BanksLinkingScreen extends ConsumerWidget {
  const BanksLinkingScreen({super.key});

  void _showConsentBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131826),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _ConsentBottomSheet(
        onConfirm: () {
          Navigator.pop(sheetContext);
          _showOtpBottomSheet(context, ref);
        },
      ),
    );
  }

  void _showOtpBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: const Color(0xFF131826),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => const _BankOtpBottomSheet(),
    ).then((verified) {
      if (verified == true && context.mounted) {
        ref.read(assetConnectionProvider.notifier).startBankLinking();
        context.pushReplacement('/banks-linking-progress');
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetConnectionProvider);
    final notifier = ref.read(assetConnectionProvider.notifier);
    final hasAnyLinked = state.bankAccounts.any((b) => b.isLinked);
    final selectedCount = state.bankAccounts.where((b) => b.isSelected && !b.isLinked).length;
    final isProceeding = hasAnyLinked && selectedCount == 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '3 of 3',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          notifier.skipBanks();
                          context.go('/profiling-intro');
                        },
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF0D9488),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Badge
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF132328),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.account_balance, size: 14, color: Color(0xFF0D9488)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Banks',
                                    style: TextStyle(
                                      color: Color(0xFF0D9488),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title & Subtitle
                          const Text(
                            'We found these bank accounts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Link accounts which you want to track',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Shield Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131826),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF1E2433)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasAnyLinked ? Icons.verified_user : Icons.security,
                                  size: 16,
                                  color: const Color(0xFF0D9488),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  hasAnyLinked ? 'Trusted by 5L+ users' : 'Data is 100% secure',
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bank Card
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF131826),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E2433)),
                        ),
                        child: Column(
                          children: [
                            // Card Header
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E2433),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.account_balance, color: Color(0xFF0D9488), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Axis Bank',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (hasAnyLinked)
                                    const Text(
                                      'Link',
                                      style: TextStyle(
                                        color: Color(0xFF0D9488),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFF1E2433)),

                            // Account Rows
                            ...state.bankAccounts.map((acc) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        acc.accountNumber,
                                        style: const TextStyle(
                                          color: Color(0xFFE2E8F0),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (acc.isLinked)
                                      const Flexible(
                                        child: Text(
                                          'You are already tracking this account',
                                          style: TextStyle(
                                            color: Color(0xFF0D9488),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    else
                                      GestureDetector(
                                        onTap: () => notifier.toggleBankSelection(acc.id),
                                        behavior: HitTestBehavior.opaque,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 12.0),
                                          child: Icon(
                                            acc.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                            color: acc.isSelected ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Didn't find your account
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Didn't find your account?",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Security Footer
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Icon(Icons.shield, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  const Text(
                    'Your data is 100% safe',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '• Powered by FINVU',
                    style: TextStyle(
                      color: const Color(0xFF64748B).withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CTA Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (!hasAnyLinked && selectedCount == 0)
                      ? null
                      : () {
                          if (isProceeding) {
                            notifier.finishAssetConnection();
                            context.go('/profiling-intro');
                          } else {
                            _showConsentBottomSheet(context, ref);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (!hasAnyLinked && selectedCount == 0)
                        ? const Color(0xFF1E2433)
                        : Colors.white,
                    foregroundColor: (!hasAnyLinked && selectedCount == 0)
                        ? const Color(0xFF64748B)
                        : const Color(0xFF0B0F19),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isProceeding ? 'Complete and proceed ->' : 'Link selected accounts',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip link
              Center(
                child: TextButton(
                  onPressed: () {
                    notifier.skipBanks();
                    context.go('/profiling-intro');
                  },
                  child: const Text(
                    'Skip linking banks',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )));
  }
}

class _ConsentBottomSheet extends StatelessWidget {
  const _ConsentBottomSheet({required this.onConfirm});

  final VoidCallback onConfirm;

  Widget _buildConsentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Providing consent to DEZERV',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2433),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildConsentRow('Consent Purpose', 'Wealth management service'),
                  const Divider(height: 1, color: Color(0xFF2D3748)),
                  _buildConsentRow('Account Types', 'Deposit'),
                  const Divider(height: 1, color: Color(0xFF2D3748)),
                  _buildConsentRow('Shared from', '26 Jul 2025 -> 25 Jul 2027'),
                  const Divider(height: 1, color: Color(0xFF2D3748)),
                  _buildConsentRow('Consent valid till', '25 Jul 2027'),
                  const Divider(height: 1, color: Color(0xFF2D3748)),
                  _buildConsentRow('Data Fetching', '31 times a month'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0B0F19),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Confirm permissions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankOtpBottomSheet extends ConsumerStatefulWidget {
  const _BankOtpBottomSheet();

  @override
  ConsumerState<_BankOtpBottomSheet> createState() => _BankOtpBottomSheetState();
}

class _BankOtpBottomSheetState extends ConsumerState<_BankOtpBottomSheet> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _resendTimer;
  int _secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetConnectionProvider);
    final selectedAccs = state.bankAccounts.where((b) => b.isSelected && !b.isLinked).toList();
    final accSubtitle = selectedAccs.isNotEmpty ? selectedAccs.first.accountNumber : 'SAVINGS account';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bank 1 of 1',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Link your bank account',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Bank card preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2433),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0F19),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance, color: Color(0xFF0D9488), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Axis Bank',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            accSubtitle,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // OTP Input field
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2),
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Enter OTP sent to +91-8826473535',
                    hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14, letterSpacing: 0),
                    filled: true,
                    fillColor: const Color(0xFF1E2433),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2D3748)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2D3748)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF0D9488)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons row
                Row(
                  children: [
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _secondsLeft > 0
                            ? null
                            : () {
                                setState(() => _secondsLeft = 30);
                                _startTimer();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2433),
                          disabledBackgroundColor: const Color(0xFF1E2433),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: const Color(0xFF64748B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _secondsLeft > 0 ? 'Resend ($_secondsLeft)' : 'Resend',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _otpController.text.length != 6
                              ? null
                              : () {
                                  Navigator.pop(context, true);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _otpController.text.length == 6
                                ? Colors.white
                                : const Color(0xFF1E2433),
                            foregroundColor: _otpController.text.length == 6
                                ? const Color(0xFF0B0F19)
                                : const Color(0xFF64748B),
                            disabledBackgroundColor: const Color(0xFF1E2433),
                            disabledForegroundColor: const Color(0xFF64748B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Verify OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Skip link
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Skip linking Axis Bank accounts',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
