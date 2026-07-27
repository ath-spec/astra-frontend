import 'package:astra_frontend/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App onboarding smoke test: Splash -> Phone -> PAN -> Asset Connection -> Dashboard', (WidgetTester tester) async {
    final oldBuilder = ErrorWidget.builder;
    addTearDown(() => ErrorWidget.builder = oldBuilder);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AstraApp(),
      ),
    );

    // Verify that SplashScreen is rendered first
    expect(find.text('ASTRA'), findsOneWidget);

    // Fast-forward 3 seconds to let timer trigger transition to /login
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the phone onboarding login screen is rendered
    expect(find.text('Build your path to financial freedom'), findsOneWidget);

    // Enter a valid 10-digit phone number
    await tester.enterText(find.byType(TextField), '8826473535');
    await tester.pump();

    // Tap Get Started button to move to PAN verification screen
    await tester.ensureVisible(find.text('Get Started ->'));
    await tester.tap(find.text('Get Started ->'));
    await tester.pumpAndSettle();

    // Verify we are on PAN verification screen
    expect(find.text('Enter your PAN'), findsOneWidget);

    // Enter a valid 10-character PAN number
    await tester.enterText(find.byType(TextField), 'ABCDE1234F');
    await tester.pump();

    // Tap Checkbox for Account Aggregator consent
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    // Tap Continue button to move to Asset Connection flow
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify we are on Connecting Assets screen (Step 1: Mutual Funds linking)
    expect(find.text('Connecting your assets'), findsOneWidget);
    expect(find.text('Mutual Funds'), findsOneWidget);
    expect(find.text('Linking now...'), findsOneWidget);

    // Fast-forward 2 seconds for timer to show Mutual Funds Status (Image 2)
    await tester.pumpAndSettle();
    expect(find.text('No mutual funds found for\nthis PAN and mobile'), findsOneWidget);

    // Tap CONNECT button as instructed ("instead of retry do connect")
    await tester.ensureVisible(find.text('CONNECT'));
    await tester.tap(find.text('CONNECT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify we returned to Connecting Assets screen (Step 2: Stocks linking)
    expect(find.text('Connecting your assets'), findsOneWidget);
    expect(find.text('Stocks'), findsOneWidget);

    // Fast-forward 2 seconds for timer to show Stocks Connection OTP screen (Image 5)
    await tester.pumpAndSettle();
    expect(find.text('2 of 3'), findsOneWidget);
    expect(find.text('Fetch Stock holdings from\ndemat accounts'), findsOneWidget);
    expect(find.text('Verify OTP'), findsOneWidget);

    // Enter 6-digit OTP (auto-submits upon reaching 6 digits)
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Stocks Verifying OTP loading screen (Image 2)
    expect(find.text('Verifying OTP'), findsOneWidget);

    // Fast-forward 2s to fire 1.8s timer and show Demat Accounts searching screen (Image 1)
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('Securely looking for demat'), findsOneWidget);

    // Fast-forward 2s to fire 1.8s timer and show Stocks Status screen (Image 3: No stocks found by default)
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('No stocks found'), findsOneWidget);
    expect(find.text('Re-generate OTP to fetch stocks'), findsOneWidget);
    expect(find.text('Continue without stocks'), findsOneWidget);

    // Tap Re-generate OTP to test the retry loop
    await tester.ensureVisible(find.text('Re-generate OTP to fetch stocks'));
    await tester.tap(find.text('Re-generate OTP to fetch stocks'));
    await tester.pumpAndSettle();
    expect(find.text('Verify OTP'), findsOneWidget);

    // Enter OTP again (auto-submits)
    await tester.enterText(find.byType(TextField), '654321');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Fast-forward through Verifying and Searching screens back to Status screen
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('No stocks found'), findsOneWidget);

    // Toggle demo switch at top to test "Stocks found" state
    await tester.tap(find.text('Demo: No Stocks Found'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 Demat Accounts found'), findsOneWidget);
    expect(find.text('CONNECT DEMAT ACCOUNTS'), findsOneWidget);

    // Tap CONNECT DEMAT ACCOUNTS button
    await tester.ensureVisible(find.text('CONNECT DEMAT ACCOUNTS'));
    await tester.tap(find.text('CONNECT DEMAT ACCOUNTS'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify we returned to Connecting Assets screen (Image 4: Step 3 Banks linking)
    expect(find.text('Connecting your assets'), findsOneWidget);
    expect(find.text('Banks'), findsOneWidget);

    // Fast-forward 2s to fire 1.8s timer and show Bank Accounts searching screen (Image 5)
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('Securely looking for bank'), findsOneWidget);
    expect(find.text('Continue to Bank Accounts ↗'), findsOneWidget);

    // Tap Continue to Bank Accounts button
    await tester.ensureVisible(find.text('Continue to Bank Accounts ↗'));
    await tester.tap(find.text('Continue to Bank Accounts ↗'));
    await tester.pumpAndSettle();

    // Verify Bank Linking Screen
    expect(find.text('We found these bank accounts'), findsOneWidget);
    expect(find.text('3 of 3'), findsOneWidget);
    expect(find.text('Link selected accounts'), findsOneWidget);

    // Tap Link selected accounts -> opens Consent Sheet
    await tester.ensureVisible(find.text('Link selected accounts'));
    await tester.tap(find.text('Link selected accounts'));
    await tester.pumpAndSettle();
    expect(find.text('Providing consent to DEZERV'), findsOneWidget);

    // Tap Confirm permissions -> opens OTP Sheet
    await tester.ensureVisible(find.text('Confirm permissions'));
    await tester.tap(find.text('Confirm permissions'));
    await tester.pumpAndSettle();
    expect(find.text('Link your bank account'), findsOneWidget);

    // Enter OTP and verify
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Verify OTP'));
    await tester.tap(find.text('Verify OTP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Progress Spinner screen
    expect(find.text('Linking all your accounts'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify Post-linking state on Bank Linking Screen
    expect(find.textContaining('You are already tracking this account'), findsWidgets);
    expect(find.text('Complete and proceed ->'), findsOneWidget);

    // Tap Complete and proceed ->
    await tester.ensureVisible(find.text('Complete and proceed ->'));
    await tester.tap(find.text('Complete and proceed ->'));
    await tester.pumpAndSettle();

    // Verify Profiling Intro Screen
    expect(find.textContaining('Answer a few questions to'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    // Fast-forward 1.8s for Get Started button fill animation to complete
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    // Tap Get started
    await tester.ensureVisible(find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Verify Profiling Questions Screen - Question 1 of 4
    expect(find.text('1 of 4'), findsOneWidget);
    expect(find.text('What is your yearly income?'), findsOneWidget);

    // Select Option 1 and tap Continue
    await tester.tap(find.text('Less than ₹10 Lakhs'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue ->'));
    await tester.tap(find.text('Continue ->'));
    await tester.pumpAndSettle();

    // Question 2 of 4
    expect(find.text('2 of 4'), findsOneWidget);
    expect(find.text("I'm a salaried employee"), findsOneWidget);
    await tester.tap(find.text("I'm a salaried employee"));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue ->'));
    await tester.tap(find.text('Continue ->'));
    await tester.pumpAndSettle();

    // Question 3 of 4
    expect(find.text('3 of 4'), findsOneWidget);
    expect(find.text('Less than ₹25 Lakhs'), findsOneWidget);
    await tester.tap(find.text('Less than ₹25 Lakhs'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue ->'));
    await tester.tap(find.text('Continue ->'));
    await tester.pumpAndSettle();

    // Question 4 of 4
    expect(find.text('4 of 4'), findsOneWidget);
    expect(find.text('Long term wealth creation'), findsOneWidget);
    await tester.tap(find.text('Long term wealth creation'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue ->'));
    await tester.tap(find.text('Continue ->'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Profiling Status screen (Submitting -> Submitted)
    expect(find.text('Submitting your details...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
    expect(find.text('Details submitted'), findsOneWidget);

    // Fast-forward 1.5s for automatic navigation to Home Screen
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify Home Screen with Typewriter banner and Dashboard
    expect(find.text('Thanks for attaching your assets.'), findsOneWidget);
    expect(find.text('System Telemetry & Metrics'), findsOneWidget);
  });
}
