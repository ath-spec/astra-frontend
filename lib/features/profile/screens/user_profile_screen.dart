import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // Start animation automatically
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetState = ref.watch(assetConnectionProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF9FAFB),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Stack(
          children: [

            
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  // App Bar / Top Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          _AnimatedPressButton(
                            onPressed: () => context.pop(),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: Colors.transparent, // Ensures the entire 48x48 area is tappable
                              alignment: Alignment.centerLeft, // Keep icon aligned
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Avatar & Title
                  SliverToBoxAdapter(
                    child: _StaggeredItem(
                      controller: _staggerController,
                      index: 0,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // Avatar
                          _SpinnableAvatar(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  width: 2,
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFF5BA1F7),
                                    Color(0xFF031E6B),
                                    Color(0xFF241714),
                                  ],
                                  stops: [0.0, 0.45, 0.8, 1.0],
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'PP',
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Portfolio Primary',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // KYC Card
                  SliverToBoxAdapter(
                    child: _StaggeredItem(
                      controller: _staggerController,
                      index: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your KYC is pending',
                                      style: TextStyle(
                                        fontFamily: 'SpaceGrotesk',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Complete your KYC to start investing in Mutual Funds.',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 10,
                                        color: Color(0xFF64748B),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _AnimatedPressButton(
                                      onPressed: () {},
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E1E1E),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text(
                                              'Complete KYC',
                                              style: TextStyle(
                                                fontFamily: 'DMSans',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.grey.shade100,
                                      Colors.grey.shade50,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.hourglass_empty_rounded,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Menu Items
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMenuItem(
                        index: 2,
                        icon: Icons.person_outline_rounded,
                        title: 'Account Details',
                      ),
                      _buildMenuItem(
                        index: 3,
                        icon: Icons.person_add_alt_1_outlined,
                        title: 'Nominee List',
                      ),
                      _buildMenuItem(
                        index: 4,
                        icon: Icons.settings_outlined,
                        title: 'Manage AA accounts',
                        onTap: () {
                          if (assetState.banksConnected) {
                            context.push('/manage-bank-accounts');
                          } else {
                            context.push('/banks-linking');
                          }
                        },
                      ),
                      _buildMenuItem(
                        index: 5,
                        icon: Icons.account_balance_outlined,
                        title: 'Bank & Mandate',
                      ),
                      _buildMenuItem(
                        index: 6,
                        icon: Icons.analytics_outlined,
                        title: 'Mutual Funds Reports',
                      ),
                      _buildMenuItem(
                        index: 7,
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Help & Support',
                      ),
                      _buildMenuItem(
                        index: 8,
                        icon: Icons.info_outline_rounded,
                        title: 'About Astra',
                      ),
                      _buildMenuItem(
                        index: 9,
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        isLast: true,
                        onTap: () {
                          ref.read(authProvider.notifier).logout();
                          context.go('/intro');
                        },
                      ),
                    ]),
                  ),
                  
                  // Bottom spacing
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 40,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String title,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return _StaggeredItem(
      controller: _staggerController,
      index: index,
      child: _AnimatedPressButton(
        onPressed: onTap ?? () {},
        child: Container(
          color: Colors.transparent, // Ensure tap area is full width
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: const Color.fromARGB(255, 0, 0, 0)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const _DashedDivider(),
            ],
          ),
        ),
      ),
    );
  }
}

/// A simple dashed divider.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Button wrapper that provides physical scale down feedback on press.
class _AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _AnimatedPressButton({
    required this.child,
    required this.onPressed,
  });

  @override
  State<_AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<_AnimatedPressButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: const Cubic(0.23, 1, 0.32, 1),
        child: widget.child,
      ),
    );
  }
}

/// Helper to coordinate a staggered entrance animation.
class _StaggeredItem extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _StaggeredItem({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.03;
    final start = (0.0 + delay).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);

    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    final transform = Tween<Offset>(
      begin: const Offset(0, 0.2), // start slightly below
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: const Cubic(0.23, 1, 0.32, 1)),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: opacity.value,
          child: FractionalTranslation(
            translation: transform.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A highly tactile, spinnable widget with physics-based inertia.
class _SpinnableAvatar extends StatefulWidget {
  final Widget child;

  const _SpinnableAvatar({required this.child});

  @override
  State<_SpinnableAvatar> createState() => _SpinnableAvatarState();
}

class _SpinnableAvatarState extends State<_SpinnableAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = 0.0;
  Offset? _lastPosition;
  DateTime? _lastTime;
  double _angularVelocity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(() {
      setState(() {
        _angle = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _lastPosition = details.localPosition;
    _lastTime = DateTime.now();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);

    final position = details.localPosition;
    final prevPosition = _lastPosition ?? (position - details.delta);
    final time = DateTime.now();
    final prevTime = _lastTime ?? time.subtract(const Duration(milliseconds: 16));

    final angle1 = math.atan2(prevPosition.dy - center.dy, prevPosition.dx - center.dx);
    final angle2 = math.atan2(position.dy - center.dy, position.dx - center.dx);

    var deltaAngle = angle2 - angle1;
    // Handle wrap-around
    if (deltaAngle > math.pi) {
      deltaAngle -= 2 * math.pi;
    } else if (deltaAngle < -math.pi) {
      deltaAngle += 2 * math.pi;
    }

    final dt = time.difference(prevTime).inMicroseconds / 1000000.0;
    if (dt > 0) {
      // Multiply by 2.5 to make it feel more sensitive/intense to flings
      _angularVelocity = (deltaAngle / dt) * 2.5;
    }

    setState(() {
      _angle += deltaAngle;
    });

    _lastPosition = position;
    _lastTime = time;
  }

  void _onPanEnd(DragEndDetails details) {
    // Add physics simulation for inertia
    if (_angularVelocity.abs() > 0.05) {
      final simulation = FrictionSimulation(
        0.005, // Basically zero friction - spins forever
        _angle, // Initial position
        _angularVelocity, // Initial velocity
      );
      _controller.animateWith(simulation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.rotate(
        angle: _angle,
        child: widget.child,
      ),
    );
  }
}

