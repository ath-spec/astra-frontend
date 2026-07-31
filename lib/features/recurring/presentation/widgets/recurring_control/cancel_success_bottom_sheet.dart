import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';

class CancelSuccessBottomSheet extends StatelessWidget {
  const CancelSuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(getProportionateScreenWidth(40)),
            topRight: Radius.circular(getProportionateScreenWidth(40)),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(20),
          vertical: getProportionateScreenHeight(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: getProportionateScreenWidth(40),
                height: getProportionateScreenHeight(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(getProportionateScreenWidth(2)),
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(48)),

            // Illustration Space
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: getProportionateScreenWidth(120),
                  height: getProportionateScreenWidth(120),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: getProportionateScreenWidth(20),
                        offset: Offset(0, getProportionateScreenHeight(10)),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: getProportionateScreenWidth(60),
                        color: Colors.black.withOpacity(0.8),
                      ),
                      Text(
                        "₹",
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(24),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(4)),
                  decoration: const BoxDecoration(
                    color: Color(0xFF34C759),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: getProportionateScreenWidth(24),
                  ),
                ),
              ],
            ),

            SizedBox(height: getProportionateScreenHeight(40)),

            Text(
              "Cancelled successfully",
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(12),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF34C759),
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: getProportionateScreenHeight(16)),

            Text(
              "Your auto-pay has been\ncancelled successfully",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(15),
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.2,
              ),
            ),

            SizedBox(height: getProportionateScreenHeight(12)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(24)),
              child: Text(
                "You are in command with zeyro, no automatic payments will be deducted from your account now.",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: getProportionateScreenWidth(12),
                  color: Colors.black.withOpacity(0.4),
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: getProportionateScreenHeight(48)),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: getProportionateScreenHeight(56),
              child: ZeyroButton(eventName: 'cancel_success_bottom_sheet_close_tapped', 
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Understood",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontWeight: FontWeight.w600,
                    fontSize: getProportionateScreenWidth(16),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
