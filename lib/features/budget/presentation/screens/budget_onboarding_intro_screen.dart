import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:astra_frontend/core/instrumentation/funnel_tracker.dart';
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astra_frontend/features/budget/presentation/screens/budget_analyzing_screen.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class BudgetOnboardingIntroScreen extends StatefulWidget {
  const BudgetOnboardingIntroScreen({super.key});

  @override
  State<BudgetOnboardingIntroScreen> createState() => _BudgetOnboardingIntroScreenState();
}

class _BudgetOnboardingIntroScreenState extends State<BudgetOnboardingIntroScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('budget_onboarding_intro_screen');
    FunnelTracker.instance.startFunnel('budget_creation');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: ZeyroIconButton(eventName: 'budget_onboarding_intro_screen_back_tapped', 
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: BudgetColors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    FunnelTracker.instance.cancelFunnel('budget_creation');
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            const Spacer(),
            // Square Image Tile
            Container(
              width: getProportionateScreenWidth(280),
              height: getProportionateScreenWidth(280),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'lib/core/images/new_budget.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(40)),
            // Heading
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(24),
              ),
              child: Text("Let's create your personalized budget",
                textAlign: TextAlign.left,
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(24),
                  fontWeight: FontWeight.w600,
                  color: BudgetColors.black,
                  height: 1.1,
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(16)),
            // Subheading
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(24),
              ),
              child: Text(
                "AI analyzes your spending and builds a custom budget, designed to fit your real life.",
                textAlign: TextAlign.left,
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(14),
                  fontWeight: FontWeight.w400,
                  color: BudgetColors.grey7,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Spacer(),
            // Buttons
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(32),
              ),
              child: Column(
                children: [
                  ZeyroButton(eventName: 'budget_onboarding_intro_screen_continue_tapped', 
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BudgetAnalyzingScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF0A0B1A,
                      ), // Very dark blue/black
                      foregroundColor: BudgetColors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Generate AI powered budget',
                          style: TextStyle(fontFamily: 'DMSans', 
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.auto_awesome, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(10)),
            // Disclosures
            Text(
              "Answers may contain inaccurate data. See disclosures.",
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: BudgetColors.midGrey,
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(6)),
          ],
        ),
      ),
      ),
    );
  }
}
