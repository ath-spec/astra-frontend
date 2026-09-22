import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../mf/screens/fund_profile/mf_fund_profile_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String? schemeName;
  final String? category;
  final double? amount;
  final String? date;
  final String? status;
  final String? type;
  final String? schemeId;
  final String? folioNumber;

  const OrderDetailsScreen({
    super.key,
    this.schemeName,
    this.category,
    this.amount,
    this.date,
    this.status,
    this.type,
    this.schemeId,
    this.folioNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainCard(context),
                    const SizedBox(height: 32),
                    _buildExpandableSection('More details'),
                    _buildDivider(),
                    _buildSupportSection(),
                    _buildDivider(),
                  ],
                ),
              ),
            ),
            _buildBottomSupportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##,##0.00', 'en_IN');
    final name = schemeName ?? 'Mutual Fund Investment';
    final cat = category ?? 'Equity • Direct Growth';
    final amtFormatted = amount != null ? '₹ ${currencyFormatter.format(amount)}' : '₹ 100.00';
    final orderStatus = status ?? 'COMPLETED';
    final orderType = type ?? 'Buy order';
    final orderDate = date ?? DateFormat("dd MMM ''yy").format(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top half
          InkWell(
            onTap: () {
              if (schemeId != null && schemeId!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MfFundProfileScreen(fundId: schemeId!),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'M',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cat,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
          
          // Bottom half (Order info)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      orderType,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'EXTERNAL',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      amtFormatted,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: orderStatus == 'COMPLETED' ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        orderStatus,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Completion date',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                    Text(
                      orderDate,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent_outlined,
                size: 20,
                color: Colors.black,
              ),
              SizedBox(width: 12),
              Text(
                'Need help? Contact support',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFFE2E8F0),
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildBottomSupportButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headset_mic_outlined,
              size: 16,
              color: Colors.black,
            ),
            SizedBox(width: 8),
            Text(
              'Support',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
