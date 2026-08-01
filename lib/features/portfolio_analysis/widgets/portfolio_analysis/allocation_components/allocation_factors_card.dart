import 'package:flutter/material.dart';

class AllocationFactorsCard extends StatelessWidget {
  const AllocationFactorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'ALLOCATION FACTORS',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                ],
              ),
            ),
            const _DottedDivider(),
            
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    Container(height: 8, width: 4, color: const Color(0xFF38A169)), // Tiny green segment
                    const SizedBox(width: 2),
                    Expanded(child: Container(height: 8, color: const Color(0xFFE53E3E))), // Massive red segment
                  ],
                ),
              ),
            ),
            
            _buildFactorItem(
              icon: Icons.change_history,
              title: 'Stable assets',
              subtitle: 'Bank Accounts, FDs, Surplus & Liqui...',
              amount: '₹3,058',
              percentage: '1%',
              iconColor: const Color(0xFF38A169),
            ),
            const _DottedDivider(),
            _buildFactorItem(
              icon: Icons.account_tree_outlined,
              title: 'Low volatility assets',
              subtitle: 'Mostly steady, small ups and downs',
              amount: '₹0',
              percentage: '0%',
              iconColor: const Color(0xFF38A169),
            ),
            const _DottedDivider(),
            _buildFactorItem(
              icon: Icons.star_border,
              title: 'Medium volatility assets',
              subtitle: 'Moderate swings, growth potential',
              amount: '₹0',
              percentage: '0%',
              iconColor: const Color(0xFFDD6B20),
            ),
            const _DottedDivider(),
            _buildFactorItem(
              icon: Icons.ac_unit,
              title: 'High volatility assets',
              subtitle: 'High swings, high potential',
              amount: '₹3,45,126',
              percentage: '99%',
              iconColor: const Color(0xFFE53E3E),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String percentage,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Icon(icon, size: 14, color: iconColor),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    amount,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                percentage,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DottedLinePainter(),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    
    double dashWidth = 3;
    double dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
