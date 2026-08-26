import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:astra_frontend/features/dashboard/data/dashboard_models.dart';

/// Today's 1D change for the Mutual Funds / Stocks buckets, driven by
/// `GET /api/v1/dashboard/summary`.
///
/// Note: the backend only exposes 1D change at the asset-bucket level (one
/// figure for all Mutual Funds combined, one for all Stocks combined), not
/// per-instrument — so, unlike the old mocked design (a scrollable list of
/// individual fund/stock cards with their own sort control), this shows one
/// card per connected bucket rather than fabricating per-instrument change
/// figures the backend doesn't provide.
class HomeTodayPortfolioChanges extends StatelessWidget {
  final DashboardSummary summary;

  const HomeTodayPortfolioChanges({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final bool mfConnected = summary.mfConnected;
    final bool stocksConnected = summary.stocksConnected;
    if (!mfConnected && !stocksConnected) return const SizedBox.shrink();

    final totalIsUp = summary.oneDayChangeAmount >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s portfolio changes',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.0,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total 1D Change',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        totalIsUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 14,
                        color: totalIsUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 2),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: totalIsUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                          ),
                          children: [
                            TextSpan(text: '${summary.oneDayChangePct.abs().toStringAsFixed(2)}% '),
                            TextSpan(
                              text: '(₹${summary.oneDayChangeAmount.abs().toStringAsFixed(0)})',
                              style: const TextStyle(color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // No benchmark-index endpoint exists yet, so the Nifty 50
            // comparison stays a static placeholder for now.
            Container(
              width: 1,
              height: 36,
              color: const Color(0xFFE2E8F0),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nifty 50',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFFEF4444)),
                    SizedBox(width: 2),
                    Text(
                      '-0.26%',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Dotted divider
        CustomPaint(
          size: const Size(double.infinity, 1),
          painter: _DottedLinePainter(),
        ),
        const SizedBox(height: 24),
        // Bucket cards
        Row(
          children: [
            if (mfConnected)
              Expanded(
                child: _BucketChangeCard(
                  name: 'Mutual Funds',
                  bucket: summary.mutualFunds,
                ),
              ),
            if (mfConnected && stocksConnected) const SizedBox(width: 12),
            if (stocksConnected)
              Expanded(
                child: _BucketChangeCard(
                  name: 'Stocks',
                  bucket: summary.stocks,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BucketChangeCard extends StatelessWidget {
  final String name;
  final DashboardAssetBucket bucket;

  const _BucketChangeCard({required this.name, required this.bucket});

  @override
  Widget build(BuildContext context) {
    final bool isUp = bucket.oneDayChangeAmount >= 0;
    final color = isUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final icon = isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final valueText = '₹${bucket.value.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    final changeText =
        '₹${bucket.oneDayChangeAmount.abs().toStringAsFixed(0)} (${bucket.oneDayChangePct.abs().toStringAsFixed(2)}%)';

    return GestureDetector(
      onTap: () {
        context.push('/asset-today-change', extra: <String, dynamic>{
          'name': name,
          'subtitle': name,
          'value': valueText,
          'change': changeText,
          'isUp': isUp,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              valueText,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 2),
                Text(
                  changeText,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
