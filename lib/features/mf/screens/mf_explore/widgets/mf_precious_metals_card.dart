import 'package:flutter/material.dart';
import 'dart:math' as math;

class MfPreciousMetalsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget graphic;
  final Color baseColor; // e.g. Gold or Silver gradient background
  final String topFundName;
  final String topFundReturns;

  const MfPreciousMetalsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.graphic,
    required this.baseColor,
    required this.topFundName,
    required this.topFundReturns,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Invest in Precious Metals',
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
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                baseColor.withOpacity(0.15),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFF1F5F9), // Slate 100
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Graphic
              SizedBox(
                height: 100,
                child: graphic,
              ),
              const SizedBox(height: 24),
              // Text
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Stacked cards
              SizedBox(
                height: 130, // Space for stacked cards
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // Bottom card (faded, smaller)
                    Positioned(
                      top: 24,
                      child: Transform.scale(
                        scale: 0.9,
                        child: _buildMiniCard(opacity: 0.5),
                      ),
                    ),
                    // Middle card (slightly faded)
                    Positioned(
                      top: 12,
                      child: Transform.scale(
                        scale: 0.95,
                        child: _buildMiniCard(opacity: 0.8),
                      ),
                    ),
                    // Top card (fully visible)
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Icon(Icons.currency_exchange_rounded, size: 18, color: Colors.blue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topFundName,
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
                                  const Text(
                                    'Commodities • Precious Metals',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  topFundReturns,
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '3Y Returns',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View collection',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 300,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
