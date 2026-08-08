import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ResponsiveAppWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveAppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Industry-grade standard for desktop web constraints (iPhone 14/15 Pro dimension: 393 x 852)
        // We trigger this wrapper if the screen width is reasonably larger than a mobile device (> 600)
        if (kIsWeb && constraints.maxWidth > 600) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              color: const Color(0xFFF1F5F9), // Elegant slate-100 background for desktop
              child: Center(
                child: Container(
                  width: 393,
                  height: 852,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.black, // Acts as the bezel color
                    borderRadius: BorderRadius.circular(44), // Outer phone hardware radius
                    boxShadow: [
                      // Deep ambient shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 80,
                        spreadRadius: -10,
                        offset: const Offset(0, 30),
                      ),
                      // Harder contact shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      // Very subtle bright top edge for 3D realism
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 1,
                        spreadRadius: 1,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Padding(
                    // Width of the phone bezel
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36), // Inner screen radius
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // On physical mobile devices or narrow browser windows, run perfectly native/full-screen
        return child;
      },
    );
  }
}
