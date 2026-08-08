
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/extensions/string_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/pause_autopay_bottom_sheet.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/upi_pin_bottom_sheet.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/cancel_success_bottom_sheet.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/resume_autopay_bottom_sheet.dart';
import 'package:astra_frontend/features/recurring/presentation/screens/recurring_history_screen.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class ManageAutopayScreen extends StatefulWidget {
  final Map<String, dynamic> payment;

  const ManageAutopayScreen({super.key, required this.payment});

  @override
  State<ManageAutopayScreen> createState() => _ManageAutopayScreenState();
}

class _ManageAutopayScreenState extends State<ManageAutopayScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _remindMe = true;
  final bool _scrollEnabled = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('manage_autopay_screen');
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final String status = widget.payment['status']?.toString().toLowerCase() ?? 'active';
    final bool isActive = status != 'cancelled' && status != 'paused';
    final double topPadding = MediaQuery.paddingOf(context).top;
    
    // Animation thresholds for sticky header title fade
    final double titleFadeStart = getProportionateScreenHeight(40);
    final double titleFadeEnd = getProportionateScreenHeight(100);
    final double opacity = ((_scrollOffset - titleFadeStart) / (titleFadeEnd - titleFadeStart)).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Material(
        color: Colors.white,
        child: Stack(
          children: [
            // Scrollable Content
            Positioned.fill(
              child: CustomScrollView(
                controller: _scrollController,
                physics: _scrollEnabled ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      getProportionateScreenWidth(20),
                      topPadding + getProportionateScreenHeight(80), 
                      getProportionateScreenWidth(20),
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildServiceHero(_scrollOffset),
                        SizedBox(height: getProportionateScreenHeight(16)),
                        _buildDetailsCard(),
                        SizedBox(height: getProportionateScreenHeight(16)),
                        _buildHistoryCard(),
                        SizedBox(height: getProportionateScreenHeight(8)),
                        _buildSettingsSection(),
                      ]),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          getProportionateScreenWidth(20),
                          getProportionateScreenHeight(80), // Increased gap above buttons
                          getProportionateScreenWidth(20),
                          getProportionateScreenHeight(8), // Reduced bottom padding
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildActionButtons(context, isActive),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                
              ),
            ),
  
            // Pinned Header
            _buildHeader(context, topPadding, opacity),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding, double opacity) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: opacity * 10, sigmaY: opacity * 10),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              getProportionateScreenWidth(16),
              topPadding + getProportionateScreenHeight(10),
              getProportionateScreenWidth(16),
              getProportionateScreenHeight(12),
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: opacity * 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () { Navigator.pop(context); },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: getProportionateScreenWidth(38),
                    height: getProportionateScreenWidth(38),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Opacity(
                    opacity: opacity,
                    child: Center(
                      child: Text(
                        (widget.payment['name'] as String).toCapitalized(),
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: getProportionateScreenWidth(16),
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(38)), // Balance for centering
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHero(double scrollOffset) {
    final String status = widget.payment['status']?.toString().toLowerCase() ?? 'active';
    final bool isCanceled = status == 'cancelled';
    final double heroOpacity = (1.0 - (scrollOffset / 100.0)).clamp(0.0, 1.0);

    return Opacity(
      opacity: heroOpacity,
      child: Transform.translate(
        offset: Offset(0, -scrollOffset * 0.2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: getProportionateScreenWidth(68),
              height: getProportionateScreenWidth(68),
              child: Center(
                child: (widget.payment['logoAsset'] != null)
                        ? SvgPicture.asset(
                            widget.payment['logoAsset'],
                            width: getProportionateScreenWidth(28),
                            height: getProportionateScreenWidth(28),
                            colorFilter: null,
                          )
                        : Icon(
                            widget.payment['icon'] as IconData? ?? Icons.subscriptions_rounded,
                            size: getProportionateScreenWidth(28),
                            color: (widget.payment['isDark'] ?? true) ? Colors.white : Colors.black,
                          ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (widget.payment['name'] as String).toCapitalized(),
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: getProportionateScreenWidth(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(10),
                      vertical: getProportionateScreenHeight(2),
                    ),
                    decoration: BoxDecoration(
                      color: !isCanceled 
                          ? const Color(0xFFDFF0D8) 
                          : const Color(0xFFF2E7D5),
                      borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
                    ),
                    child: Text(
                      (!isCanceled ? "active" : "cancelled").toCapitalized(),
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(9),
                        fontWeight: FontWeight.w600,
                        color: !isCanceled ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${widget.payment['amount'].toInt()}",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  (widget.payment['name']?.toString().toLowerCase() == 'canva' || widget.payment['isYearly'] == true
                          ? "per year"
                          : "per month")
                      .toCapitalized(),
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(10),
                    color: Colors.black.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
        border: Border.all(color: const Color.fromARGB(255, 206, 206, 205)),
      ),
      child: Column(
        children: [
          _buildDetailItem("Payment method", "•••• 8218", Icons.credit_card_rounded),
          _buildDivider(),
          _buildDetailItem("Current plan", "Premium family", Icons.keyboard_arrow_down_rounded),
          _buildDivider(),
          _buildDetailItem("Next billing", "Mar 7, 2026", Icons.calendar_today_rounded),
          SizedBox(height: getProportionateScreenHeight(16)),
          Row(
            children: [
              Expanded(child: _buildSecondaryButton("Manage plan", () {})),
              SizedBox(width: getProportionateScreenWidth(10)),
              Expanded(child: _buildSecondaryButton("Change payment", () {})),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(10), color: Colors.black.withValues(alpha: 0.4), fontWeight: FontWeight.w500)),
              SizedBox(height: getProportionateScreenHeight(3)),
              Text(value, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(12), fontWeight: FontWeight.w600, color: Colors.black)),
            ],
          ),
          Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(6)),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 255, 255, 255), borderRadius: BorderRadius.circular(4)),
            child: Icon(icon, size: 14, color: Colors.black.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.black.withValues(alpha: 0.05));

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return ZeyroTapDetector(eventName: 'manage_autopay_screen_action_tapped', 
      onTap: onTap,
      child: Container(
        height: getProportionateScreenHeight(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)), border: Border.all(color: const Color.fromARGB(255, 206, 206, 205))),
        child: Text(text, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(12), fontWeight: FontWeight.w600, color: Colors.black)),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return ZeyroTapDetector(eventName: 'manage_autopay_screen_history_tapped', 
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                RecurringHistoryScreen(payment: widget.payment),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutExpo;
              var tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));
              return SlideTransition(
                  position: animation.drive(tween), child: child);
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(0), vertical: getProportionateScreenHeight(16)),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment history",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(11),
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSettingRow("Category", "Entertainment"),
        SizedBox(height: getProportionateScreenHeight(16)),
        _buildSettingRow("Remind me", "", hasSwitch: true),
      ],
    );
  }

  Widget _buildSettingRow(String label, String value, {bool hasSwitch = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(12),
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        if (hasSwitch)
          ZeyroTapDetector(eventName: 'manage_autopay_screen_switch_tapped', 
            onTap: () {
              setState(() {
                _remindMe = !_remindMe;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: getProportionateScreenWidth(28),
              height: getProportionateScreenHeight(14),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _remindMe ? Colors.black : const Color.fromARGB(255, 230, 230, 230),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _remindMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: getProportionateScreenWidth(10),
                  height: getProportionateScreenWidth(10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        else
          Text(value,
              style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(12),
                  color: Colors.black.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isActive) {
    final String status = widget.payment['status']?.toString().toLowerCase() ?? 'active';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive) ...[
            ZeyroTapDetector(eventName: 'manage_autopay_screen_pause_tapped', 
              onTap: () => _handlePauseInitiation(context),
              child: Container(
                width: double.infinity,
                height: 56, // Exact height from budget intro
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0B1A), // Exact color from budget intro
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Pause",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(12)),
            ZeyroTapDetector(eventName: 'manage_autopay_screen_cancel_tapped', 
              onTap: () => _handleCancelInitiation(context),
              child: Container(
                width: double.infinity,
                height: 56, // Exact height from budget intro
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(4),
                  // No border as per budget intro's OutlinedButton style
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ] else ...[
            ZeyroTapDetector(eventName: 'manage_autopay_screen_resume_tapped', 
              onTap: () => _handleResumeInitiation(context),
              child: Container(
                width: double.infinity,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0B1A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (status == 'paused'
                          ? "resume subscription"
                          : "renew subscription")
                      .toCapitalized(),
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handlePauseInitiation(BuildContext context) async {
    final result = await showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "pause",
      barrierColor: Colors.black.withValues(alpha: 0.05),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: PauseAutoPayBottomSheet(payment: widget.payment),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(anim1),
          child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
    if (result != null && context.mounted) {
      Navigator.of(context).pop({'status': 'paused', 'pauseUntil': result});
    }
  }

  void _handleResumeInitiation(BuildContext context) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "resume",
      barrierColor: Colors.black.withValues(alpha: 0.05),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ResumeAutoPayBottomSheet(payment: widget.payment),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(anim1),
          child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
    if (result == true && context.mounted) {
      Navigator.of(context).pop('resumed');
    }
  }

  void _handleCancelInitiation(BuildContext context) async {
    final pinSuccess = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: "pin",
        barrierColor: Colors.black.withValues(alpha: 0.05),
        pageBuilder: (context, anim1, anim2) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: UpiPinBottomSheet(payment: widget.payment))),
        transitionBuilder: (context, anim1, anim2, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(anim1),
            child: child),
        transitionDuration: const Duration(milliseconds: 300));
    if (pinSuccess == true && context.mounted) {
      final finalResult = await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierLabel: "success",
          barrierColor: Colors.black.withValues(alpha: 0.05),
          pageBuilder: (context, anim1, anim2) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: const CancelSuccessBottomSheet())),
          transitionBuilder: (context, anim1, anim2, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(anim1),
              child: child),
          transitionDuration: const Duration(milliseconds: 300));
      if (finalResult == true && context.mounted) {
        Navigator.of(context).pop('cancelled');
      }
    }
  }
}
