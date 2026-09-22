import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';
import '../../asset_connection/screens/manage_bank_accounts_screen.dart' show getBankLogoAsset;
import '../../../core/network/api.dart';
import '../widgets/edit_number_overlay.dart';

/// Screen matching Image 3 for Account Aggregator Stocks status result.
/// Displays "No Demat found" (default) or "Demat accounts found" via demo toggle.
class AaStocksStatusScreen extends ConsumerStatefulWidget {
  const AaStocksStatusScreen({super.key});

  @override
  ConsumerState<AaStocksStatusScreen> createState() =>
      _AaStocksStatusScreenState();
}

class _AaStocksStatusScreenState extends ConsumerState<AaStocksStatusScreen>
    with SingleTickerProviderStateMixin {
  bool _hasDemat = true; // Happy case: demat is fetched
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isLoadingBanks = true;
  List<BankAccountItem> _detectedBanks = [];
  String? _selectedBankId;

  @override
  void initState() {
    super.initState();
    _fetchDetectedBanks();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetectedBanks() async {
    try {
      final res = await dioApiClient.dio.get('/api/v1/aa/accounts/detected');
      final envelopeData = res.data is Map<String, dynamic> ? res.data['data'] : null;
      final list = envelopeData is Map<String, dynamic> ? envelopeData['accounts'] as List<dynamic>? : null;
      final discoveredAccounts = (list ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((json) => BankAccountItem.fromJson(json))
          .toList();
          
      if (mounted) {
        setState(() {
          _detectedBanks = discoveredAccounts;
          if (_detectedBanks.isNotEmpty) {
            _selectedBankId = _detectedBanks.first.id;
          }
          _isLoadingBanks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBanks = false);
      }
    }
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB)),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authProvider.notifier).pendingPhone;
    final displayPhone = phone.isEmpty ? '6291328703' : phone;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF111827),
                      size: 20,
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (context.canPop()) context.pop();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                  child: TextButton.icon(
                    onPressed: () => setState(() => _hasDemat = !_hasDemat),
                    icon: Icon(
                      _hasDemat ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                      color: const Color(0xFF031E6B),
                      size: 24,
                    ),
                    label: Text(
                      _hasDemat ? 'Demo: Demat Found' : 'Demo: No Demat Found',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        color: Color(0xFF031E6B),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Icon Badge matching Image 3
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _hasDemat
                                    ? const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.1)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _hasDemat
                                      ? const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.3)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _hasDemat
                                    ? Icons.account_balance_wallet_rounded
                                    : Icons.domain_disabled_rounded,
                                color: _hasDemat
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF6B7280),
                                size: 32,
                              ),
                            ),
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: _hasDemat
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF6B7280),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _hasDemat
                                      ? Icons.check_rounded
                                      : Icons.info_outline_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _hasDemat ? 'Demat connected' : 'No Demat found',
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            height: 1.15,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _hasDemat
                              ? 'We found active Demat accounts linked to your mobile number +91 $displayPhone.'
                              : "We couldn't find any Demat accounts associated with your mobile number +91 $displayPhone.",
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildDashedDivider(),
                        const SizedBox(height: 32),
                        if (_hasDemat) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.show_chart_rounded,
                                    color: Color(0xFF10B981),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CDSL / NSDL Demat Account',
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_isLoadingBanks)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(color: Color(0xFF031E6B)),
                              ),
                            )
                          else if (_detectedBanks.isNotEmpty) ...[
                            const Text(
                              'Select your primary bank account:',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._detectedBanks.map((bank) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedBankId = bank.id;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: _selectedBankId == bank.id ? const Color(0xFFF0FDF4) : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _selectedBankId == bank.id
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFE5E7EB),
                                          width: _selectedBankId == bank.id ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: const Color(0xFFE5E7EB)),
                                              image: DecorationImage(
                                                image: AssetImage(getBankLogoAsset(bank.bankName) ?? 'lib/core/images/icici_logo.webp'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bank.bankName,
                                                  style: const TextStyle(
                                                    fontFamily: 'DMSans',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF111827),
                                                  ),
                                                ),
                                                Text(
                                                  '•••• ${bank.shortId}',
                                                  style: const TextStyle(
                                                    fontFamily: 'DMSans',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_selectedBankId == bank.id)
                                            const Icon(
                                              Icons.radio_button_checked,
                                              color: Color(0xFF10B981),
                                              size: 24,
                                            )
                                          else
                                            const Icon(
                                              Icons.radio_button_unchecked,
                                              color: Color(0xFFD1D5DB),
                                              size: 24,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: Color(0xFF031E6B),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Tip: You can link your broker or mutual funds via the home screen.',
                                    style: const TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      color: Color(0xFF4B5563),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      if (_hasDemat)
                        GestureDetector(
                          onTapDown: (_) => _animationController.forward(),
                          onTapUp: (_) => _animationController.reverse(),
                          onTapCancel: () => _animationController.reverse(),
                          onTap: () {
                            if (_selectedBankId != null) {
                              ref.read(assetConnectionProvider.notifier).setPendingBaseBankId(_selectedBankId!);
                            }
                            context.push('/banks-linking');
                          },
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFF5BA1F7),
                                    Color(0xFF031E6B),
                                    Color(0xFF241714),
                                  ],
                                  stops: [0.0, 0.25, 0.7, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    'CONTINUE TO BANKS',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Positioned(
                                    right: 20,
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else ...[
                        GestureDetector(
                          onTapDown: (_) => _animationController.forward(),
                          onTapUp: (_) => _animationController.reverse(),
                          onTapCancel: () => _animationController.reverse(),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => EditNumberOverlay(
                                currentNumber: displayPhone,
                                onConfirm: (newNumber) {
                                  ref
                                      .read(authProvider.notifier)
                                      .setPendingPhone(newNumber);
                                  context.push('/aa-stocks-otp');
                                },
                              ),
                            );
                          },
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFF5BA1F7),
                                    Color(0xFF031E6B),
                                    Color(0xFF241714),
                                  ],
                                  stops: [0.0, 0.25, 0.7, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    'TRY WITH DIFFERENT NUMBER',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Positioned(
                                    right: 20,
                                    child: Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.push('/banks-linking'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6B7280),
                          ),
                          child: const Text(
                            'CONTINUE WITHOUT DEMAT',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
