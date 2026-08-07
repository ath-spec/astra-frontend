import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/privacy_provider.dart';
import '../../../core/utils/privacy_formatter.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/asset_connection_provider.dart';
import '../widgets/bank_account_details_sheet.dart';

class BankAccountDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> bankAccount;

  const BankAccountDetailsScreen({
    super.key,
    required this.bankAccount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = bankAccount['account'] as BankAccountItem;
    final balance = bankAccount['balance'] as double;
    final logoPath = bankAccount['logo'] as String;
    final isLocked = ref.watch(privacyProvider);
    final authState = ref.watch(authProvider);
    
    String userName = 'INVESTOR';
    if (authState is AuthAuthenticated) {
      userName = authState.user.name.toUpperCase();
    }
    
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
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.chevron_left, size: 24, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bank Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  logoPath,
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, size: 32),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bank Name & Account Number
            Text(
              '${account.bankName.toUpperCase()} .. ${account.id}',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: 1.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Balance
            Text(
              isLocked 
                  ? PrivacyFormatter.cypher
                  : '₹${currencyFormatter.format(balance)}',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -1.5,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Update Time
            const Text(
              'TODAY, 5:33 AM',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Account Details Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.06),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BankAccountDetailsSheet(
                      account: account,
                      logoPath: logoPath,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(4), // As per emil styling/images, slightly sharper or standard
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ACCOUNT HOLDER',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userName.replaceAll(' ', '\n'), // break line if multiple words, or just show as is
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: const Color(0xFFE2E8F0),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'IFSC CODE',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  account.ifsc,
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      const Row(
                        children: [
                          Text(
                            'VIEW DETAILS',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB), // Primary Blue
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: Color(0xFF2563EB),
                          ),
                        ],
                      ),
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
