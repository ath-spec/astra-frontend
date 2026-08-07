
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/extensions/string_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class RecurringHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> payment;

  const RecurringHistoryScreen({super.key, required this.payment});

  @override
  State<RecurringHistoryScreen> createState() => _RecurringHistoryScreenState();
}

class _RecurringHistoryScreenState extends State<RecurringHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView('recurring_history_screen');
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final double topPadding = MediaQuery.paddingOf(context).top;

    // Animation thresholds for sticky header title fade
    final double titleFadeStart = getProportionateScreenHeight(40);
    final double titleFadeEnd = getProportionateScreenHeight(100);
    final double opacity =
        ((_scrollOffset - titleFadeStart) / (titleFadeEnd - titleFadeStart))
            .clamp(0.0, 1.0);

    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          // Content
          Positioned.fill(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                getProportionateScreenWidth(20),
                topPadding + getProportionateScreenHeight(80),
                getProportionateScreenWidth(20),
                MediaQuery.paddingOf(context).bottom +
                    getProportionateScreenHeight(24),
              ),
              children: [
                _buildSummaryStat(_scrollOffset),
                SizedBox(height: getProportionateScreenHeight(32)),
                Text(
                  "Detailed history",
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: getProportionateScreenWidth(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(16)),
                _buildHistoryRow(
                  "Apr 7, 2026",
                  "₹${widget.payment['amount'].toInt()}",
                  "Paid",
                  const Color(0xFFDFF0D8),
                  const Color(0xFF3C763D),
                ),
                _buildHistoryRow(
                  "Mar 7, 2026",
                  "₹${widget.payment['amount'].toInt()}",
                  "Paid",
                  const Color(0xFFDFF0D8),
                  const Color(0xFF3C763D),
                ),
                _buildHistoryRow(
                  "Feb 7, 2026",
                  "₹${widget.payment['amount'].toInt()}",
                  "Paid",
                  const Color(0xFFDFF0D8),
                  const Color(0xFF3C763D),
                ),
                _buildHistoryRow(
                  "Jan 7, 2026",
                  "₹${widget.payment['amount'].toInt()}",
                  "Paid",
                  const Color(0xFFDFF0D8),
                  const Color(0xFF3C763D),
                ),
                _buildHistoryRow(
                  "Dec 7, 2025",
                  "₹${widget.payment['amount'].toInt()}",
                  "Paid",
                  const Color(0xFFDFF0D8),
                  const Color(0xFF3C763D),
                ),
                _buildHistoryRow(
                  "Nov 7, 2025",
                  "₹${widget.payment['amount'].toInt()}",
                  "Paid",
                  const Color(0xFFDFF0D8),
                  const Color(0xFF3C763D),
                ),
                _buildHistoryRow(
                  "Oct 7, 2025",
                  "₹${widget.payment['amount'].toInt()}",
                  "Paid",
                  const Color(0xFFDFF0D8),
                  const Color(0xFF3C763D),
                ),
                _buildHistoryRow(
                  "Sep 7, 2025",
                  "₹${widget.payment['amount'].toInt()}",
                  "Failed",
                  const Color(0xFFF2E7D5),
                  const Color(0xFF8A6D3B),
                ),
                _buildHistoryRow(
                  "Aug 7, 2025",
                  "₹${widget.payment['amount'].toInt()}",
                  "Paid",
                  const Color(0xFFDFF0D8),
                  const Color(0xFF3C763D),
                ),
              ],
            ),
          ),

          // Custom Sticky Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: opacity * 10,
                  sigmaY: opacity * 10,
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    getProportionateScreenWidth(16),
                    topPadding + getProportionateScreenHeight(10),
                    getProportionateScreenWidth(16),
                    getProportionateScreenHeight(12),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(opacity * 0.8),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: getProportionateScreenWidth(38),
                          height: getProportionateScreenWidth(38),
                          alignment: Alignment.centerLeft,
                          color: Colors.transparent,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Opacity(
                          opacity: opacity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (widget.payment['name'] as String)
                                    .toCapitalized(),
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: getProportionateScreenWidth(14),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "total: ₹${(widget.payment['amount'] * (widget.payment['name']?.toString().toLowerCase() == 'canva' || widget.payment['isYearly'] == true ? 3.0 : 8.5)).toInt()}"
                                    .toCapitalized(),
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: getProportionateScreenWidth(10),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: getProportionateScreenWidth(38),
                      ), // Spacer
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(double scrollOffset) {
    final double heroOpacity = (1.0 - (scrollOffset / 100.0)).clamp(0.0, 1.0);
    final bool isYearly =
        widget.payment['name']?.toString().toLowerCase() == 'canva' ||
        widget.payment['isYearly'] == true;
    final double summaryMultiplier = isYearly ? 3.0 : 8.5;

    return Opacity(
      opacity: heroOpacity,
      child: Transform.translate(
        offset: Offset(0, -scrollOffset * 0.2),
        child: Container(
          padding: EdgeInsets.all(getProportionateScreenWidth(24)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF000000), Color(0xFF222222)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: getProportionateScreenWidth(40),
                        height: getProportionateScreenWidth(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            getProportionateScreenWidth(4),
                          ),
                        ),
                        child:
                            widget.payment['name'] == 'Netflix' &&
                                widget.payment['logoAsset'] == null
                            ? Center(
                                child: Text(
                                  'N',
                                  style: TextStyle(
                                    fontFamily: 'BebasNeue',
                                    color: Colors.white,
                                    fontSize: getProportionateScreenWidth(18),
                                  ),
                                ),
                              )
                            : (widget.payment['logoAsset'] != null)
                            ? SvgPicture.asset(
                                widget.payment['logoAsset'],
                                colorFilter: null,
                              )
                            : Icon(
                                widget.payment['icon'] as IconData? ??
                                    Icons.subscriptions_rounded,
                                color: (widget.payment['isDark'] ?? true)
                                    ? Colors.white
                                    : Colors.black,
                                size: getProportionateScreenWidth(20),
                              ),
                      ),
                      SizedBox(width: getProportionateScreenWidth(12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (widget.payment['name'] as String).toCapitalized(),
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: getProportionateScreenWidth(16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            "Total expense",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: getProportionateScreenWidth(10),
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.show_chart_rounded,
                    color: Color(0xFFD6FF3F),
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: getProportionateScreenHeight(12)),
              Text(
                "₹${(widget.payment['amount'] * summaryMultiplier).toInt()}",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: getProportionateScreenWidth(32),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(8)),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6FF3F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (isYearly ? "3 payments" : "9 payments").toCapitalized(),
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: getProportionateScreenWidth(9),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    (isYearly ? "since 2023" : "since last year").toCapitalized(),
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: getProportionateScreenWidth(10),
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryRow(
    String date,
    String amount,
    String status,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(4)),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(10)),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                getProportionateScreenWidth(4),
              ),
            ),
            child: Icon(
              status == 'Paid'
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: textColor,
              size: getProportionateScreenWidth(20),
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: getProportionateScreenWidth(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(2)),
                Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: getProportionateScreenWidth(10),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: getProportionateScreenWidth(16),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                "Confirmed",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: getProportionateScreenWidth(8),
                  color: Colors.black.withOpacity(0.3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
