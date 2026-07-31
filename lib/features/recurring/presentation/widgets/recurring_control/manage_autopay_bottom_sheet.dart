import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/pause_autopay_bottom_sheet.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/upi_pin_bottom_sheet.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/cancel_success_bottom_sheet.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/resume_autopay_bottom_sheet.dart';

class ManageAutopayBottomSheet extends StatefulWidget {
  final Map<String, dynamic> payment;

  const ManageAutopayBottomSheet({super.key, required this.payment});

  @override
  State<ManageAutopayBottomSheet> createState() => _ManageAutopayBottomSheetState();
}

class _ManageAutopayBottomSheetState extends State<ManageAutopayBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _remindMe = true;

  @override
  void initState() {
    super.initState();
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
    final String status = widget.payment['status']?.toString().toLowerCase() ?? 'active';
    final bool isActive = status != 'cancelled' && status != 'paused';
    
    // Animation thresholds
    final double titleFadeStart = getProportionateScreenHeight(40);
    final double titleFadeEnd = getProportionateScreenHeight(100);
    final double opacity = ((_scrollOffset - titleFadeStart) / (titleFadeEnd - titleFadeStart)).clamp(0.0, 1.0);

    return Listener(
      onPointerMove: (event) {
        // If user pulls down (dy > 0) while at the top of the scroll
        if (event.delta.dy > 15 && _scrollOffset <= 0) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8E7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(getProportionateScreenWidth(28)),
            topRight: Radius.circular(getProportionateScreenWidth(28)),
          ),
        ),
        child: Stack(
          children: [
            // Scrollable Content
            Positioned.fill(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                getProportionateScreenWidth(20),
                getProportionateScreenHeight(70), // Reduced space since header is minimal
                getProportionateScreenWidth(20),
                getProportionateScreenHeight(40),
              ),
              children: [
                _buildServiceHero(_scrollOffset),
                SizedBox(height: getProportionateScreenHeight(16)),
                _buildDetailsCard(),
                SizedBox(height: getProportionateScreenHeight(16)),
                _buildHistoryCard(),
                SizedBox(height: getProportionateScreenHeight(20)),
                _buildSettingsSection(),
                SizedBox(height: getProportionateScreenHeight(24)),
                _buildActionButtons(context, isActive),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ],
            ),
          ),

          // Pinned Header (Minimalist Drag Handle)
          _buildPinnedHeader(context, opacity),
        ],
      ),
    ),
  );
}

  Widget _buildPinnedHeader(BuildContext context, double opacity) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: opacity * 10, sigmaY: opacity * 10),
          child: Container(
            height: getProportionateScreenHeight(76),
            padding: EdgeInsets.fromLTRB(
              getProportionateScreenWidth(20),
              getProportionateScreenHeight(16),
              getProportionateScreenWidth(20),
              0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8E7).withOpacity(opacity * 0.8),
            ),
            child: Column(
              children: [
                // Minimalist Drag Handle centered
                Center(
                  child: Container(
                    width: getProportionateScreenWidth(40),
                    height: getProportionateScreenHeight(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: Opacity(
                    opacity: opacity,
                    child: Center(
                      child: Text(
                        (widget.payment['name'] as String).toLowerCase(),
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: getProportionateScreenWidth(15),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHero(double scrollOffset) {
    final Color bgColor = widget.payment['backgroundColor'] as Color;
    final String status = widget.payment['status']?.toString().toLowerCase() ?? 'active';
    final bool isCanceled = status == 'cancelled';
    
    // Scale down hero based on scroll
    final double heroOpacity = (1.0 - (scrollOffset / 100.0)).clamp(0.0, 1.0);

    return Opacity(
      opacity: heroOpacity,
      child: Transform.translate(
        offset: Offset(0, -scrollOffset * 0.2), // Subtle parallax
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              width: getProportionateScreenWidth(56),
              height: getProportionateScreenWidth(56),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
              ),
              child: Center(
                child: widget.payment['name'] == 'Netflix'
                    ? Text(
                        'N',
                        style: TextStyle(fontFamily: 'BebasNeue', 
                          color: Colors.white,
                          fontSize: getProportionateScreenWidth(28),
                        ),
                      )
                    : Icon(
                        widget.payment['icon'] as IconData? ?? Icons.subscriptions_rounded,
                        size: getProportionateScreenWidth(28),
                        color: Colors.white,
                      ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (widget.payment['name'] as String).toLowerCase(),
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: getProportionateScreenWidth(16),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(2)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(10),
                      vertical: getProportionateScreenHeight(2),
                    ),
                    decoration: BoxDecoration(
                      color: !isCanceled 
                          ? const Color(0xFFDFF0D8) 
                          : const Color(0xFFF2E7D5),
                      borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
                    ),
                    child: Text(
                      (!isCanceled ? "active" : "cancelled").toLowerCase(),
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(9),
                        fontWeight: FontWeight.w600,
                        color: !isCanceled ? const Color(0xFF3C763D) : const Color(0xFF8A6D3B),
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
                  "Per month",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(10),
                    color: Colors.black.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
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
        color: const Color(0xFFFFFDF1),
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
        border: Border.all(color: const Color(0xFFECEBDB)),
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
              Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(10), color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w500)),
              SizedBox(height: getProportionateScreenHeight(3)),
              Text(value, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(13), fontWeight: FontWeight.w600, color: Colors.black)),
            ],
          ),
          Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(6)),
            decoration: BoxDecoration(color: const Color(0xFFFBF8E7), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 14, color: Colors.black.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.black.withOpacity(0.05));

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return ZeyroTapDetector(eventName: 'manage_autopay_bottom_sheet_action_tapped', 
      onTap: onTap,
      child: Container(
        height: getProportionateScreenHeight(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)), border: Border.all(color: const Color(0xFFECEBDB))),
        child: Text(text, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(12), fontWeight: FontWeight.w600, color: Colors.black)),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      decoration: BoxDecoration(color: const Color(0xFFFFFDF1), borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)), border: Border.all(color: const Color(0xFFECEBDB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Subscription history", style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(11), color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w600)),
          SizedBox(height: getProportionateScreenHeight(14)),
          _buildHistoryRow("Jan 7, 2026", "₹${widget.payment['amount'].toInt()}", "Paid", const Color(0xFFDFF0D8), const Color(0xFF3C763D)),
          _buildHistoryRow("Dec 7, 2025", "₹${widget.payment['amount'].toInt()}", "Paid", const Color(0xFFDFF0D8), const Color(0xFF3C763D)),
          _buildHistoryRow("Nov 7, 2025", "₹${widget.payment['amount'].toInt()}", "Paid", const Color(0xFFDFF0D8), const Color(0xFF3C763D)),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String date, String amount, String status, Color bgColor, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
      child: Row(
        children: [
          Expanded(child: Text(date, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(12), fontWeight: FontWeight.w600, color: Colors.black))),
          Text(amount, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(12), fontWeight: FontWeight.w600, color: Colors.black)),
          SizedBox(width: getProportionateScreenWidth(10)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(8), fontWeight: FontWeight.w600, color: textColor)),
          ),
        ],
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
        Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(14), fontWeight: FontWeight.w600, color: Colors.black)),
        if (hasSwitch)
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _remindMe,
              activeColor: Colors.black,
              onChanged: (val) {
                setState(() {
                  _remindMe = val;
                });
              },
            ),
          )
        else
          Text(value, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(12), color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isActive) {
    final String status = widget.payment['status']?.toString().toLowerCase() ?? 'active';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActive) ...[
          ZeyroTapDetector(eventName: 'manage_autopay_bottom_sheet_pause_tapped', 
            onTap: () => _handlePauseInitiation(context),
            child: Container(
              width: double.infinity,
              height: getProportionateScreenHeight(48),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: const Color(0xFFFFFDF1), borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)), border: Border.all(color: const Color(0xFFECEBDB))),
              child: Text("Pause subscription", style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(14), fontWeight: FontWeight.w600, color: Colors.black)),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(12)),
          ZeyroTapDetector(eventName: 'manage_autopay_bottom_sheet_cancel_tapped', 
            onTap: () => _handleCancelInitiation(context),
            child: Container(
              width: double.infinity,
              height: getProportionateScreenHeight(48),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(getProportionateScreenWidth(15))),
              child: Text("Cancel subscription", style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(14), fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ] else ...[
           ZeyroTapDetector(eventName: 'manage_autopay_bottom_sheet_resume_tapped', 
            onTap: () => _handleResumeInitiation(context),
            child: Container(
              width: double.infinity,
              height: getProportionateScreenHeight(48),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(getProportionateScreenWidth(15))),
              child: Text((status == 'paused' ? "resume subscription" : "renew subscription").toLowerCase(), style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(14), fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ],
    );
  }

  void _handlePauseInitiation(BuildContext context) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "pause",
      barrierColor: Colors.black.withOpacity(0.05),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: PauseAutoPayBottomSheet(payment: widget.payment),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) => SlideTransition(position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(anim1), child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
    if (result == true && context.mounted) Navigator.of(context).pop('paused');
  }

  void _handleResumeInitiation(BuildContext context) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "resume",
      barrierColor: Colors.black.withOpacity(0.05),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ResumeAutoPayBottomSheet(payment: widget.payment),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) => SlideTransition(position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(anim1), child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
    if (result == true && context.mounted) Navigator.of(context).pop('resumed');
  }

  void _handleCancelInitiation(BuildContext context) async {
    final pinSuccess = await showGeneralDialog<bool>(context: context, barrierDismissible: true, barrierLabel: "pin", barrierColor: Colors.black.withOpacity(0.05), pageBuilder: (context, anim1, anim2) => BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Align(alignment: Alignment.bottomCenter, child: UpiPinBottomSheet(payment: widget.payment))), transitionBuilder: (context, anim1, anim2, child) => SlideTransition(position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(anim1), child: child), transitionDuration: const Duration(milliseconds: 300));
    if (pinSuccess == true && context.mounted) {
      final finalResult = await showGeneralDialog<bool>(context: context, barrierDismissible: true, barrierLabel: "success", barrierColor: Colors.black.withOpacity(0.05), pageBuilder: (context, anim1, anim2) => BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Align(alignment: Alignment.bottomCenter, child: const CancelSuccessBottomSheet())), transitionBuilder: (context, anim1, anim2, child) => SlideTransition(position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(anim1), child: child), transitionDuration: const Duration(milliseconds: 300));
      if (finalResult == true && context.mounted) Navigator.of(context).pop('cancelled');
    }
  }
}
