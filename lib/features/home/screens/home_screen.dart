import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/feature_card.dart';
import '../widgets/stats_summary_widget.dart';

/// Main Home and Dashboard screen with typewriter onboarding message and fetching progress.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  // Typewriter animation state
  final String _fullText =
      "We are working on fetching your data safely and accurately. This might take a while.";
  int _charCount = 0;
  Timer? _typewriterTimer;

  // Fetching progress state
  double _fetchProgress = 0.1;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() {
    _charCount = 0;
    _fetchProgress = 0.1;

    _typewriterTimer?.cancel();
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charCount < _fullText.length) {
        setState(() {
          _charCount++;
        });
      } else {
        timer.cancel();
      }
    });

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_fetchProgress < 1.0) {
        setState(() {
          _fetchProgress += 0.025;
          if (_fetchProgress > 1.0) _fetchProgress = 1.0;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  String get _currentFetchStatus {
    if (_fetchProgress < 0.4) {
      return 'Fetching bank accounts';
    } else if (_fetchProgress < 0.75) {
      return 'Fetching mutual funds';
    } else if (_fetchProgress < 1.0) {
      return 'Fetching stocks & investments';
    } else {
      return 'All assets synced & updated';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedText = _fullText.substring(0, _charCount);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Column(
          children: [
            // DEZERV Custom Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DEZERV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Row(
                    children: [
                      // Simulate No Internet disconnect button for easy verification
                      IconButton(
                        icon: const Icon(Icons.wifi_off_rounded, color: Color(0xFFEF4444), size: 20),
                        tooltip: 'Simulate No Internet Disconnection',
                        onPressed: () => context.push('/no-internet', extra: '/'),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2D3748)),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFFE2E8F0),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Body Content
            Expanded(
              child: _selectedTab == 0
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fetching / Typewriter Onboarding Banner (Images 5 & 6)
                          const Text(
                            'Thanks for attaching your assets.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Typewriter message
                          MinHeightContainer(
                            minHeight: 48,
                            child: Text(
                              displayedText,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Fetching progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _fetchProgress,
                              backgroundColor: const Color(0xFF1E2433),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentFetchStatus,
                            style: TextStyle(
                              color: _fetchProgress >= 1.0
                                  ? const Color(0xFF0D9488)
                                  : const Color(0xFFE2E8F0),
                              fontSize: 15,
                              fontWeight: _fetchProgress >= 1.0 ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Dashboard Main Content
                          Text(
                            'System Telemetry & Metrics',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Live overview of application health, active revenue, and orders.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const StatsSummaryWidget(),
                          const SizedBox(height: 32),
                          Text(
                            'Feature Modules',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Quick navigation to core architecture modules.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth > 800
                                  ? 3
                                  : (constraints.maxWidth > 500 ? 2 : 1);
                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.4,
                                children: [
                                  FeatureCard(
                                    title: 'Settings & Preferences',
                                    subtitle:
                                        'Configure theme modes, account profile, and preferences.',
                                    icon: Icons.settings_rounded,
                                    gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                    onTap: () => context.go('/settings'),
                                  ),
                                  FeatureCard(
                                    title: 'User Analytics',
                                    subtitle:
                                        'Detailed retention graphs, cohorts, and funnel conversions.',
                                    icon: Icons.insights_rounded,
                                    gradientColors: const [Color(0xFF0D9488), Color(0xFF14B8A6)],
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Analytics module coming in v1.1')),
                                      );
                                    },
                                  ),
                                  FeatureCard(
                                    title: 'API Gateway Logs',
                                    subtitle:
                                        'Real-time HTTP request inspecting and latency monitoring.',
                                    icon: Icons.api_rounded,
                                    gradientColors: const [Color(0xFFF43F5E), Color(0xFFE11D48)],
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Gateway Logs module coming in v1.1')),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedTab == 1
                                ? Icons.pie_chart_outline_rounded
                                : (_selectedTab == 2 ? Icons.trending_up_rounded : Icons.shield_outlined),
                            size: 64,
                            color: const Color(0xFF475569),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedTab == 1
                                ? 'Portfolio Management'
                                : (_selectedTab == 2 ? 'Investment Opportunities' : 'Insurance & Protection'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This section is synced with your attached assets.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar (Image 6)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B0F19),
          border: Border(top: BorderSide(color: Color(0xFF1E2433), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0B0F19),
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedTab,
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (index) => setState(() => _selectedTab = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_rounded),
              label: 'Portfolio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded),
              label: 'Invest',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              label: 'Insurance',
            ),
          ],
        ),
      ),
    );
  }
}

class MinHeightContainer extends StatelessWidget {
  const MinHeightContainer({super.key, required this.minHeight, required this.child});
  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      alignment: Alignment.topLeft,
      child: child,
    );
  }
}
