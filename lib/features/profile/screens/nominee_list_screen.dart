import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NomineeListScreen extends StatelessWidget {
  const NomineeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(left: 24 * scale, top: 16 * scale, right: 24 * scale, bottom: 24 * scale),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44 * scale,
                      height: 44 * scale,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF0F172A),
                        size: 20 * scale,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 44 * scale), // balance the back button
                        child: Text(
                          'NOMINEES',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              height: 1,
              color: const Color(0xFFF1F5F9),
            ),

            // Main Content (Empty State)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration placeholder
                    Container(
                      width: 160 * scale,
                      height: 160 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_search_rounded,
                          size: 64 * scale,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    SizedBox(height: 32 * scale),
                    
                    // Title
                    Text(
                      'No nominees yet',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12 * scale),
                    
                    // Subtitle
                    Text(
                      'Add a nominee to your mutual fund investments.',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12 * scale,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48 * scale),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: EdgeInsets.all(24 * scale),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 18 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4 * scale),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Add a nominee',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
