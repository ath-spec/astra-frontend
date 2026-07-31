import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/pause_date_selection_bottom_sheet.dart';

class PauseAutoPayBottomSheet extends StatefulWidget {
  final Map<String, dynamic> payment;

  const PauseAutoPayBottomSheet({super.key, required this.payment});

  @override
  State<PauseAutoPayBottomSheet> createState() => _PauseAutoPayBottomSheetState();
}

class _PauseAutoPayBottomSheetState extends State<PauseAutoPayBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8E7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(getProportionateScreenWidth(28)),
            topRight: Radius.circular(getProportionateScreenWidth(28)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
                children: [
                  SizedBox(height: getProportionateScreenHeight(8)),
                  _buildServiceHero(),
                  SizedBox(height: getProportionateScreenHeight(32)),
                  Text(
                    "Are you sure about pausing\nyour auto-pay",
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: getProportionateScreenWidth(20),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(24)),
                  _buildWarningItem(
                    Icons.block_flipped,
                    "Service will be discontinued",
                    "You'll no longer have access to the service",
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  _buildWarningItem(
                    Icons.currency_rupee_rounded,
                    "Manual payments might be needed",
                    "To access the services you enjoy",
                  ),
                  SizedBox(height: getProportionateScreenHeight(40)),
                  _buildActionButtons(context),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        getProportionateScreenWidth(20),
        getProportionateScreenHeight(16),
        getProportionateScreenWidth(20),
        getProportionateScreenHeight(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the title
        children: [
          // Drag Handle / Indicator instead of back button
          Container(
            width: getProportionateScreenWidth(40),
            height: getProportionateScreenHeight(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHero() {
    final Color bgColor = widget.payment['backgroundColor'] as Color;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: getProportionateScreenWidth(48),
          height: getProportionateScreenWidth(48),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
          ),
          child: Center(
            child: widget.payment['name'] == 'Netflix'
                ? Text('N', style: TextStyle(fontFamily: 'BebasNeue', color: Colors.white, fontSize: getProportionateScreenWidth(24), decoration: TextDecoration.none))
                : Icon(widget.payment['icon'] as IconData? ?? Icons.subscriptions_rounded, size: getProportionateScreenWidth(24), color: Colors.white),
          ),
        ),
        SizedBox(width: getProportionateScreenWidth(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (widget.payment['name'] as String).toLowerCase(),
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(15),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                "Amount to be paid now is rs ${widget.payment['amount'].toint()}",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(11),
                  color: Colors.black.withOpacity(0.4),
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarningItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(getProportionateScreenWidth(8)),
          decoration: BoxDecoration(color: const Color(0xFFFFFDF1), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFECEBDB))),
          child: Icon(icon, size: 16, color: Colors.black87),
        ),
        SizedBox(width: getProportionateScreenWidth(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(14), fontWeight: FontWeight.w600, color: Colors.black, decoration: TextDecoration.none)),
              Text(subtitle, style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(12), color: Colors.black54, decoration: TextDecoration.none, fontWeight: FontWeight.normal)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ZeyroTapDetector(eventName: 'pause_autopay_bottom_sheet_select_date_tapped', 
          onTap: () => _showDateSelection(context),
          child: Container(
            width: double.infinity,
            height: getProportionateScreenHeight(48),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(getProportionateScreenWidth(15))),
            child: Text("Pause auto-pay", style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(14), fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.none)),
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(12)),
        GestureDetector(
onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: getProportionateScreenHeight(48),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFFFFDF1), borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)), border: Border.all(color: const Color(0xFFECEBDB))),
            child: Text("Don't pause auto-pay", style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(14), fontWeight: FontWeight.w600, color: Colors.black, decoration: TextDecoration.none)),
          ),
        ),
      ],
    );
  }

  void _showDateSelection(BuildContext context) async {
    final result = await showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "date",
      barrierColor: Colors.black.withOpacity(0.05),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: PauseDateSelectionBottomSheet(payment: widget.payment),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) => SlideTransition(position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(anim1), child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );

    if (result != null && context.mounted) {
      Navigator.pop(context, result);
    }
  }
}
