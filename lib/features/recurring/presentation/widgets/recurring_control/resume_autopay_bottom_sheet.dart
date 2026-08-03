
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/extensions/string_extensions.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';

class ResumeAutoPayBottomSheet extends StatefulWidget {
  final Map<String, dynamic> payment;

  const ResumeAutoPayBottomSheet({super.key, required this.payment});

  @override
  State<ResumeAutoPayBottomSheet> createState() => _ResumeAutoPayBottomSheetState();
}

class _ResumeAutoPayBottomSheetState extends State<ResumeAutoPayBottomSheet> {
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
            topLeft: Radius.circular(getProportionateScreenWidth(4)),
            topRight: Radius.circular(getProportionateScreenWidth(4)),
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
                    "Are you sure about resuming\nyour auto-pay",
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: getProportionateScreenWidth(20),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(24)),
                  _buildInfoItem(
                    Icons.check_circle_outline_rounded,
                    "Service will be continued",
                    "You'll have unDMSansrupted access to the service",
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  _buildInfoItem(
                    Icons.auto_mode_rounded,
                    "Automatic payments will resume",
                    "Payments will be deducted as per your plan",
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: getProportionateScreenWidth(40),
            height: getProportionateScreenHeight(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
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
            borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
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
                (widget.payment['name'] as String).toCapitalized(),
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(15),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                "Amount to be paid is rs ${widget.payment['amount'].toint()}",
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

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
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
        ZeyroTapDetector(eventName: 'resume_autopay_bottom_sheet_confirm_tapped', 
          onTap: () => Navigator.pop(context, true),
          child: Container(
            width: double.infinity,
            height: getProportionateScreenHeight(48),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(getProportionateScreenWidth(4))),
            child: Text("Resume auto-pay", style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(14), fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.none)),
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(12)),
        GestureDetector(
onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: getProportionateScreenHeight(48),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFFFFDF1), borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)), border: Border.all(color: const Color(0xFFECEBDB))),
            child: Text("Don't resume", style: TextStyle(fontFamily: 'DMSans', fontSize: getProportionateScreenWidth(14), fontWeight: FontWeight.w600, color: Colors.black, decoration: TextDecoration.none)),
          ),
        ),
      ],
    );
  }
}
