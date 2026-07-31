import 'package:astra_frontend/core/instrumentation/instrumentation.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';

class YearlyCalendarViewWidget extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onMonthSelected;
  final ScrollController? scrollController;

  const YearlyCalendarViewWidget({
    super.key,
    required this.initialDate,
    required this.onMonthSelected,
    this.scrollController,
  });

  static const int kStartYearOffset = 10;
  static const int kTotalYears = 61;

  static int getStartYear() => DateTime.now().year - kStartYearOffset;

  static double calculateYearSectionHeight(BuildContext context) {
    final double monthNameHeight = getProportionateScreenHeight(24);
    final double monthGap = getProportionateScreenHeight(6);
    final double monthPainterHeight = getProportionateScreenHeight(80);
    final double miniMonthHeight = monthNameHeight + monthGap + monthPainterHeight;
    
    final double gridRowGap = getProportionateScreenHeight(24);
    final double gridHeight = (miniMonthHeight * 4) + (gridRowGap * 3);
    
    final double yearHeaderHeight = getProportionateScreenHeight(24) + 
                                   getProportionateScreenHeight(48) + // Fixed text height
                                   getProportionateScreenHeight(16);
                                   
    final double yearBottomGap = getProportionateScreenHeight(32);
    final double dividerHeight = 1.0;
    
    return yearHeaderHeight + gridHeight + yearBottomGap + dividerHeight;
  }

  @override
  State<YearlyCalendarViewWidget> createState() => _YearlyCalendarViewWidgetState();
}

class _YearlyCalendarViewWidgetState extends State<YearlyCalendarViewWidget> {
  
  // Generate years from current year - 10 to +50 years
  late final List<int> years;

  @override
  void initState() {
    super.initState();
    final int startYear = YearlyCalendarViewWidget.getStartYear();
    years = List.generate(
      YearlyCalendarViewWidget.kTotalYears,
      (index) => startYear + index,
    );

    // Auto-scroll to current year on open with subtle delay to ensure Layout 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted && widget.scrollController != null &&
              widget.scrollController!.hasClients) {
            final double sectionHeight =
                YearlyCalendarViewWidget.calculateYearSectionHeight(context);
            final int currentYear = DateTime.now().year;
            final int startYear = YearlyCalendarViewWidget.getStartYear();
            final int targetIndex = currentYear - startYear;
            widget.scrollController!.jumpTo(sectionHeight * targetIndex);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sectionHeight = YearlyCalendarViewWidget.calculateYearSectionHeight(context);
    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      itemExtent: sectionHeight,
      itemCount: years.length,
      itemBuilder: (context, index) {
        return _buildYearSection(context, years[index], sectionHeight);
      },
    );
  }

  Widget _buildYearSection(BuildContext context, int year, double sectionHeight) {
    return SizedBox(
      height: sectionHeight,
      child: RepaintBoundary(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year Heading
          SizedBox(height: getProportionateScreenHeight(24)),
          SizedBox(
            height: getProportionateScreenHeight(48),
            child: Text(
              year.toString(),
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: getProportionateScreenWidth(32),
                fontWeight: FontWeight.w600,
                color: year == widget.initialDate.year
                    ? const Color(0xFFFF3B30) // Brand Red
                    : Colors.black,
              ),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(16)),

          // Months Grid (Refactored to Column+Rows for pixel-perfect height)
          Column(
            children: List.generate(4, (rowIndex) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: rowIndex < 3 ? getProportionateScreenHeight(24) : 0,
                ),
                child: Row(
                  children: List.generate(3, (colIndex) {
                    final month = (rowIndex * 3) + colIndex + 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: colIndex < 2 ? getProportionateScreenWidth(16) : 0,
                        ),
                        child: _buildMiniMonth(context, year, month),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),

          SizedBox(height: getProportionateScreenHeight(32)),
          Divider(
            color: Colors.black.withOpacity(0.1),
            height: 1.0,
            thickness: 1.0,
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildMiniMonth(BuildContext context, int year, int month) {
    final DateTime targetMonthDate = DateTime(year, month);
    final String monthName = DateFormat('MMM').format(targetMonthDate);

    final DateTime now = DateTime.now();
    final bool isCurrentMonth = now.year == year && now.month == month;

    return ZeyroTapDetector(eventName: 'yearly_calendar_view_month_tapped', 
      onTap: () => widget.onMonthSelected(targetMonthDate),
      child: Container(
        color: Colors.transparent, // For hit testing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: getProportionateScreenHeight(24),
                child: Text(
                  monthName.toLowerCase(),
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: getProportionateScreenWidth(16),
                    fontWeight: FontWeight.w600,
                    color: isCurrentMonth
                        ? const Color(0xFFFF3B30)
                        : Colors.black,
                  ),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(6)),
              SizedBox(
                width: getProportionateScreenWidth(100),
                height: getProportionateScreenHeight(80),
                child: CustomPaint(
                  painter: MiniMonthPainter(
                    year: year,
                    month: month,
                    isCurrentMonth: isCurrentMonth,
                    todayDay: now.day,
                    textColor: Colors.black.withOpacity(0.8),
                    todayColor: const Color(0xFFFF3B30),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class MiniMonthPainter extends CustomPainter {
  final int year;
  final int month;
  final bool isCurrentMonth;
  final int todayDay;
  final Color textColor;
  final Color todayColor;

  MiniMonthPainter({
    required this.year,
    required this.month,
    required this.isCurrentMonth,
    required this.todayDay,
    required this.textColor,
    required this.todayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int firstDayOfWeek = DateTime(year, month, 1).weekday;
    final int offset = firstDayOfWeek - 1;

    final double cellWidth = size.width / 7;
    final double cellHeight = size.height / 6;

    final textStyle = TextStyle(
      color: textColor,
      fontSize: cellWidth * 0.6,
      fontWeight: FontWeight.w400,
    );

    final todayStyle = textStyle.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

    final paintCircle = Paint()
      ..color = todayColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 42; i++) {
      final int dayNumber = i - offset + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) continue;

      final double x = (i % 7) * cellWidth;
      final double y = (i ~/ 7) * cellHeight;

      if (isCurrentMonth && dayNumber == todayDay) {
        // Draw today highlight circle
        canvas.drawCircle(
          Offset(x + cellWidth / 2, y + cellHeight / 2),
          cellWidth * 0.45,
          paintCircle,
        );

        _drawText(
          canvas,
          dayNumber.toString(),
          x,
          y,
          cellWidth,
          cellHeight,
          todayStyle,
        );
      } else {
        _drawText(
          canvas,
          dayNumber.toString(),
          x,
          y,
          cellWidth,
          cellHeight,
          textStyle,
        );
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double w,
    double h,
    TextStyle style,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: w, maxWidth: w);
    textPainter.paint(canvas, Offset(x, y + (h - textPainter.height) / 2));
  }

  @override
  bool shouldRepaint(covariant MiniMonthPainter oldDelegate) {
    return oldDelegate.year != year ||
        oldDelegate.month != month ||
        oldDelegate.isCurrentMonth != isCurrentMonth;
  }
}
