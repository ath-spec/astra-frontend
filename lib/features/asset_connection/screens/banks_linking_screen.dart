import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/arch_background.dart';
import '../providers/asset_connection_provider.dart';

/// Screen 1 of Banks Flow: Shows Bank Accounts (Image 1) in clean light mode.
/// Allows checking/unchecking accounts, viewing consent info bottom sheet (Image 2),
/// and proceeding to account fetching.
class BanksLinkingScreen extends ConsumerStatefulWidget {
  const BanksLinkingScreen({super.key});

  @override
  ConsumerState<BanksLinkingScreen> createState() => _BanksLinkingScreenState();
}

class _BanksLinkingScreenState extends ConsumerState<BanksLinkingScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure banks are shown in state if not already populated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(assetConnectionProvider);
      if (state.bankAccounts.isEmpty) {
        ref.read(assetConnectionProvider.notifier).showFoundBanks();
      }
    });
  }

  void _showConsentBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ConsentBottomSheet(
        onUnderstood: () {
          Navigator.pop(sheetContext);
          ref.read(assetConnectionProvider.notifier).startBankLinking();
          context.push('/banks-searching');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetConnectionProvider);
    final notifier = ref.read(assetConnectionProvider.notifier);
    // GoRouter extra: true means we returned after a partial link
    final returnMode = GoRouterState.of(context).extra == true;
    // In return mode: CTA active when any NEW (unlinked) account is selected
    final hasSelected = state.bankAccounts.any((b) => b.isSelected && !b.isLinked);
    final ctaLabel = returnMode ? 'LINK MORE ACCOUNTS' : 'APPROVE AND PROCEED';
    final ctaActive = returnMode ? hasSelected : state.bankAccounts.any((b) => b.isSelected);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Subtle 3D Architectural Dome Background Graphic
          const ArchBackground(height: 380),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),

                        // Title
                        const Text(
                          'Get latest balance and transactions',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: Color(0xFF0F172A),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.0,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle with link
                        Wrap(
                          children: [
                            const Text(
                              'Securely track on Kuvera (DASPL). Revoke this anytime. ',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                color: Color(0xFF64748B),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showConsentBottomSheet(context, ref),
                              child: const Text(
                                'Know more',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: Color(0xFF0F172A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem('UPDATED', 'Daily'),
                            _buildStatItem('VALID FOR', '1 year'),
                            _buildStatItem('ACCESS', '1 Month'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Dotted Separator Line
                        CustomPaint(
                          size: const Size(double.infinity, 1),
                          painter: _DottedLinePainter(),
                        ),
                        const SizedBox(height: 20),

                        // Bank Accounts List
                        ...state.bankAccounts.map((bank) {
                          return _buildBankCard(
                            bank: bank,
                            onTap: bank.isLinked
                                ? null // already linked, not interactive
                                : () => notifier.toggleBankSelection(bank.id),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Connect More Accounts Label
                        const Text(
                          'CONNECT MORE ACCOUNTS',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Connect More Accounts Placeholder Box
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // CTA Button
                        GestureDetector(
                          onTap: ctaActive
                              ? () => _showConsentBottomSheet(context, ref)
                              : null,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: ctaActive
                                    ? const [
                                        Color(0xFFFFFFFF),
                                        Color(0xFF5BA1F7),
                                        Color(0xFF031E6B),
                                        Color(0xFF241714),
                                      ]
                                    : const [
                                        Color(0xFFF3F4F6),
                                        Color(0xFFD1D5DB),
                                        Color(0xFF9CA3AF),
                                        Color(0xFF6B7280),
                                      ],
                                stops: const [0.0, 0.25, 0.7, 1.0],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  ctaLabel,
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const Positioned(
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
                        const SizedBox(height: 16),

                        // Secondary action
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              if (returnMode) {
                                // User explicitly done — mark state complete and go home
                                notifier.finishAssetConnection();
                                context.go('/');
                              } else {
                                notifier.skipBanks();
                                context.go('/');
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                returnMode
                                    ? "Don't want to connect more"
                                    : 'Deny',
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'DMSans',
            color: Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBankCard({
    required BankAccountItem bank,
    required VoidCallback? onTap,
  }) {
    final accountLast4 = bank.accountNumber.length >= 4
        ? bank.accountNumber.substring(bank.accountNumber.length - 4)
        : bank.accountNumber;
    final isLinked = bank.isLinked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isLinked
              ? const Color(0xFFF0FDF4) // light green tint for linked
              : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLinked
                ? const Color(0xFF10B981).withValues(alpha: 0.4)
                : bank.isSelected
                    ? const Color(0xFF0F172A).withValues(alpha: 0.2)
                    : const Color(0xFFE2E8F0),
            width: (isLinked || bank.isSelected) ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bank Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Icon(
                  bank.bankName.toUpperCase().contains('ICICI')
                      ? Icons.account_balance_wallet_rounded
                      : Icons.account_balance_rounded,
                  color: bank.bankName.toUpperCase().contains('ICICI')
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF031E6B),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name & Account Number
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank.bankName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '.. $accountLast4',
                    style: const TextStyle(
                      fontFamily: 'DMMono',
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            if (isLinked) ...
              // Linked badge
              [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'LINKED',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ]
            else ...
              // DEPOSIT badge + checkbox
              [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Text(
                    'DEPOSIT',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: bank.isSelected
                        ? const Color(0xFF0F172A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: bank.isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: bank.isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 15,
                        )
                      : null,
                ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'powered by RBI-regulated account aggregator ',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
                Text(
                  'FINVU',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF10B981),
                  size: 14,
                ),
                const SizedBox(width: 6),
                const Text(
                  'trusted by 3 crore citizens',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dotted horizontal line separator
class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0;

    double startX = 0;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Consent Info Bottom Sheet (Image 2)
class _ConsentBottomSheet extends StatelessWidget {
  final VoidCallback onUnderstood;

  const _ConsentBottomSheet({required this.onUnderstood});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'DETAILS OF YOUR APPROVAL',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 16),

              // Details List
              _buildDetailRow(
                label: 'approval requested on',
                value: '6 June 2026',
              ),
              _buildDetailRow(
                label: 'purpose',
                value:
                    'to generate insights based on your overall finances and provide incidental recommendations, if any',
              ),
              _buildDetailRow(
                label: 'balance and transactions updated',
                value: 'upto 45 times per month',
              ),
              _buildDetailRow(
                label: 'approval valid for',
                value: '6 June 2026 - 6 June 2027',
              ),
              _buildDetailRow(
                label: 'account details',
                value: 'profile, summary, transactions',
              ),
              _buildDetailRow(
                label: 'access period to find insights for you',
                value: '1 month',
              ),
              _buildDetailRow(
                label: 'approval expiry',
                value: '6 June 2027',
              ),
              _buildDetailRow(
                label: 'account types',
                value: 'deposit',
                isLast: true,
              ),

              const SizedBox(height: 28),

              // CTA Button (Understood)
              GestureDetector(
                onTap: onUnderstood,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
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
                        'UNDERSTOOD',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DMSans',
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'DMSans',
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
