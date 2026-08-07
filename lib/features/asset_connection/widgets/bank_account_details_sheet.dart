import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/asset_connection_provider.dart';
import '../../auth/providers/auth_provider.dart';

class BankAccountDetailsSheet extends ConsumerWidget {
  final BankAccountItem account;
  final String logoPath;

  const BankAccountDetailsSheet({
    super.key,
    required this.account,
    required this.logoPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    String userName = 'INVESTOR';
    if (authState is AuthAuthenticated) {
      userName = authState.user.name.toUpperCase();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Account Details',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildDetailRow('Account Holder', userName),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          
          _buildDetailRow('Bank Name', account.bankName),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          
          _buildDetailRow('Account Number', account.accountNumber),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          
          _buildDetailRow('IFSC Code', account.ifsc),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          
          _buildDetailRow('Branch', account.branch),
          
          const SizedBox(height: 48),
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
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
