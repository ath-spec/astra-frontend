
import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class UpiPinBottomSheet extends StatefulWidget {
  final Map<String, dynamic> payment;

  const UpiPinBottomSheet({super.key, required this.payment});

  @override
  State<UpiPinBottomSheet> createState() => _UpiPinBottomSheetState();
}

class _UpiPinBottomSheetState extends State<UpiPinBottomSheet> {
  String _pin = "";

  void _onKeyTap(String key) {
    if (_pin.length < 6) {
      setState(() {
        _pin += key;
      });
      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyPin() async {
    // Simulate verification delay
    await Future.delayed(const Duration(milliseconds: 500));
    // Allowing all pins for now as requested
    if (mounted) Navigator.of(context).pop(true);
  }

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
            const SizedBox(height: 32),

            // App Header (UPI Sim-style)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ZeyroTapDetector(eventName: 'upi_pin_bottom_sheet_back_tapped', 
                  onTap: () { Navigator.of(context).pop(); },
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: getProportionateScreenWidth(20)),
                ),
                Text(
                  "ENTER UPI PIN",
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(14),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(24)),
              ],
            ),

            SizedBox(height: getProportionateScreenHeight(40)),

            Text(
              "confirm cancellation for ${widget.payment['name']}",
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(16),
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 32),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                bool isFilled = index < _pin.length;
                return Container(
                  width: getProportionateScreenWidth(16),
                  height: getProportionateScreenWidth(16),
                  margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(12)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black.withOpacity(0.2)),
                    color: isFilled ? Colors.black : Colors.transparent,
                  ),
                );
              }),
            ),

            SizedBox(height: getProportionateScreenHeight(48)),

            // Custom Keypad
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                if (index == 9) return const SizedBox.shrink();
                if (index == 10) return _buildKey("0");
                if (index == 11) return _buildBackspace();
                return _buildKey("${index + 1}");
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String label) {
    return GestureDetector(
      onTap: () {
        AnalyticsService.instance.logEvent('upi_pin_bottom_sheet_key_tapped');
        _onKeyTap(label);
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontFamily: 'DMSans', 
            fontSize: getProportionateScreenWidth(24),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspace() {
    return GestureDetector(
      onTap: () {
        AnalyticsService.instance.logEvent('upi_pin_bottom_sheet_backspace_tapped');
        _onBackspace();
      },
      behavior: HitTestBehavior.opaque,
      child: Center(child: Icon(Icons.backspace_outlined, size: getProportionateScreenWidth(24))),
    );
  }
}
