
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/presentation/screens/recurring_control_screen.dart';

class RecurringIntroScreen extends StatelessWidget {
  const RecurringIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFfaf5ea),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: ZeyroIconButton(eventName: 'recurring_intro_screen_back_tapped', 
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {Navigator.of(context).pop(); },
                ),
              ),
            ),
            const Spacer(),
            // Square Image Tile (Matches Budget Intro Style)
            Container(
              width: getProportionateScreenWidth(280),
              height: getProportionateScreenWidth(280),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'lib/core/images/recurring_firsttime.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(40)),
            // Heading (Matches Budget Intro Style)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(28),
              ),
              child: Text(
                "manage subscriptions without the chaos",
                textAlign: TextAlign.left,
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(24),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(16)),
            // Subheading (Optional, keeping it clean for now)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(24),
              ),
              child: Text(
                "one view for all your dues. take control of your recurring payments with ease.",
                textAlign: TextAlign.left,
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(11),
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
            const Spacer(),
            // CTA Button (Matches Budget Intro Style)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(32),
              ),
              child: ZeyroButton(eventName: 'recurring_intro_screen_start_tapped', 
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecurringControlScreen(),
                      settings: const RouteSettings(name: '/recurring/control'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A0B1A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'get started',
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(10)),
            // Disclosures/Helper text
            Text(
              "achieve inner peace",
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(20)),
          ],
        ),
      ),
    );
  }
}
