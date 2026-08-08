import 'package:flutter/material.dart';

class MfFdPlansList extends StatefulWidget {
  const MfFdPlansList({super.key});

  @override
  State<MfFdPlansList> createState() => _MfFdPlansListState();
}

class _MfFdPlansListState extends State<MfFdPlansList> {
  int _selectedTabIndex = 1; // Default to 'Mid term'

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Let\'s find best FD plans for you!',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(child: _buildTab(0, 'Short term', '0 to 2 years')),
              const SizedBox(width: 8),
              Expanded(child: _buildTab(1, 'Mid term', '2 to 3 years')),
              const SizedBox(width: 8),
              Expanded(child: _buildTab(2, 'Long term', '3 to 5 years')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildList(),
        ),
      ],
    );
  }

  Widget _buildTab(int index, String title, String subtitle) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? const Color(0xFF00C75A) : const Color(0xFFE2E8F0),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: const Color(0xFF1E1E1E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        _buildPlanCard(
          bankName: 'Suryoday SF Bank',
          badgeText: 'Instant Withdrawal',
          badgeIcon: Icons.star,
          rate: '8.10',
          logoColor: Colors.deepOrange,
          isBestPlan: true,
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          bankName: 'Shriram Finance',
          badgeText: 'AA+(Stable) by ICRA',
          badgeIcon: Icons.star,
          rate: '7.60',
          logoColor: Colors.amber,
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          bankName: 'slice SF Bank',
          badgeText: 'Get money in 3 hours',
          badgeIcon: Icons.star,
          rate: '7.50',
          logoColor: Colors.purpleAccent,
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String bankName,
    required String badgeText,
    required IconData badgeIcon,
    required String rate,
    required Color logoColor,
    bool isBestPlan = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isBestPlan ? const Color(0xFF530582) : const Color(0xFFE2E8F0),
          width: isBestPlan ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          if (isBestPlan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: const BoxDecoration(
                color: Color(0xFF530582), // Dark purple header
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              child: const Text(
                'Best FD plan',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: logoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.account_balance, color: logoColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bankName,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(badgeIcon, size: 10, color: const Color(0xFF530582)),
                          const SizedBox(width: 4),
                          Text(
                            badgeText,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 11,
                              color: Color(0xFF530582), // Deep purple badge text
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      rate,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00C75A), // Bright green
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      '% p.a.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00C75A),
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
}
