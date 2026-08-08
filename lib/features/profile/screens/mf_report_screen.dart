import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MfReportScreen extends StatelessWidget {
  const MfReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(left: 24, top: 16, right: 24, bottom: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 44), // balance the back button
                        child: Text(
                          'MUTUAL FUND REPORT',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
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

            // Content List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                children: [
                  _buildReportSection(
                    context,
                    
                    title: 'ELSS Statement',
                    latestPeriod: 'FY 2026-27',
                    latestSubtitle: "from april '26 to mar '27",
                    onViewAll: () => context.push('/mf-report-list', extra: 'ELSS STATEMENT'),
                  ),
                  _buildDivider(),
                  _buildReportSection(
                    context,
                    
                    title: 'Capital Gains',
                    latestPeriod: 'FY 2026-27',
                    latestSubtitle: "from april '26 to mar '27",
                    onViewAll: () => context.push('/mf-report-list', extra: 'CAPITAL GAINS'),
                  ),
                  _buildDivider(),
                  _buildReportSection(
                    context,
                    
                    title: 'Transactions',
                    latestPeriod: 'FY 2026-27',
                    latestSubtitle: "from april '26 to mar '27",
                    onViewAll: () => context.push('/mf-report-list', extra: 'TRANSACTIONS'),
                  ),
                  _buildDivider(),
                  _buildReportSection(
                    context,
                    
                    title: 'Mutual Fund Holdings',
                    latestPeriod: 'Your Mutual Fund Holdings',
                    latestSubtitle: "as of today",
                    onViewAll: null, // No view all for this one based on image
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Container(
        height: 1,
        color: const Color(0xFFF1F5F9),
      ),
    );
  }

  Widget _buildReportSection(
    BuildContext context, {
    
    required String title,
    required String latestPeriod,
    required String latestSubtitle,
    VoidCallback? onViewAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8), // gray-400
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // very light gray/blue fill
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF0F172A), width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    latestPeriod,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    latestSubtitle,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 10,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF0F172A), width: 1.0),
                ),
                child: Text(
                  'Download',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
