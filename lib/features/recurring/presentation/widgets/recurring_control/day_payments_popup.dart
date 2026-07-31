import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';

class DayPaymentsPopup extends StatelessWidget {
  final int date;
  final List<Map<String, dynamic>> payments;
  final VoidCallback onClose;

  const DayPaymentsPopup({
    super.key,
    required this.date,
    required this.payments,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total amount
    double totalAmount = payments.fold(
      0.0,
      (sum, item) => sum + (item['amount'] as double),
    );

    return Container(
      padding: EdgeInsets.all(getProportionateScreenWidth(20)),
      width: getProportionateScreenWidth(300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: getProportionateScreenWidth(30),
            spreadRadius: 0,
            offset: Offset(0, getProportionateScreenHeight(10)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // List of payments
          ...payments.map((payment) => _buildPaymentRow(payment)),

          SizedBox(height: getProportionateScreenHeight(8)),
          Divider(color: Colors.black.withOpacity(0.06), thickness: getProportionateScreenHeight(1)),
          SizedBox(height: getProportionateScreenHeight(12)),

          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "total",
                style: TextStyle(fontFamily: 'Syne', 
                  fontSize: getProportionateScreenWidth(12),
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "₹${totalAmount.toStringAsFixed(2).replaceAll('.00', '')}", // Format cleanly
                style: TextStyle(fontFamily: 'Syne', 
                  fontSize: getProportionateScreenWidth(16),
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(Map<String, dynamic> payment) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: getProportionateScreenWidth(36),
            height: getProportionateScreenWidth(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(getProportionateScreenWidth(10)),
            ),
            child: Center(
              child: (payment['logoAsset'] != null)
                  ? SvgPicture.asset(
                      payment['logoAsset'],
                      width: getProportionateScreenWidth(20),
                      height: getProportionateScreenWidth(20),
                      colorFilter: null,
                    )
                  : (payment['icon'] != null)
                      ? Icon(
                          payment['icon'] as IconData,
                          size: getProportionateScreenWidth(18),
                          color: Colors.black,
                        )
                      : Icon(
                          Icons.category_rounded,
                          size: getProportionateScreenWidth(18),
                          color: Colors.black,
                        ),
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(12)),

          // Name and Type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (payment['name'] as String).toLowerCase(),
                  style: TextStyle(fontFamily: 'Syne', 
                    fontSize: getProportionateScreenWidth(12),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(1)),
                Text(
                  (payment['type'] as String).toLowerCase(),
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(10),
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            "₹${(payment['amount'] as double).toStringAsFixed(2).replaceAll('.00', '')}",
            style: TextStyle(fontFamily: 'Syne', 
              fontSize: getProportionateScreenWidth(12),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
