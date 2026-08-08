import 'package:flutter/material.dart';

class MfBondsKnowMore extends StatelessWidget {
  const MfBondsKnowMore({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Know More',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Green Section
                Container(
                  color: const Color(0xFF2E6A4B), // Dark Green
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.menu_book, color: Colors.white, size: 20),
                          const SizedBox(height: 8),
                          const Text(
                            'Learn about\nBonds',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check_circle, color: Color(0xFF00C75A), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Fixed returns',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00C75A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.play_arrow, color: Color(0xFF1E1E1E), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Play',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom White Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  color: Colors.white,
                  child: const Text(
                    'Know everything about bonds',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
