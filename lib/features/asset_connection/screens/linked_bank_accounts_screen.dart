import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/asset_connection_provider.dart';
import '../../../core/providers/privacy_provider.dart';
import '../../../core/utils/privacy_formatter.dart';

class LinkedBankAccountsScreen extends ConsumerWidget {
  const LinkedBankAccountsScreen({super.key});

  String _getBankLogo(String bankName) {
    final lower = bankName.toLowerCase();
    if (lower.contains('hdfc')) return 'lib/core/images/hdfc_logo.webp';
    if (lower.contains('axis')) return 'lib/core/images/axis_logo.webp';
    if (lower.contains('sbi') || lower.contains('state bank')) return 'lib/core/images/sbi_logo.webp';
    if (lower.contains('icici')) return 'lib/core/images/icici.webp';
    if (lower.contains('kotak')) return 'lib/core/images/kotak.webp';
    if (lower.contains('pnb')) return 'lib/core/images/pnb.webp';
    return 'lib/core/images/hdfc_logo.webp';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetConnectionProvider);
    final isLocked = ref.watch(privacyProvider);
    final linkedAccounts = state.bankAccounts.where((b) => b.isLinked).toList();
    
    // Calculate total balance from linked accounts
    final double totalBalance = linkedAccounts.fold(0.0, (sum, item) => sum + item.balance);
    final currencyFormatter = NumberFormat('#,##,###');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.06, 
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.chevron_left, size: 24, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push('/banks-searching');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_circle, size: 12, color: Color(0xFF475569)),
                              SizedBox(width: 4),
                              Text(
                                'ADD ACCOUNTS',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          ref.read(privacyProvider.notifier).state = !isLocked;
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Icon(
                            isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded, 
                            size: 18, 
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Cumulative Balance
            const SizedBox(height: 32),
            const Text(
              'BANK BALANCE',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isLocked 
                  ? PrivacyFormatter.cypher
                  : '₹${currencyFormatter.format(totalBalance)}',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -1.5,
              ),
            ),
            
            const SizedBox(height: 64),
            
            // Accounts Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accounts',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: linkedAccounts.isEmpty ? 1 : linkedAccounts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (linkedAccounts.isEmpty) {
                            return const Center(
                              child: Text(
                                'No accounts linked.',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            );
                          }
                          
                          final account = linkedAccounts[index];
                          final double accountBalance = account.balance;
                          final logoPath = _getBankLogo(account.bankName);
                          
                          return GestureDetector(
                            onTap: () {
                              context.push(
                                '/bank-account-details', 
                                extra: {
                                  'account': account,
                                  'balance': accountBalance,
                                  'logo': logoPath,
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFF1F5F9)),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        logoPath,
                                        width: 24,
                                        height: 24,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, size: 20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.bankName,
                                          style: const TextStyle(
                                            fontFamily: 'DMSans',
                                            fontSize:12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF94A3B8),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF94A3B8),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              account.id,
                                              style: const TextStyle(
                                                fontFamily: 'DMSans',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${currencyFormatter.format(accountBalance)}',
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.refresh, size: 10, color: Color(0xFF94A3B8)),
                                          SizedBox(width: 4),
                                          Text(
                                            'TODAY 5:33 AM',
                                            style: TextStyle(
                                              fontFamily: 'DMSans',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
