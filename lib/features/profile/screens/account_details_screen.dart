import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class AccountDetailsScreen extends ConsumerWidget {
  const AccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = MediaQuery.of(context).size.width / 375.0;

    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    String name = 'Not provided';
    String mobile = 'Not provided';
    String pan = authNotifier.pendingPan.isNotEmpty ? authNotifier.pendingPan : 'Not provided';

    if (authState is AuthAuthenticated) {
      name = authState.user.name;
      if (authState.user.email.contains('@')) {
        mobile = authState.user.email.split('@').first;
      }
    }

    if (name == 'Not provided' || name.isEmpty) name = authNotifier.pendingName;
    if (mobile == 'Not provided' || mobile.isEmpty) mobile = authNotifier.pendingPhone;
    if (name.isEmpty) name = 'Investor';
    if (mobile.isEmpty) mobile = 'Not provided';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(left: 24 * scale, top: 16 * scale, right: 24 * scale, bottom: 24 * scale),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44 * scale,
                      height: 44 * scale,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF0F172A),
                        size: 20 * scale,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 44 * scale), // balance the back button
                        child: Text(
                          'ACCOUNT DETAILS',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              height: 1,
              color: const Color(0xFFF1F5F9),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 32 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mutual fund account',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 32 * scale),
                    
                    _buildDetailRow(
                      scale: scale,
                      label: 'KYC status',
                      value: 'Not Verified',
                      hasCopy: false,
                    ),
                    _buildDetailRow(
                      scale: scale,
                      label: 'Name',
                      value: name,
                      hasCopy: false,
                    ),
                    _buildDetailRow(
                      scale: scale,
                      label: 'PAN',
                      value: pan,
                      hasCopy: true,
                    ),
                    _buildDetailRow(
                      scale: scale,
                      label: 'Unique client code',
                      value: '0KV001IZ40',
                      hasCopy: true,
                    ),
                    _buildDetailRow(
                      scale: scale,
                      label: 'Mobile',
                      value: mobile,
                      hasCopy: false,
                    ),
                    _buildDetailRow(
                      scale: scale,
                      label: 'Communication mobile',
                      value: mobile,
                      hasCopy: false,
                      isLast: true,
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

  Widget _buildDetailRow({
    required double scale,
    required String label,
    required String value,
    required bool hasCopy,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10 * scale,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 8 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (hasCopy)
              Icon(
                Icons.copy_rounded,
                size: 12 * scale,
                color: const Color(0xFF94A3B8),
              ),
          ],
        ),
        SizedBox(height: 16 * scale),
        if (!isLast) ...[
          const _DashedDivider(),
          SizedBox(height: 16 * scale),
        ],
      ],
    );
  }
}

/// A simple dashed divider.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
              ),
            );
          }),
        );
      },
    );
  }
}
