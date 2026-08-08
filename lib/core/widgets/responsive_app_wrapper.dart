import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ResponsiveAppWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveAppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (kIsWeb && constraints.maxWidth > 700) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              color: const Color(0xFFE2E8F0), // Soft slate background for contrast
              child: Center(
                child: SizedBox(
                  width: 401, // 393 + 8 for buttons
                  height: 852,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // --- HARDWARE BUTTONS ---
                      // Mute Switch
                      Positioned(
                        left: 0,
                        top: 200,
                        child: Container(
                          width: 4,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFF9CA3AF),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                          ),
                        ),
                      ),
                      // Volume Up
                      Positioned(
                        left: 0,
                        top: 250,
                        child: Container(
                          width: 4,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF9CA3AF),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                          ),
                        ),
                      ),
                      // Volume Down
                      Positioned(
                        left: 0,
                        top: 320,
                        child: Container(
                          width: 4,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF9CA3AF),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                          ),
                        ),
                      ),
                      // Power Button
                      Positioned(
                        right: 0,
                        top: 280,
                        child: Container(
                          width: 4,
                          height: 90,
                          decoration: const BoxDecoration(
                            color: Color(0xFF9CA3AF),
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                          ),
                        ),
                      ),

                      // --- PHONE BODY ---
                      Container(
                        width: 393,
                        height: 852,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E), // Titanium Black edge
                          borderRadius: BorderRadius.circular(55), // iPhone outer radius
                          border: Border.all(
                            color: const Color(0xFF6B7280), // Metallic sheen
                            width: 2.5,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 50,
                              spreadRadius: 10,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0), // Screen Bezel thickness
                          child: Stack(
                            children: [
                              // --- THE APP SCREEN ---
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(44), // Screen corner radius
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(44),
                                  child: child, // The actual Flutter App
                                ),
                              ),

                              // --- DYNAMIC ISLAND ---
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  width: 120,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(24), // Pill shape
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Front Camera Lens
                                      Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF111111),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: const Color(0xFF262626), width: 1.5),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 5,
                                              height: 5,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF0F264A), // Lens reflection tint
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // FaceID Sensor
                                      Padding(
                                        padding: const EdgeInsets.only(right: 22),
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF1A1A1A),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Native behavior on mobile
        return child;
      },
    );
  }
}
