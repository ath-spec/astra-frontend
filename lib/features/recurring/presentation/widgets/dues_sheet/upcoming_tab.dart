import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/extensions/string_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/recurring_control/pause_autopay_bottom_sheet.dart';
import 'package:astra_frontend/features/recurring/presentation/screens/manage_autopay_screen.dart';

class UpcomingTab extends StatefulWidget {
  final DateTime currentMonth;
  final List<Map<String, dynamic>> payments;
  final Function(String) onPaymentCancelled;
  final ScrollController? scrollController;

  const UpcomingTab({
    super.key,
    required this.currentMonth,
    required this.payments,
    required this.onPaymentCancelled,
    this.scrollController,
  });

  @override
  State<UpcomingTab> createState() => _UpcomingTabStateNew();
}

class _UpcomingTabStateNew extends State<UpcomingTab> {
  // We'll use local toggle states for now, but in a real app this would be in the model
  final Map<String, bool> _toggleStates = {};

  bool _isEnabled(String id) => _toggleStates[id] ?? true;

  void _handleToggle(int index, bool newValue) async {
    final item = widget.payments[index];
    if (!newValue) {
      final result = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: "pause auto-pay",
        barrierColor: Colors.black.withOpacity(0.05),
        pageBuilder: (context, anim1, anim2) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: PauseAutoPayBottomSheet(payment: item),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(anim1),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );

      if (mounted) {
        setState(() {
          _toggleStates[item['id']] = result == true ? false : true;
        });
      }
    } else {
      setState(() {
        _toggleStates[item['id']] = true;
      });
    }
  }

  void _handleManage(int index) async {
    final item = widget.payments[index];
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageAutopayScreen(payment: item),
      ),
    );

    if (mounted) {
      if (result == 'cancelled') {
        widget.onPaymentCancelled(item['id']);
      } else if (result == 'paused') {
        setState(() {
          _toggleStates[item['id']] = false;
        });
      }
    }
  }

  static const List<String> _months = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun',
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
  ];

  String _getNextRenewalText(Map<String, dynamic> item) {
    final status = item['status']?.toString().toLowerCase();
    if (status == 'paused') return "paused";
    if (status == 'cancelled') return "cancelled";
    
    final day = item['day'] ?? 21;
    final int monthIndex = (item['type'] == 'Yearly' && item['month'] != null)
        ? (item['month'] - 1)
        : (widget.currentMonth.month - 1);
    
    return "renews ${_months[monthIndex]} $day";
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: widget.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(20),
        vertical: getProportionateScreenHeight(16),
      ),
      itemCount: widget.payments.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: getProportionateScreenHeight(20)),
      itemBuilder: (context, index) {
        final item = widget.payments[index];
        return ZeyroTapDetector(eventName: 'upcoming_tab_manage_tapped', 
          onTap: () => _handleManage(index),
          child: _buildUpcomingItem(index, item),
        );
      },
    );
  }

  Widget _buildUpcomingItem(int index, Map<String, dynamic> item) {
    final bool isEnabled = _isEnabled(item['id']);

    return Container(
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo Container
          SizedBox(
            width: getProportionateScreenWidth(68),
            height: getProportionateScreenWidth(68),
            child: Center(
              child: (item['icon'] != null)
                  ? Icon(
                      item['icon'] as IconData,
                      size: getProportionateScreenWidth(26),
                      color: (item['isDark'] ?? true) ? Colors.white : Colors.black,
                    )
                  : Container(
                      padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                      child: SvgPicture.asset(
                        item['logoAsset'],
                        colorFilter: null,
                      ),
                    ),
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(16)),

          // Info and Status Pill
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(2)),
                Text(
                  _getNextRenewalText(item),
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(12),
                    color: Colors.black.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(8)),
                
                // Status Pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(12),
                    vertical: getProportionateScreenHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: isEnabled 
                        ? const Color(0xFFE2F0D9) // Light green for active
                        : const Color(0xFFFFF2CD), // Light yellow for canceled/paused
                    borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
                  ),
                  child: Text(
                    isEnabled ? "active" : "cancelled",
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: getProportionateScreenWidth(10),
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? const Color(0xFF548235) : const Color(0xFFBF9000),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Price and Per Month
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${item['amount'].toInt()}",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(18),
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? Colors.black : Colors.black.withOpacity(0.3),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                (item['name']?.toString().toLowerCase() == 'canva' || item['isYearly'] == true
                        ? "per year"
                        : "per month")
                    .toCapitalized(),
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(10),
                  color: Colors.black.withOpacity(0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(8)),
              // Hidden Toggle (functionality preserved)
              Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  value: isEnabled,
                  activeTrackColor: const Color(0xFF34C759),
                  onChanged: (val) => _handleToggle(index, val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
