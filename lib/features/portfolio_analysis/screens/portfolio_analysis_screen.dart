import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  Widget _buildTabButton(int index, String title, IconData icon, double screenWidth) {
    return AnimatedBuilder(
      animation: _tabController.animation!,
      builder: (context, child) {
        final value = _tabController.animation!.value;
        final diff = index - value; // Distance from center
        final absDiff = diff.abs();
        
        // Center is 0. Push inactive tabs to the left/right based on screen width.
        // For web/landscape we might need a smaller spacing, but screenWidth * 0.35 works well for mobile.
        // Let's cap spacing at a reasonable maximum so it doesn't fly off screen on ultrawide monitors.
        final spacing = (screenWidth * 0.35).clamp(120.0, 200.0);
        final translateX = diff * spacing;
        
        // Keep original color and font weight logic
        final color = ColorTween(
          begin: Colors.black,
          end: const Color(0xFFCBD5E1),
        ).transform(absDiff.clamp(0.0, 1.0))!;
        
        final fontWeight = absDiff < 0.5 ? FontWeight.w600 : FontWeight.w500;

        return Transform.translate(
          offset: Offset(translateX, 0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Custom ease-out curve for snappy responsiveness
              _tabController.animateTo(index, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 16,
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
    );
  }

  Widget _buildPortraitLayout(BuildContext context, double screenWidth) {
    return Column(
      children: [
        // Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: SizedBox(
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
        // Custom Carousel Tab Bar (Emil Design)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! < -300) {
              if (_tabController.index < 2) {
                _tabController.animateTo(_tabController.index + 1, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
              }
            } else if (details.primaryVelocity! > 300) {
              if (_tabController.index > 0) {
                _tabController.animateTo(_tabController.index - 1, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
              }
            }
          },
          child: SizedBox(
            height: 48,
            width: screenWidth,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildTabButton(0, 'Discipline', Icons.adjust, screenWidth),
                _buildTabButton(1, 'Allocation', Icons.view_in_ar_outlined, screenWidth),
                _buildTabButton(2, 'Performance', Icons.change_history, screenWidth),
              ],
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
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _buildPortraitLayout(context, screenWidth),
          ),
        ),
      ),
    );
  }
}
