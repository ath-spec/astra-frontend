import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/portfolio_analysis/discipline_tab.dart';
import '../widgets/portfolio_analysis/allocation_tab.dart';
import '../widgets/portfolio_analysis/performance_tab.dart';

class PortfolioAnalysisScreen extends StatelessWidget {
  const PortfolioAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 24),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'ANALYSIS',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance
                  ],
                ),
              ),
              // Tab Bar
              const TabBar(
                indicatorColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Color(0xFFCBD5E1),
                labelStyle: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.adjust, size: 16),
                          SizedBox(width: 6),
                          Text('Discipline'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_in_ar_outlined, size: 16),
                          SizedBox(width: 6),
                          Text('Allocation'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.change_history, size: 16),
                          SizedBox(width: 6),
                          Text('Performance'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Divider
              Container(
                height: 1,
                color: const Color(0xFFF8FAFC),
              ),
              // Tab Views
              const Expanded(
                child: TabBarView(
                  children: [
                    DisciplineTab(),
                    AllocationTab(),
                    PerformanceTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
