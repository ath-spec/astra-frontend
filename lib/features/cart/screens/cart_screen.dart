import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isExplorePressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(left: 24.w, top: 16.h, right: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44.w,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: const Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Cart',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),

            // Empty State
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF8FAFC),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child: Image.asset(
                            'lib/core/images/empty_cart.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      
                      // Texts
                      Text(
                        'Your cart is empty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Funds you add to your cart will show up\nhere, ready to invest.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Explore Button
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isExplorePressed = true),
                        onTapUp: (_) {
                          setState(() => _isExplorePressed = false);
                          // Navigate to funds or just pop for now
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/stocks');
                          }
                        },
                        onTapCancel: () => setState(() => _isExplorePressed = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          curve: const Cubic(0.23, 1, 0.32, 1),
                          transform: Matrix4.identity()..scale(_isExplorePressed ? 0.97 : 1.0),
                          transformAlignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF334155), Color(0xFF0F172A)],
                            ),
                            borderRadius: BorderRadius.circular(32.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'EXPLORE ALL FUNDS',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(width: 8.w),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
