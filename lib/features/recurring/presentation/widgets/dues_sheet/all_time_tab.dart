import 'package:flutter/material.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/presentation/widgets/dues_sheet/subscription_tile.dart';

class AllTab extends StatelessWidget {
  final DateTime currentMonth;
  final List<Map<String, dynamic>> payments;
  final Function(String, String, {DateTime? pauseUntil}) onStatusChanged;
  final ScrollController? scrollController;

  const AllTab({
    super.key,
    required this.currentMonth,
    required this.payments,
    required this.onStatusChanged,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.sizeOf(context).height * 0.4,
          alignment: Alignment.center,
          child: Text(
            "No subscriptions found",
            style: TextStyle(fontFamily: 'DMSans', 
              color: Colors.black.withValues(alpha: 0.4),
              fontSize: getProportionateScreenWidth(14),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        left: getProportionateScreenWidth(20),
        right: getProportionateScreenWidth(20),
        top: getProportionateScreenHeight(8),
        bottom: MediaQuery.paddingOf(context).bottom + getProportionateScreenHeight(8),
      ),
      itemCount: payments.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: getProportionateScreenHeight(0)),
      itemBuilder: (context, index) {
        return SubscriptionTile(
          item: payments[index],
          onStatusChanged: onStatusChanged,
        );
      },
    );
  }
}
