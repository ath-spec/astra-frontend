import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/extensions/string_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/presentation/screens/manage_autopay_screen.dart';

class SubscriptionTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(String, String, {DateTime? pauseUntil}) onStatusChanged;

  const SubscriptionTile({
    super.key,
    required this.item,
    required this.onStatusChanged,
  });

  void _handleManage(BuildContext context) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => ManageAutopayScreen(payment: item),
      ),
    );

    if (result == 'cancelled') {
      onStatusChanged(item['id'], 'cancelled');
    } else if (result is Map && result['status'] == 'paused') {
      onStatusChanged(
        item['id'],
        'paused',
        pauseUntil: result['pauseUntil'] as DateTime?,
      );
    } else if (result == 'paused') {
      onStatusChanged(item['id'], 'paused');
    } else if (result == 'resumed') {
      onStatusChanged(item['id'], 'active');
    }
  }

  static const List<String> _months = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun',
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
  ];

  String _getSubtitle() {
    final status = (item['status']?.toString().toLowerCase() ?? 'active');
    if (status == 'paused') {
      if (item['pauseUntil'] != null) {
        return "paused until ${_formatDate(item['pauseUntil'])}";
      }
      return "paused until next month";
    }

    final day = item['day'] ?? 21;
    final int monthIndex = (item['type'] == 'Yearly' && item['month'] != null)
        ? (item['month'] - 1)
        : (DateTime.now().month - 1);
    
    int targetMonth = monthIndex;
    if (item['type'] != 'Yearly' && DateTime.now().day > day) {
      targetMonth = (targetMonth + 1) % 12;
    }

    return "renews ${_months[targetMonth]} $day";
  }

  String _formatDate(DateTime date) {
    return "${_months[date.month - 1]} ${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    final status = (item['status']?.toString().toLowerCase() ?? 'active');
    final bool isEnabled = status == 'active';

    return ZeyroTapDetector(eventName: 'subscription_tile_manage_tapped', 
      onTap: () => _handleManage(context),
      child: Container(
        padding: EdgeInsets.all(getProportionateScreenWidth(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
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
                        size: getProportionateScreenWidth(22),
                        color:
                            ((item['isDark'] ?? true)
                                    ? Colors.white
                                    : Colors.black)
                                .withValues(alpha: isEnabled ? 1.0 : 0.7),
                      )
                    : Container(
                        padding: EdgeInsets.all(
                          getProportionateScreenWidth(10),
                        ),
                        child: SvgPicture.asset(
                          item['logoAsset'],
                          colorFilter: null,
                        ),
                      ),
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(12)),
            // Middle Details
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -getProportionateScreenHeight(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (item['name'] as String).toCapitalized(),
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(12),
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? Colors.black
                            : Colors.black.withValues(alpha: 0.5),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(2)),
                    Text(
                      _getSubtitle().toCapitalized(),
                      style: TextStyle(fontFamily: 'DMSans', 
                        fontSize: getProportionateScreenWidth(9),
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(9)),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(10),
                        vertical: getProportionateScreenHeight(2),
                      ),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? const Color.fromARGB(255, 227, 246, 219)
                            : const Color.fromARGB(255, 255, 249, 221),
                        borderRadius: BorderRadius.circular(
                          getProportionateScreenWidth(15),
                        ),
                      ),
                      child: Text(
                        status.toCapitalized(),
                        style: TextStyle(fontFamily: 'DMSans', 
                          fontSize: getProportionateScreenWidth(8),
                          fontWeight: FontWeight.w500,
                          color: isEnabled
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Side Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${item['amount'].toInt()}",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(14),
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? Colors.black
                        : Colors.black.withValues(alpha: 0.3),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  (item['name']?.toString().toLowerCase() == 'canva' || item['isYearly'] == true
                          ? "per year"
                          : "per month")
                      .toLowerCase(),
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(8),
                    color: Colors.black.withValues(alpha: isEnabled ? 0.4 : 0.3),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(4)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
