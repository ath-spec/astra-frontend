import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

/// Screen matching Image 3 for Account Aggregator Stocks status result.
/// Displays "No Demat found" (default) or "Demat accounts found" via demo toggle.
class AaStocksStatusScreen extends ConsumerStatefulWidget {
  const AaStocksStatusScreen({super.key});

  @override
  ConsumerState<AaStocksStatusScreen> createState() =>
      _AaStocksStatusScreenState();
}

class _AaStocksStatusScreenState extends ConsumerState<AaStocksStatusScreen>
    with SingleTickerProviderStateMixin {
  bool _hasDemat = false; // Default matching Image 3
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB)),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authProvider.notifier).pendingPhone;
    final displayPhone = phone.isEmpty ? '6291328703' : phone;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111827),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: TextButton.icon(
          onPressed: () => setState(() => _hasDemat = !_hasDemat),
          icon: Icon(
            _hasDemat ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
            color: const Color(0xFF031E6B),
            size: 24,
          ),
          label: Text(
            _hasDemat ? 'Demo: Demat Found' : 'Demo: No Demat Found',
            style: const TextStyle(
              fontFamily: 'DMSans',
              color: Color(0xFF031E6B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () => context.push('/connect-assets'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
              ),
              child: Container(
                padding: const EdgeInsets.only(bottom: 1),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF9CA3AF),
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Icon Badge matching Image 3
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _hasDemat
                                    ? const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.1)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _hasDemat
                                      ? const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.3)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _hasDemat
                                    ? Icons.account_balance_wallet_rounded
                                    : Icons.domain_disabled_rounded,
                                color: _hasDemat
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF6B7280),
                                size: 32,
                              ),
                            ),
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: _hasDemat
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF6B7280),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _hasDemat
                                      ? Icons.check_rounded
                                      : Icons.info_outline_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _hasDemat ? 'Demat accounts found!' : 'No Demat found',
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            height: 1.15,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _hasDemat
                              ? 'We found active Demat accounts linked to your mobile number +91 $displayPhone and PAN ••••370H.'
                              : "We couldn't find any Demat accounts associated with your mobile number +91 $displayPhone and PAN ••••370H.",
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildDashedDivider(),
                        const SizedBox(height: 32),
                        if (_hasDemat) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.show_chart_rounded,
                                    color: Color(0xFF10B981),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CDSL / NSDL Demat Account',
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'PAN ••••370H • Active Holding',
                                        style: TextStyle(
                                          fontFamily: 'DMMono',
                                          fontSize: 12,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: Color(0xFF031E6B),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Tip: You can manually link your broker or mutual funds on the next screen.',
                                    style: const TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 13,
                                      color: Color(0xFF4B5563),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 48),
                        // CONTINUE TO ASSETS Button
                        GestureDetector(
                          onTapDown: (_) => _animationController.forward(),
                          onTapUp: (_) => _animationController.reverse(),
                          onTapCancel: () => _animationController.reverse(),
                          onTap: () => context.push('/connect-assets'),
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFF5BA1F7),
                                    Color(0xFF031E6B),
                                    Color(0xFF241714),
                                  ],
                                  stops: [0.0, 0.25, 0.7, 1.0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    'CONTINUE TO ASSETS',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Positioned(
                                    right: 20,
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Footer
                        Center(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'powered by RBI-regulated account aggregator ',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.change_history_rounded,
                                        color: const Color(0xFF1E3A8A),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      const Text(
                                        'FINVU',
                                        style: TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E3A8A),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.security_rounded,
                                    color: Color(0xFF10B981),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'trusted by 3 crore citizens',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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
}
