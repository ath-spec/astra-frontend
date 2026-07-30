import 'package:flutter/material.dart';

class MfIncomeSafety extends StatelessWidget {
  const MfIncomeSafety({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Income & Safety',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildRow(
                icon: Icons.shield_rounded,
                iconBgColor: const Color(0xFFFFFBEB),
                iconColor: const Color(0xFFF59E0B),
                title: 'Corporate Bonds',
                subtitle: 'High returns • Low Risk',
                returns: '12.4%',
              ),
              _buildDivider(),
              _buildRow(
                icon: Icons.lock_outline_rounded,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                title: 'Fixed Deposits',
                subtitle: 'Stable returns • Safe',
                returns: '7.2%',
              ),
              _buildDivider(),
              _buildRow(
                icon: Icons.bar_chart_rounded,
                iconBgColor: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF10B981),
                title: 'Debt Funds',
                subtitle: 'Better than FD • Low Risk',
                returns: '7.6%',
              ),
              _buildDivider(),
              _buildRow(
                icon: Icons.water_drop_outlined,
                iconBgColor: const Color(0xFFF5F3FF),
                iconColor: const Color(0xFF8B5CF6),
                title: 'Liquid Funds',
                subtitle: 'Instant access • Very Low Risk',
                returns: '6.3%',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String returns,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                returns,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981), // Green
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 1,
      color: const Color(0xFFF1F5F9),
    );
  }
}
