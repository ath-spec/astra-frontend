import 'package:flutter/material.dart';

class MfOrdersFilters extends StatelessWidget {
  const MfOrdersFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterPill('FILTER', icon: Icons.tune),
          const SizedBox(width: 8),
          _buildFilterPill('BUY'),
          const SizedBox(width: 8),
          _buildFilterPill('SIP'),
          const SizedBox(width: 8),
          _buildFilterPill('SELL'),
          const SizedBox(width: 8),
          _buildFilterPill('SURPLUS'),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              fontWeight: FontWeight.w800, // Match screenshot (bold)
              letterSpacing: 1.0,
              color: Color(0xFF0F172A),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 14, color: const Color(0xFF0F172A)),
          ],
        ],
      ),
    );
  }
}
