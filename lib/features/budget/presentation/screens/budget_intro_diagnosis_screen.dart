import 'package:astra_frontend/features/budget/theme/budget_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/features/budget/data/budget_mock_providers.dart';
import 'package:astra_frontend/features/budget/presentation/screens/suggested_budget_screen.dart';
import 'package:astra_frontend/features/budget/presentation/screens/finalize_total_budget_screen.dart';

class BudgetIntroDiagnosisScreen extends ConsumerStatefulWidget {
  final double totalBudget;
  const BudgetIntroDiagnosisScreen({super.key, this.totalBudget = 0.0});

  @override
  ConsumerState<BudgetIntroDiagnosisScreen> createState() =>
      _BudgetIntroDiagnosisScreenState();
}

class _BudgetIntroDiagnosisScreenState
    extends ConsumerState<BudgetIntroDiagnosisScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // fetchDiagnosis() is now called earlier in BudgetAnalyzingScreen
    // so we just read from the populated state
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetStateProvider);

    if (state.isLoadingDiagnosis) {
      return const Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Center(child: CircularProgressIndicator(color: BudgetColors.black)),
      );
    }

    final diag = state.currentDiagnosis;
    final bool hasNoData = diag != null && 
        diag.averageIncome == 0 && 
        diag.averageSavings == 0 && 
        diag.averageExpenses == 0 && 
        diag.diagnosisInsights.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SizedBox.expand(
        child: Stack(
          children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: (180), // Space for the floating button
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // iOS Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: (16),
                          top: (8),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: BudgetColors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    // Top Content: What we gathered
                    SizedBox(height: (8)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (24),
                        ),
                        child: Text("Here's what we gathered",
                          style: TextStyle(fontFamily: 'DMSans', 
                            fontSize: (18),
                            fontWeight: FontWeight.w600,
                            color: BudgetColors.black,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    SizedBox(height: (12)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (24),
                        ),
                        child: Text(
                          hasNoData
                              ? "We could not review your income and spending from the past 6 months as we found no transactions."
                              : "We reviewed your income and spending from the past 6 months.",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                            fontSize: (12),
                            color: BudgetColors.grey7,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: (20)),

                    // Averages Row
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildStatCol(
                              "Income",
                              currencyFormat.format(diag?.averageIncome ?? 0),
                              false,
                            ),
                          ),
                          // Savings gets a pill highlight
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                vertical: (4),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: (10),
                                vertical: (12),
                              ),
                              decoration: BoxDecoration(
                                color: BudgetColors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: BudgetColors.grey7,
                                  width: 1,
                                ),
                              ),
                              child: _buildStatCol(
                                "Savings",
                                currencyFormat.format(diag?.averageSavings ?? 0),
                                true,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildStatCol(
                              "Expenses",
                              currencyFormat.format(diag?.averageExpenses ?? 0),
                              false,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (hasNoData) ...[
                      SizedBox(height: (32)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (24),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all((20)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4F4),
                            border: Border.all(color: BudgetColors.errorText.withOpacity(0.3), width: 1.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: BudgetColors.errorTextAccent,
                                size: (32),
                              ),
                              SizedBox(height: (12)),
                              Text("No data available",
                                style: TextStyle(fontFamily: 'DMSans', 
                                  fontSize: (14),
                                  fontWeight: FontWeight.w600,
                                  color: BudgetColors.foreground,
                                ),
                              ),
                              SizedBox(height: (8)),
                              Text("Zeyro has no data on you at the moment. please connect your accounts to get accurate results.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                                  fontSize: (12),
                                  color: BudgetColors.grey7,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                    SizedBox(height: (22)),

                    // Divider
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (32),
                      ),
                      child: Container(
                        height: 1,
                        color: BudgetColors.midGrey.withOpacity(0.3),
                        width: double.infinity,
                      ),
                    ),

                    SizedBox(height: (14)),

                    // Diagnosis section
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (32),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Our diagnosis",
                          style: TextStyle(fontFamily: 'DMSans', 
                            fontSize: (14),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: BudgetColors.grey7,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: (6)),

                    // Horizontal scroll of issues
                    SizedBox(
                      height: (170), // Increased to prevent vertical overflow
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: (24),
                        ),
                        itemCount: diag?.diagnosisInsights.length ?? 0,
                        itemBuilder: (context, index) {
                          final insight = diag!.diagnosisInsights[index];
                          return _buildDiagnosisCard(
                            insight.title,
                            insight.description,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: (14)),

                    // What this means box
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: (24),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(
                          (20),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: BudgetColors.black12, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("What this means",
                              style: TextStyle(fontFamily: 'DMSans', 
                                fontSize: (12),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: BudgetColors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              diag?.diagnosisInsights
                                      .map((e) => e.description)
                                      .join(". ") ??
                                  "Analyzing your data...",
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                                fontSize: (10),
                                color: BudgetColors.grey7,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ],

                    SizedBox(height: (20)),
                  ],
                ),
              ),
            ),
          ),
          // Floating PERSISTENT CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: (32),
                  right: (32),
                  bottom: (16),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final state = ref.read(budgetStateProvider);
                    final diag = state.currentDiagnosis;
                    // Prefer the API's suggested budget if it's available, otherwise fallback to whatever we carried
                    final realBudget = diag?.suggestedTotalBudget ?? widget.totalBudget;

                    if (diag?.historicalSpending.isEmpty ?? true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FinalizeBudgetScreen(totalBudget: realBudget, isManual: false),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SuggestedBudgetScreen(totalBudget: realBudget),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BudgetColors.black,
                    foregroundColor: BudgetColors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 4,
                  ),
                  child: const Text("Continue to budget",
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String amount, bool isHighlight) {
    return Column(
      children: [
        Text("Avg.",
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: (12),
            color: BudgetColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: (14),
            color: BudgetColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: (isHighlight ? 18 : 14),
              color: BudgetColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisCard(String title, String body) {
    return Container(
      width: (260),
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: BudgetColors.black12, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: (12),
              fontWeight: FontWeight.w600,
              color: BudgetColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                (body),
                style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DMSans', 
                  fontSize: (10),
                  height: 1.4,
                  color: BudgetColors.grey7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
