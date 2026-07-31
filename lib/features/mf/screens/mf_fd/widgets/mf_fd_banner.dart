import 'package:flutter/material.dart';

class MfFdBanner extends StatefulWidget {
  const MfFdBanner({super.key});

  @override
  State<MfFdBanner> createState() => _MfFdBannerState();
}

class _MfFdBannerState extends State<MfFdBanner> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F4EB), // Light green-beige background from design
      padding: const EdgeInsets.only(left: 20.0, top: 32.0, bottom: 32.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Book a FD',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF236A44), // Dark green
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Without opening a\nnew bank account',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    color: Color(0xFF386047),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) => setState(() => _isPressed = false),
                  onTapCancel: () => setState(() => _isPressed = false),
                  onTap: () {},
                  child: AnimatedScale(
                    scale: _isPressed ? 0.97 : 1.0,
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C75A), // Bright green
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Book now',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '8.1',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2C2C2C),
                            height: 1,
                            letterSpacing: -2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(2, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2C2C2C),
                            height: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(2, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8869),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Text(
                        'DICGC insured up to ₹5L',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
