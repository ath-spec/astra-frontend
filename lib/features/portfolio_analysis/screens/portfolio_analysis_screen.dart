import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/portfolio_analysis/discipline_tab.dart';
import '../widgets/portfolio_analysis/allocation_tab.dart';
import '../widgets/portfolio_analysis/performance_tab.dart';

class PortfolioAnalysisScreen extends StatefulWidget {
  final int initialTab;
  const PortfolioAnalysisScreen({super.key, this.initialTab = 0});

  @override
  State<PortfolioAnalysisScreen> createState() => _PortfolioAnalysisScreenState();
}

class _PortfolioAnalysisScreenState extends State<PortfolioAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabButton(int index, String title, IconData icon) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          final value = _tabController.animation!.value;
          final diff = (value - index).abs();
          
          final color = ColorTween(
            begin: Colors.black,
            end: const Color(0xFFCBD5E1),
          ).transform(diff.clamp(0.0, 1.0))!;
          
          final fontWeight = diff < 0.5 ? FontWeight.w600 : FontWeight.w500;

          return InkWell(
            onTap: () {
              _tabController.animateTo(index);
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12.sp,
                        fontWeight: fontWeight,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
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
                      child: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'ANALYSIS',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 12.sp,
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
            // Custom Tab Bar with Smooth Sliding
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < -300) {
                  // Swipe Left -> go to next tab
                  if (_tabController.index < 2) {
                    _tabController.animateTo(_tabController.index + 1);
                  }
                } else if (details.primaryVelocity! > 300) {
                  // Swipe Right -> go to previous tab
                  if (_tabController.index > 0) {
                    _tabController.animateTo(_tabController.index - 1);
                  }
                }
              },
              child: SizedBox(
                height: 48,
                width: screenWidth,
                child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, child) {
                  final value = _tabController.animation!.value;
                  // value: 0 -> left = width/3, value: 1 -> left = 0, value: 2 -> left = -width/3
                  final leftOffset = (1.0 - value) * (screenWidth / 3);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: leftOffset,
                        width: screenWidth,
                        child: Row(
                          children: [
                            _buildTabButton(0, 'Discipline', Icons.adjust),
                            _buildTabButton(1, 'Allocation', Icons.view_in_ar_outlined),
                            _buildTabButton(2, 'Performance', Icons.change_history),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ),
            // Divider
            Container(
              height: 1,
              color: const Color(0xFFF8FAFC),
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
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
    ),
    );
  }
}
