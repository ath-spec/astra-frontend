import 'package:flutter/material.dart';
import '../../fund_profile/mf_fund_profile_screen.dart';
import '../../mf_collection/mf_alternative_collection_screen.dart';

class MfAlternativeFunds extends StatelessWidget {
  const MfAlternativeFunds({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alternative to FD',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Better returns than FDs, liquid and tax efficient',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => const MfAlternativeCollectionScreen(
                        title: 'Alternative to FD',
                        subtitle: 'Better returns than FDs, liquid and tax efficient',
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    children: [
                    const Text(
                      'View all',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 390 / 140,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth * (280 / 390);
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildAlternativeCard(
                    context: context,
                    width: cardWidth,
                    name: 'Union Liquid Fund',
                    category: 'Debt • Liquid',
                    expense: '0.06%',
                    aum: '₹6649 Crs',
                    returns: '7.0%',
                    logoIcon: Icons.water_drop_outlined,
                    logoColor: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildAlternativeCard(
                    context: context,
                    width: cardWidth,
                    name: 'Nippon India Arbitrage Fund',
                    category: 'Alternative to FD',
                    expense: '0.35%',
                    aum: '14,352',
                    returns: '7.8%',
                    logoIcon: Icons.balance,
                    logoColor: const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 16),
                  _buildAlternativeCard(
                    context: context,
                    width: cardWidth,
                    name: 'SBI Equity Savings Fund',
                    category: 'Alternative to FD',
                    expense: '0.41%',
                    aum: '3,210',
                    returns: '9.2%',
                    logoIcon: Icons.eco,
                    logoColor: const Color(0xFF15803D),
                  ),
                  const SizedBox(width: 16),
                  _buildAlternativeCard(
                    context: context,
                    width: cardWidth,
                    name: 'HDFC Liquid Fund',
                    category: 'Debt • Liquid',
                    expense: '0.08%',
                    aum: '8,000',
                    returns: '7.1%',
                    logoIcon: Icons.account_balance,
                    logoColor: Colors.red,
                  ),
                  const SizedBox(width: 16),
                  _buildAlternativeCard(
                    context: context,
                    width: cardWidth,
                    name: 'Kotak Equity Arbitrage',
                    category: 'Alternative to FD',
                    expense: '0.38%',
                    aum: '5,420',
                    returns: '7.5%',
                    logoIcon: Icons.money,
                    logoColor: Colors.amber,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeCard({
    required BuildContext context,
    required double width,
    required String name,
    required String category,
    required String expense,
    required String aum,
    required String returns,
    required IconData logoIcon,
    required Color logoColor,
  }) {
    return GestureDetector(
      onTap: () => MfFundProfileScreen.showModal(context, name),
      child: Container(
        width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(logoIcon, color: logoColor, size: 20),
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
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
            margin: const EdgeInsets.only(bottom: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Expense ratio', expense),
              _buildStat('AUM', aum),
              _buildStat('3Y Returns', returns, isGreen: true),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildStat(String label, String value, {bool isGreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isGreen ? const Color(0xFF10B981) : const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }
}
