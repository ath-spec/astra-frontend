
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:astra_frontend/core/extensions/string_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:astra_frontend/core/responsive/size_config.dart';
import 'package:astra_frontend/features/recurring/data/recurring_models.dart';
import 'package:astra_frontend/features/recurring/data/recurring_providers.dart';
import 'package:astra_frontend/services/analytics_service.dart';

class RecurringHistoryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> payment;

  const RecurringHistoryScreen({super.key, required this.payment});

  @override
  ConsumerState<RecurringHistoryScreen> createState() => _RecurringHistoryScreenState();
}

class _RecurringHistoryScreenState extends ConsumerState<RecurringHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  String get _mandateId => (widget.payment['mandateId'] ?? widget.payment['id']).toString();

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
    final historyAsync = ref.watch(mandateHistoryProvider(_mandateId));

    // Animation thresholds for sticky header title fade
    final double titleFadeStart = getProportionateScreenHeight(40);
    final double titleFadeEnd = getProportionateScreenHeight(100);
    final double opacity =
        ((_scrollOffset - titleFadeStart) / (titleFadeEnd - titleFadeStart))
            .clamp(0.0, 1.0);

    final history = historyAsync.valueOrNull ?? const <MandateExecution>[];
    final successful = history.where((h) => h.status.toUpperCase() == 'SUCCESS');
    final totalPaid = successful.fold<double>(0.0, (sum, h) => sum + h.amount);

    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          // Content
          Positioned.fill(
            child: historyAsync.isLoading && history.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(
                      getProportionateScreenWidth(20),
                      topPadding + getProportionateScreenHeight(80),
                      getProportionateScreenWidth(20),
                      MediaQuery.paddingOf(context).bottom +
                          getProportionateScreenHeight(24),
                    ),
                    children: [
                      _buildSummaryStat(_scrollOffset, totalPaid, successful.length),
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
                      if (history.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(24)),
                          child: Text(
                            "No payment history yet",
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: getProportionateScreenWidth(13),
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                          ),
                        )
                      else
                        ...history.map((execution) {
                          final isSuccess = execution.status.toUpperCase() == 'SUCCESS';
                          final date = execution.scheduledDateTime;
                          return _buildHistoryRow(
                            date != null ? DateFormat('MMM d, yyyy').format(date) : '—',
                            "₹${execution.amount.toInt()}",
                            isSuccess ? "Paid" : "Failed",
                            isSuccess ? const Color(0xFFDFF0D8) : const Color(0xFFF2E7D5),
                            isSuccess ? const Color(0xFF3C763D) : const Color(0xFF8A6D3B),
                          );
                        }),
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
                    color: Colors.white.withValues(alpha: opacity * 0.8),
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
                                "total: ₹${totalPaid.toInt()}".toCapitalized(),
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: getProportionateScreenWidth(10),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.4),
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

  Widget _buildSummaryStat(double scrollOffset, double totalPaid, int paymentCount) {
    final double heroOpacity = (1.0 - (scrollOffset / 100.0)).clamp(0.0, 1.0);

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
                color: Colors.black.withValues(alpha: 0.1),
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
                              color: Colors.white.withValues(alpha: 0.5),
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
                "₹${totalPaid.toInt()}",
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
                      "$paymentCount payment${paymentCount == 1 ? '' : 's'}".toCapitalized(),
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: getProportionateScreenWidth(9),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
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
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              color: bgColor.withValues(alpha: 0.2),
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
                status == 'Paid' ? "Confirmed" : "Retry pending",
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: getProportionateScreenWidth(8),
                  color: Colors.black.withValues(alpha: 0.3),
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
