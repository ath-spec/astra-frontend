import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/privacy_formatter.dart';

class StockData {
  final String name;
  final String sector;
  final double allocation;
  final String logoAsset;
  final double currentVal;
  final double oneDayChange;
  final double oneDayChangePct;
  final int quantity;
  final double ltp;

  const StockData({
    required this.name,
    required this.sector,
    required this.allocation,
    this.logoAsset = '',
    required this.currentVal,
    required this.oneDayChange,
    required this.oneDayChangePct,
    required this.quantity,
    required this.ltp,
  });
}

class StockCard extends StatefulWidget {
  final StockData stock;
  final bool forceExpanded;
  final bool isLocked;

  const StockCard({super.key, required this.stock, this.forceExpanded = false, this.isLocked = false});

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {
    bool _isExpanded = false;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  final _currencyFormatDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final bool showExpanded = widget.forceExpanded || _isExpanded;
    final curve = const Cubic(
      0.23,
      1.0,
      0.32,
      1.0,
    ); // Emil-style ease-out curve

    return GestureDetector(
      onTap: () {
        if (!widget.forceExpanded) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: curve,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo placeholder
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Center(
                    child: Text(
                      widget.stock.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.stock.name,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstCurve: curve,
                        secondCurve: curve,
                        sizeCurve: curve,
                        crossFadeState: showExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          '${widget.stock.sector} • ${widget.stock.allocation}% of stocks',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        secondChild: Row(
                          children: [
                            Text(
                              '1D Change: ',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              widget.isLocked ? PrivacyFormatter.cypher : '${widget.stock.oneDayChange >= 0 ? '↑' : '↓'} ${_currencyFormat.format(widget.stock.oneDayChange.abs())} (${widget.stock.oneDayChangePct}%)',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: widget.stock.oneDayChange >= 0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!showExpanded)
                  Text(
                    PrivacyFormatter.obscure(_currencyFormat.format(widget.stock.currentVal), widget.isLocked),
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
              ],
            ),

            // Expanded Content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: curve,
              child: showExpanded
                  ? Column(
                      children: [
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                              'Current',
                              PrivacyFormatter.obscure(_currencyFormat.format(widget.stock.currentVal), widget.isLocked),
                            ),
                            _buildStatItem(
                              'Quantity',
                              widget.isLocked ? PrivacyFormatter.cypher : widget.stock.quantity.toString(),
                              center: true,
                            ),
                            _buildStatItem(
                              'Last Traded Price',
                              PrivacyFormatter.obscure(_currencyFormatDecimals.format(widget.stock.ltp), widget.isLocked),
                              right: true,
                            ),
                          ],
                        ),
                      ],
                    )
                  : SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value, {
    bool center = false,
    bool right = false,
  }) {
    CrossAxisAlignment align = CrossAxisAlignment.start;
    if (center) align = CrossAxisAlignment.center;
    if (right) align = CrossAxisAlignment.end;

    return Expanded(
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
