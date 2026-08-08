import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astra_frontend/services/service_providers.dart';

class RecurringIntroScreen extends ConsumerStatefulWidget {
  const RecurringIntroScreen({super.key});

  @override
  ConsumerState<RecurringIntroScreen> createState() =>
      _RecurringIntroScreenState();
}

class _RecurringIntroScreenState extends ConsumerState<RecurringIntroScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0XFFFEFEFE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: ZeyroIconButton(
                  eventName: 'recurring_intro_screen_back_tapped',
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            const Spacer(),
            // Square Image Tile (Matches Budget Intro Style)
            SizedBox(
              width: getProportionateScreenWidth(280),
              height: getProportionateScreenWidth(280),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'lib/core/images/new_recurring_white_bg.webp',
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
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Manage subscriptions without the chaos",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: getProportionateScreenWidth(24),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(16)),
            // Subheading (Optional, keeping it clean for now)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(24),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "One view for all your dues. take control of your recurring payments with ease.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: getProportionateScreenWidth(14),
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // CTA Button (Matches Budget Intro Style)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(32),
              ),
              child: ZeyroButton(
                eventName: 'recurring_intro_screen_start_tapped',
                onPressed: () {
                  ref.read(budgetStateProvider).setRecurringSetup(true);
                  // Use go('/') to reset the stack, then push to get the normal
                  // forward slide transition, just like other screens.
                  context.go('/');
                  context.push('/recurring-control');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A0B1A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Get started',
                  style: TextStyle(
                    fontFamily: 'DMSans',
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
              "Achieve inner peace",
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
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
