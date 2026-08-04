import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/asset_connection_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ManageBankAccountsScreen extends ConsumerWidget {
  const ManageBankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetConnectionProvider);
    final linkedAccounts = state.bankAccounts.where((b) => b.isLinked).toList();

    final authState = ref.watch(authProvider);
    String userName = 'Investor';
    String connectionNumber = 'Not Available';

    if (authState is AuthAuthenticated) {
      userName = authState.user.name.toUpperCase();
      if (authState.user.email.contains('@astra.dev')) {
        connectionNumber = authState.user.email.replaceAll('@astra.dev', '');
      } else if (authState.user.email == 'guest@example.com') {
        connectionNumber = 'GUEST CONNECTION';
      } else {
        connectionNumber = authState.user.email;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.chevron_left, size: 28, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'manage accounts',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'take control of your AA accounts on Kuvera',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Subheader
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'LINKED ACCOUNTS (${linkedAccounts.length})',
                style: const TextStyle(
                  fontFamily: 'DMMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // List of Linked Accounts
            Expanded(
              child: linkedAccounts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.link_off_rounded, size: 48, color: const Color(0xFFCBD5E1)),
                          const SizedBox(height: 16),
                          const Text(
                            'No accounts linked',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: linkedAccounts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildAccountCard(context, ref, linkedAccounts[index], userName, connectionNumber);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, WidgetRef ref, BankAccountItem account, String userName, String connectionNumber) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildBankLogoWidget(account.bankName, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '${account.bankName} | •• ${account.accountNumber.substring(account.accountNumber.length - 4)}',
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                // Active Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5), // Emerald 100
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF34D399)), // Emerald 400
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 12, color: Color(0xFF059669)), // Emerald 600
                      const SizedBox(width: 4),
                      const Text(
                        'Active',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ACCOUNT HOLDER', userName),
                const Divider(color: Color(0xFFF1F5F9), height: 32),
                _buildDetailRow('BANK ACCOUNT NUMBER', 'XXXXXXXXX${account.accountNumber.substring(account.accountNumber.length - 4)}'),
                const Divider(color: Color(0xFFF1F5F9), height: 32),
                _buildDetailRow('CONNECTION NUMBER', connectionNumber),
                const Divider(color: Color(0xFFF1F5F9), height: 32),
                _buildDetailRow('TYPE', 'Bank Account'),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFF0F172A)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.info_outline, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'View details',
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRevokeDialog(context, ref, account.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.link_off, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Revoke',
                          style: TextStyle(fontFamily: 'DMSans', fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMMono',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  String? _getBankLogoAsset(String bankName) {
    final name = bankName.toLowerCase();
    
    if (name.contains('hdfc')) return 'lib/core/images/hdfc_logo.webp';
    else if (name.contains('icici')) return 'lib/core/images/icici.webp';
    else if (name.contains('state bank') || name.contains('sbi')) return 'lib/core/images/sbi_logo.webp';
    else if (name.contains('axis')) return 'lib/core/images/axis_logo.webp';
    else if (name.contains('kotak')) return 'lib/core/images/kotak.webp';
    else if (name.contains('punjab national') || name.contains('pnb')) return 'lib/core/images/pnb.webp';
    else if (name.contains('bank of baroda') || name.contains('bob')) return 'lib/core/images/bankofbaroda_logo.webp';
    else if (name.contains('canara')) return 'lib/core/images/canara_logo.webp';
    else if (name.contains('union')) return 'lib/core/images/uniobank_logo.webp';
    else if (name.contains('indusind')) return 'lib/core/images/indusind_logo.webp';
    else if (name.contains('yes')) return 'lib/core/images/yesbank_logo.webp';
    else if (name.contains('uco')) return 'lib/core/images/uco_bank_logo.webp';
    else if (name.contains('punjab & sind') || name.contains('punjab and sind')) return 'lib/core/images/punjab_sindh_bank_logo.webp';
    else if (name.contains('indian overseas bank')) return 'lib/core/images/indian_overseas_bank_logo.webp';
    else if (name.contains('indian bank')) return 'lib/core/images/indian_bank_logo.webp';
    else if (name.contains('maharashtra')) return 'lib/core/images/bank_of_maharashtra_logo.webp';
    else if (name.contains('bank of india') || name.contains('boi')) return 'lib/core/images/bankofindia_logo.webp';
    
    return null;
  }

  Widget _buildFallbackLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.account_balance,
          size: size * 0.6,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildBankLogoWidget(String bankName, {double size = 30}) {
    final assetPath = _getBankLogoAsset(bankName);
    
    if (assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          color: Colors.white,
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackLogo(size);
            },
          ),
        ),
      );
    }
    
    return _buildFallbackLogo(size);
  }

  void _showRevokeDialog(BuildContext context, WidgetRef ref, String accountId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Revoke Connection?',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        content: const Text(
          'Are you sure you want to unlink and remove this bank account?',
          style: TextStyle(
            fontFamily: 'DMSans',
            color: Color(0xFF475569),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(assetConnectionProvider.notifier).revokeBankConnection(accountId);
              Navigator.pop(ctx); // Close dialog only, stay on screen
            },
            child: const Text(
              'Revoke',
              style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}
