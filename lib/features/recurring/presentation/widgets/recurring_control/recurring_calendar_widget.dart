
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/services/analytics_service.dart';


class RecurringCalendarWidget extends StatefulWidget {
  final DateTime currentMonth;
  final List<Map<String, dynamic>> payments;
  final ValueChanged<DateTime>? onMonthChanged;
  final VoidCallback? onHeaderTapped;
  final Function(int date, List<Map<String, dynamic>> payments)? onDaySelected;

  const RecurringCalendarWidget({
    super.key,
    required this.currentMonth,
    required this.payments,
    this.onMonthChanged,
    this.onHeaderTapped,
    this.onDaySelected,
  });

  @override
  State<RecurringCalendarWidget> createState() =>
      _RecurringCalendarWidgetState();
}

class _RecurringCalendarWidgetState extends State<RecurringCalendarWidget> {
  Map<int, List<Map<String, dynamic>>> get _mockPayments {
    final Map<int, List<Map<String, dynamic>>> map = {};
    final int currentMonth = widget.currentMonth.month;
    for (var payment in widget.payments) {
      // If a payment has a specific 'month' (yearly subscriptions), 
      // only show it on the calendar when viewing that month
      if (payment['month'] != null && payment['month'] != currentMonth) {
        continue;
      }
      final int day = payment['day'] ?? 1;
      if (!map.containsKey(day)) {
        map[day] = [];
      }
      map[day]!.add(payment);
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        getProportionateScreenWidth(8),
        getProportionateScreenWidth(22),
        getProportionateScreenWidth(8),
        getProportionateScreenWidth(8),
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 255, 255, 255),
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          getProportionateScreenWidth(16),
          getProportionateScreenWidth(0),
          getProportionateScreenWidth(16),
          getProportionateScreenWidth(16),
        ),
        child: Column(
          children: [
            _buildDaysOfWeek(),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        days.length,
        (i) => Expanded(
          child: Center(
            child: Text(
              days[i],
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(11),
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final int year = widget.currentMonth.year;
    final int month = widget.currentMonth.month;
    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int firstDayOfWeek = DateTime(year, month, 1).weekday % 7;
    final int prevMonthLastDay = DateTime(year, month, 0).day;
    final int totalDaysNeeded = firstDayOfWeek + daysInMonth;
    final int totalCells = (totalDaysNeeded / 7).ceil() * 7;

    return GridView.builder(
      padding: EdgeInsets.only(top: getProportionateScreenWidth(16)),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: getProportionateScreenWidth(4),
        mainAxisSpacing: getProportionateScreenHeight(4),
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        int day;
        bool isCurrentMonth = true;
        if (index < firstDayOfWeek) {
          day = prevMonthLastDay - firstDayOfWeek + index + 1;
          isCurrentMonth = false;
        } else if (index >= firstDayOfWeek + daysInMonth) {
          day = index - (firstDayOfWeek + daysInMonth) + 1;
          isCurrentMonth = false;
        } else {
          day = index - firstDayOfWeek + 1;
        }
        return _buildDayCell(day, isCurrentMonth: isCurrentMonth);
      },
    );
  }

  Widget _buildDayCell(int day, {bool isCurrentMonth = true}) {
    final now = DateTime.now();
    bool isToday = isCurrentMonth &&
        widget.currentMonth.year == now.year &&
        widget.currentMonth.month == now.month &&
        day == now.day;
    bool hasPayments = isCurrentMonth && _mockPayments.containsKey(day);

    return GestureDetector(
      onTap: isCurrentMonth 
        ? () {
            AnalyticsService.instance.logEvent('recurring_calendar_widget_day_tapped');
            if (hasPayments) {
              widget.onDaySelected?.call(day, _mockPayments[day]!);
            }
          }
        : null,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: getProportionateScreenWidth(48),
          height: getProportionateScreenWidth(48),
          decoration: BoxDecoration(
            color: isToday
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Day number hidden if logos exist
              if (!hasPayments)
                Text(
                  day.toString(),
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(14),
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    color: isCurrentMonth ? Colors.white : Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              // Center payment logos if they exist
              if (hasPayments)
                _buildPaymentStack(_mockPayments[day]!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStack(List<Map<String, dynamic>> payments) {
    if (payments.isEmpty) return const SizedBox.shrink();

    final mainPayment = payments[0];
    final otherPayments = payments.skip(1).take(4).toList();
    const double logoSize = 24.0;
    const double pillHeight = 4.0;
    const double segmentWidth = 8.0;

    final List<Color> themeColors = [
      Color(0xFFECCFF0),
      Color(0xFFC8E6C9),
      Color(0xFF4808C7).withValues(alpha: 0.5),
      Color(0xFFD6FF3F),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Primary Logo
        SizedBox(
          width: getProportionateScreenWidth(logoSize),
          height: getProportionateScreenWidth(logoSize),
          child: Center(
            child: (mainPayment['logoAsset'] != null)
                ? SvgPicture.asset(
                    mainPayment['logoAsset'],
                    width: getProportionateScreenWidth(20),
                    height: getProportionateScreenWidth(20),
                    colorFilter: null,
                  )
                : (mainPayment['icon'] != null)
                    ? Icon(
                        mainPayment['icon'] as IconData,
                        size: getProportionateScreenWidth(12),
                        color: Colors.black,
                      )
                    : Icon(
                        Icons.category_rounded,
                        size: getProportionateScreenWidth(12),
                        color: Colors.black,
                      ),
          ),
        ),
        
        // Individual Multi-Payment Dots (Google Calendar style)
        if (otherPayments.isNotEmpty) ...[
          SizedBox(height: getProportionateScreenHeight(4)),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(otherPayments.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(1)),
                width: getProportionateScreenWidth(4),
                height: getProportionateScreenWidth(4),
                decoration: BoxDecoration(
                  color: themeColors[index % themeColors.length],
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
