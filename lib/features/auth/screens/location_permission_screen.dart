import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> with SingleTickerProviderStateMixin {
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

  void _submit() {
    context.push('/name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          'GRANT ACCESS',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'we need\npermissions for\nlocation.',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            letterSpacing: -1.0,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'WHY WE ASK',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildPermissionItem(
                          icon: Icons.balance,
                          title: 'regulatory compliance',
                          subtitle: 'WE\'RE REQUIRED TO CONFIRM YOUR COUNTRY TO FOLLOW INDIAN FINANCIAL REGULATIONS.',
                        ),
                        const SizedBox(height: 24),
                        _buildPermissionItem(
                          icon: Icons.shield_outlined,
                          title: 'account security',
                          subtitle: 'HELPS US DETECT UNUSUAL ACCESS AND PROTECT YOU FROM FRAUD.',
                        ),
                        const SizedBox(height: 24),
                        _buildPermissionItem(
                          icon: Icons.smart_toy_outlined, // Bot icon
                          title: 'prevent misuse',
                          subtitle: 'STOPS FAKE OR AUTOMATED ACCOUNTS FROM ABUSING THE SYSTEM.',
                        ),
                        const SizedBox(height: 24),
                        _buildPermissionItem(
                          icon: Icons.description_outlined,
                          title: 'for audit & compliance',
                          subtitle: 'USED TO MAINTAIN AUDIT RECORDS FOR REGULATORY COMPLIANCE.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: GestureDetector(
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _animationController.reverse(),
                    onTapCancel: () => _animationController.reverse(),
                    onTap: _submit,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
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
                              'CONTINUE',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({required IconData icon, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF4F46E5), // Indigo matching our theme
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  height: 1.4,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
