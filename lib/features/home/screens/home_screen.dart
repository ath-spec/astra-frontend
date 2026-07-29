import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/arch_background.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';

/// Screen 4: New Home Screen / Dashboard (Image 4) in clean light mode.
/// Displays user wealth header, portfolio chart card, asset status list (with FETCHING status),
/// and floating pill bottom navigation bar.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetState = ref.watch(assetConnectionProvider);

    // Only run the pulse animation if we are actually linking
    if (assetState.step == AssetConnectionStep.banksLinkingProgress) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      if (_pulseController.isAnimating) _pulseController.stop();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Subtle 3D Architectural Dome Background Graphic
          const ArchBackground(height: 420),

          // Main Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SizedBox.expand(
                child: Column(
                  children: [
                    // Top App Bar
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        24.0, 
                        MediaQuery.of(context).padding.top + 12.0, 
                        24.0, 
                        12.0
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Profile Button
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile settings coming soon'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFF0F172A),
                                size: 22,
                              ),
                            ),
                          ),
                          // Lock / Security Button
                          GestureDetector(
                            onTap: () => context.push('/no-internet', extra: '/'),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: Color(0xFF0F172A),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Dashboard Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 24.0,
                          right: 24.0,
                          bottom: MediaQuery.of(context).padding.bottom + 100, // Space for nav pill and system nav
                        ),
                        child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Wealth Subtitle
                        const Text(
                          "ABHIMANYU'S WEALTH",
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Amount & Refresh Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '₹ • • • •',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                color: Color(0xFF0F172A),
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Refreshing portfolio summary...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                    width: 1.2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Main Chart Card
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Subtle background grid lines
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(3, (i) {
                                  return Container(
                                    height: 1,
                                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                                  );
                                }),
                              ),
                              // Empty state placeholder
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.insights_rounded,
                                      size: 32,
                                      color: const Color(0xFFCBD5E1).withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Connect assets to generate insights',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Asset Connection List
                        _buildAssetRow(
                          icon: Icons.bar_chart_rounded,
                          title: 'Mutual Funds',
                          buttonText: 'Import',
                          onPressed: () => context.push('/mf-status'),
                        ),
                        _buildDottedDivider(),

                        _buildSurplusRow(),
                        _buildDottedDivider(),

                        _buildAssetRow(
                          icon: Icons.candlestick_chart_rounded,
                          title: 'Stocks',
                          buttonText: assetState.stocksConnected ? '2 Linked' : 'Import',
                          onPressed: () => context.push('/aa-stocks-otp'),
                          isLinked: assetState.stocksConnected,
                        ),
                        _buildDottedDivider(),

                        _buildBankAccountsRow(
                          isLinked: assetState.banksConnected,
                          isLinking: assetState.step == AssetConnectionStep.banksLinkingProgress,
                        ),
                        const SizedBox(height: 28),

                        // Bottom Insights Banner Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFF8FAFC),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Unlock portfolio insights',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  color: Color(0xFF0F172A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Connect funds, stocks and accounts to see\nyour holistic wealth summary',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12), // Removed extra padding for floating nav bar
                      ],
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildAssetRow({
    required IconData icon,
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
    bool isLinked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'DMSans',
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLinked ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              foregroundColor: isLinked ? const Color(0xFF0F172A) : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: isLinked
                    ? const BorderSide(color: Color(0xFFCBD5E1))
                    : BorderSide.none,
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurplusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF64748B), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Surplus',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    children: [
                      TextSpan(text: 'Earn '),
                      TextSpan(
                        text: '2.5x',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(text: ' on your idle money'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Surplus idle money management coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Explore',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountsRow({required bool isLinked, required bool isLinking}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: GestureDetector(
        onTap: () => context.push('/banks-linking'),
        child: Row(
          children: [
            const Icon(Icons.account_balance_rounded, color: Color(0xFF64748B), size: 24),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Bank Accounts',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isLinked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Text(
                  'Connected',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else if (isLinking)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: const Text(
                      '• • •',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FETCHING',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'Import',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDottedDivider() {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DottedLinePainter(),
    );
  }
}

/// Dotted horizontal line separator
class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    double startX = 0;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
