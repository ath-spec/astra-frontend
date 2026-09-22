import 'package:flutter/material.dart';
import 'package:astra_frontend/features/stocks/data/stocks_models.dart';

class StockShareholdingWidget extends StatelessWidget {
  final StockShareholdingPattern data;

  const StockShareholdingWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Same card container style used across the rest of this screen (and
    // the fund profile's asset-allocation card): white bg, subtle border,
    // soft shadow — this used to render as bare, unboxed padding.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shareholding pattern',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
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
                _buildShareholdingRow('Promoter', data.promoter, const Color(0xFF6366F1)),
                const SizedBox(height: 16),
                _buildShareholdingRow('FII (Foreign Inst.)', data.fii, const Color(0xFF10B981)),
                const SizedBox(height: 16),
                _buildShareholdingRow('DII (Domestic Inst.)', data.dii, const Color(0xFFF59E0B)),
                const SizedBox(height: 16),
                _buildShareholdingRow('Public / Retail', data.public, const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareholdingRow(String label, List<ShareholderInfo> items, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    final double percentage = items.first.percentage;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(2)}%',
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (percentage / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
