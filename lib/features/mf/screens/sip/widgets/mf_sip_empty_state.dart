import 'package:flutter/material.dart';

class MfSipEmptyState extends StatelessWidget {
  final VoidCallback? onCtaTapped;

  const MfSipEmptyState({
    super.key,
    this.onCtaTapped,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = screenWidth < 420 ? screenWidth / 420 : 1.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24.0 * scale,
          right: 24.0 * scale,
          bottom: 80.0 * scale, // Offsets visual weight of the text
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 350 * scale,
              height: 220 * scale,
              child: Image.asset(
                'lib/core/images/sipnew.webp',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Column(
              children: [
                Text(
                  "You currently have no SIP",
                  textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Text(
                    "Start an SIP, STP or SWP and your plans will appear here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12 * scale,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32 * scale),
                  GestureDetector(
                    onTap: onCtaTapped,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 12 * scale),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(4 * scale),
                      ),
                      child: Text(
                        "Explore All Funds".toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
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
