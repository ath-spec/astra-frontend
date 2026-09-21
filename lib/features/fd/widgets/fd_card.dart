import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/privacy_formatter.dart';

/// View-model for one FD row, mirroring StockData's role for StockCard —
/// same shape, same interaction pattern, different fields.
class FDData {
  final String accountNumber;
  final double principalAmount;
  final double interestRate;
  final int tenureMonths;
  final double maturityAmount;
  final DateTime maturityDate;
  final String status;
  final double allocation;

  const FDData({
    required this.accountNumber,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.maturityAmount,
    required this.maturityDate,
    required this.status,
    required this.allocation,
  });

  DateTime get openDate =>
      DateTime(maturityDate.year, maturityDate.month - tenureMonths, maturityDate.day);

  /// Linear accrual estimate — the backend doesn't expose a day-by-day
  /// interest ledger for a mock FD, so this interpolates between principal
  /// and maturity value by elapsed time. Clamped so a not-yet-started or
  /// already-matured account doesn't produce a value outside that range.
  double get accruedInterest {
    final totalGain = maturityAmount - principalAmount;
    final totalSpan = maturityDate.difference(openDate).inSeconds;
    if (totalSpan <= 0) return 0;
    final elapsed = DateTime.now().difference(openDate).inSeconds;
    final ratio = (elapsed / totalSpan).clamp(0.0, 1.0);
    return totalGain * ratio;
  }
}

class FDCard extends StatefulWidget {
  final FDData fd;
  final bool forceExpanded;
  final bool isLocked;

  const FDCard({super.key, required this.fd, this.forceExpanded = false, this.isLocked = false});

  @override
  State<FDCard> createState() => _FDCardState();
}

class _FDCardState extends State<FDCard> {
  bool _isExpanded = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final _dateFormat = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final bool showExpanded = widget.forceExpanded || _isExpanded;
    final curve = const Cubic(0.23, 1.0, 0.32, 1.0);
    final last4 = widget.fd.accountNumber.length >= 4
        ? widget.fd.accountNumber.substring(widget.fd.accountNumber.length - 4)
        : widget.fd.accountNumber;

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
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Icon(Icons.savings_rounded, size: 18, color: Color(0xFF0F172A)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FD •••• $last4',
                        style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 4),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstCurve: curve,
                        secondCurve: curve,
                        sizeCurve: curve,
                        crossFadeState: showExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: Text(
                          '${widget.fd.interestRate.toStringAsFixed(2)}% p.a. • ${widget.fd.allocation}% of FDs',
                          style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondChild: Text.rich(
                          TextSpan(
                            text: 'Matures ${_dateFormat.format(widget.fd.maturityDate)}: ',
                            style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF94A3B8)),
                            children: [
                              TextSpan(
                                text: widget.isLocked
                                    ? PrivacyFormatter.cypher
                                    : '↑ ${_currencyFormat.format(widget.fd.accruedInterest)} accrued',
                                style: const TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!showExpanded)
                  Text(
                    PrivacyFormatter.obscure(_currencyFormat.format(widget.fd.principalAmount), widget.isLocked),
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: curve,
              child: showExpanded
                  ? Column(
                      children: [
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                              'Principal',
                              PrivacyFormatter.obscure(_currencyFormat.format(widget.fd.principalAmount), widget.isLocked),
                            ),
                            _buildStatItem(
                              'Tenure',
                              widget.isLocked ? PrivacyFormatter.cypher : '${widget.fd.tenureMonths} mo',
                              center: true,
                            ),
                            _buildStatItem(
                              'Maturity Value',
                              PrivacyFormatter.obscure(_currencyFormat.format(widget.fd.maturityAmount), widget.isLocked),
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

  Widget _buildStatItem(String label, String value, {bool center = false, bool right = false}) {
    CrossAxisAlignment align = CrossAxisAlignment.start;
    if (center) align = CrossAxisAlignment.center;
    if (right) align = CrossAxisAlignment.end;

    return Expanded(
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'DMSans', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
